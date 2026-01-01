// ==================== lib/services/media_service.dart ====================
import 'dart:io';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import '../models/media_item.dart';
import 'package:audiotags/audiotags.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class MediaService {
  List<MediaItem> videos = [];
  List<MediaItem> music = [];

  Map<String, String> _customThumbnails = {};
  Map<String, dynamic> _metadataCache = {};
  File? _cacheFile;

  MediaService();

  Future<void> _initCache() async {
    final appDir = await getApplicationDocumentsDirectory();
    _cacheFile = File(path.join(appDir.path, 'media_metadata_cache.json'));

    if (await _cacheFile!.exists()) {
      try {
        final content = await _cacheFile!.readAsString();
        _metadataCache = json.decode(content);
      } catch (e) {
        print('Error loading cache: $e');
        _metadataCache = {};
      }
    }
  }

  Future<void> _saveCache() async {
    if (_cacheFile != null) {
      try {
        await _cacheFile!.writeAsString(json.encode(_metadataCache));
      } catch (e) {
        print('Error saving cache: $e');
      }
    }
  }

  Future<void> _loadCustomThumbnails() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('thumb_')) {
        final videoPath = key.substring(6);
        final thumbPath = prefs.getString(key);
        if (thumbPath != null) {
          _customThumbnails[videoPath] = thumbPath;
        }
      }
    }
  }

  Future<void> updateThumbnail(String videoPath, int timeMs) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final thumbFileName =
          'custom_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final thumbPath = path.join(appDir.path, thumbFileName);

      final uint8list = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        timeMs: timeMs,
        maxWidth: 200,
        quality: 50,
      );

      if (uint8list != null) {
        final file = File(thumbPath);
        await file.writeAsBytes(uint8list);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('thumb_$videoPath', thumbPath);

        _customThumbnails[videoPath] = thumbPath;

        // Also update cache to prevent override
        if (_metadataCache.containsKey(videoPath)) {
          _metadataCache[videoPath]['artPath'] = thumbPath;
          _saveCache();
        }

        final index = videos.indexWhere((v) => v.path == videoPath);
        if (index != -1) {
          videos[index] = videos[index].copyWith(albumArt: uint8list);
        }
      }
    } catch (e) {
      print('Error updating thumbnail: $e');
    }
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.status.isDenied) {
        await Permission.manageExternalStorage.request();
      }
      if (await Permission.manageExternalStorage.status.isGranted) {
        return true;
      }
      Map<Permission, PermissionStatus> statuses = await [
        Permission.videos,
        Permission.audio,
        Permission.storage,
      ].request();
      return statuses.values.any((status) => status.isGranted);
    }
    return true;
  }

  Future<void> loadMedia() async {
    await _initCache();
    await _loadCustomThumbnails();
    videos.clear();
    music.clear();

    if (Platform.isAndroid) {
      await _loadAndroidMedia();
    }
  }

  Future<void> _loadAndroidMedia() async {
    final directories = [
      '/storage/emulated/0/DCIM',
      '/storage/emulated/0/Movies',
      '/storage/emulated/0/Download',
      '/storage/emulated/0/Music',
      '/storage/emulated/0/Podcasts',
      '/storage/emulated/0/Telegram',
      '/storage/emulated/0/Android/media/org.telegram.messenger/Telegram',
    ];

    List<File> allFiles = [];

    // Phase 1: File collection
    for (final dirPath in directories) {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        await _collectFiles(dir, allFiles);
      }
    }

    // Phase 2: Processing
    List<File> videoFiles = [];
    List<File> audioFiles = [];

    for (final file in allFiles) {
      final ext = path.extension(file.path).toLowerCase();
      if (_isVideoFile(ext)) {
        videoFiles.add(file);
      } else if (_isAudioFile(ext)) {
        audioFiles.add(file);
      }
    }

    await _processBatch(videoFiles, true);
    await _processBatch(audioFiles, false);

    // Save cache after bulk processing
    await _saveCache();
  }

  Future<void> _collectFiles(Directory dir, List<File> collector) async {
    try {
      await for (final entity in dir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File) {
          collector.add(entity);
        }
      }
    } catch (e) {
      // print('Error collecting files from ${dir.path}: $e');
    }
  }

  Future<void> _processBatch(List<File> files, bool isVideo) async {
    const int batchSize = 10;
    for (var i = 0; i < files.length; i += batchSize) {
      final end = (i + batchSize < files.length) ? i + batchSize : files.length;
      final batch = files.sublist(i, end);

      final results = await Future.wait(
        batch.map((file) => _getMediaItem(file, isVideo: isVideo)),
      );

      if (isVideo) {
        videos.addAll(results);
      } else {
        music.addAll(results);
      }
      // Incremental save could be here but might slow things down.
      // Saving at the very end is usually better for I/O.
    }
  }

  bool _isVideoFile(String ext) {
    return [
      '.mp4',
      '.mkv',
      '.avi',
      '.mov',
      '.wmv',
      '.flv',
      '.3gp',
      '.webm',
      '.m4v',
      '.mpeg',
      '.mpg',
      '.m2ts',
      '.ts',
      '.qt',
      '.m4p',
    ].contains(ext);
  }

  bool _isAudioFile(String ext) {
    return [
      '.mp3',
      '.m4a',
      '.wav',
      '.flac',
      '.aac',
      '.ogg',
      '.wma',
      '.opus',
    ].contains(ext);
  }

  Future<MediaItem> _getMediaItem(File file, {required bool isVideo}) async {
    try {
      final stat = await file.stat();
      final lastModified = stat.modified.millisecondsSinceEpoch;
      final cacheKey = file.path;

      // Check Cache
      if (_metadataCache.containsKey(cacheKey)) {
        final entry = _metadataCache[cacheKey];
        if (entry['lastModified'] == lastModified) {
          // Cache Hit
          Uint8List? artBytes;

          // Check for custom override first
          if (isVideo && _customThumbnails.containsKey(file.path)) {
            final customPath = _customThumbnails[file.path]!;
            final customFile = File(customPath);
            if (await customFile.exists()) {
              artBytes = await customFile.readAsBytes();
            }
          }

          // If no custom or not found, try cached art path
          if (artBytes == null && entry['artPath'] != null) {
            final artFile = File(entry['artPath']);
            if (await artFile.exists()) {
              artBytes = await artFile.readAsBytes();
            }
          }

          return MediaItem(
            name: entry['name'],
            path: file.path,
            duration: entry['duration'],
            size: entry['size'],
            artist: entry['artist'],
            album: entry['album'],
            albumArt: artBytes,
            artUri: entry['artPath'] != null
                ? Uri.file(entry['artPath']).toString()
                : null,
          );
        }
      }

      // Cache Miss - Extract Real Data
      return await _createAndCacheMediaItem(file, isVideo, lastModified);
    } catch (e) {
      print("Error getting media item: $e");
      // Fallback
      return MediaItem(
        name: path.basenameWithoutExtension(file.path),
        path: file.path,
        duration: "00:00",
        size: "Unknown",
        artist: isVideo ? null : "Unknown Artist",
        album: isVideo ? null : "Unknown Album",
        albumArt: null,
      );
    }
  }

  Future<MediaItem> _createAndCacheMediaItem(
    File file,
    bool isVideo,
    int lastModified,
  ) async {
    final fileName = path.basenameWithoutExtension(file.path);
    final stat = await file
        .stat(); // Size might be needed if not passed (we passed modtime)
    final fileSize = _formatFileSize(stat.size);

    Uint8List? albumArt;
    String? artist;
    String? album;
    String formattedDuration = '00:00';

    if (isVideo) {
      final videoInfo = FlutterVideoInfo();
      try {
        var info = await videoInfo.getVideoInfo(file.path);
        if (info?.duration != null) {
          formattedDuration = _formatDuration(info!.duration!.toInt());
        }
      } catch (e) {}

      // Custom Check or Generate
      if (_customThumbnails.containsKey(file.path)) {
        final f = File(_customThumbnails[file.path]!);
        if (await f.exists()) albumArt = await f.readAsBytes();
      }

      if (albumArt == null) {
        try {
          albumArt = await VideoThumbnail.thumbnailData(
            video: file.path,
            imageFormat: ImageFormat.JPEG,
            maxWidth: 200,
            quality: 50,
          );
        } catch (e) {}
      }
    } else {
      try {
        final tag = await AudioTags.read(file.path);
        if (tag?.pictures.isNotEmpty == true) {
          albumArt = tag!.pictures.first.bytes;
        }
        artist = tag?.trackArtist;
        album = tag?.album;
        if (tag?.duration != null) {
          formattedDuration = _formatDuration(tag!.duration! * 1000);
        }
      } catch (e) {}
    }

    // Save Art to Disk for Cache
    String? cachedArtPath;
    if (albumArt != null) {
      // Don't save if it's already a custom thumb path, just usage logic.
      // But for consistency let's save our own cache copy or just use the bytes?
      // Saving bytes to disk speeds up next read vs decoding video again.
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final thumbDir = Directory(path.join(appDir.path, 'thumbnails'));
        if (!await thumbDir.exists()) await thumbDir.create();

        // Use hash or filename as key
        final artFileName = '${file.path.hashCode}_v1.jpg';
        final artFile = File(path.join(thumbDir.path, artFileName));
        await artFile.writeAsBytes(albumArt);
        cachedArtPath = artFile.path;
      } catch (e) {
        print("Failed to save cached art: $e");
      }
    }

    // Update Cache Map
    _metadataCache[file.path] = {
      'lastModified': lastModified,
      'name': fileName,
      'duration': formattedDuration,
      'size': fileSize,
      'artist': artist ?? (isVideo ? null : 'Unknown Artist'),
      'album': album ?? (isVideo ? null : 'Unknown Album'),
      'artPath': cachedArtPath, // Path to stored image
    };

    return MediaItem(
      name: fileName,
      path: file.path,
      duration: formattedDuration,
      size: fileSize,
      artist: artist ?? (isVideo ? null : 'Unknown Artist'),
      album: album ?? (isVideo ? null : 'Unknown Album'),
      albumArt: albumArt,
      artUri: cachedArtPath != null ? Uri.file(cachedArtPath).toString() : null,
    );
  }

  String _formatDuration(int milliseconds) {
    if (milliseconds <= 0) return '00:00';
    final duration = Duration(milliseconds: milliseconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    } else {
      return '$twoDigitMinutes:$twoDigitSeconds';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  List<Map<String, dynamic>> getFolders() {
    final Map<String, int> folderCounts = {};

    for (final video in videos) {
      final folder = path.dirname(video.path);
      final folderName = path.basename(folder);
      if (folderName.isNotEmpty) {
        folderCounts[folder] = (folderCounts[folder] ?? 0) + 1;
      }
    }

    for (final audio in music) {
      final folder = path.dirname(audio.path);
      final folderName = path.basename(folder);
      if (folderName.isNotEmpty) {
        folderCounts[folder] = (folderCounts[folder] ?? 0) + 1;
      }
    }

    return folderCounts.entries
        .map(
          (e) => {
            'name': path.basename(e.key),
            'path': e.key,
            'count': e.value,
          },
        )
        .toList();
  }

  /// Groups music by Album name
  List<Map<String, dynamic>> getAlbums() {
    final Map<String, List<MediaItem>> albumGroups = {};

    for (var song in music) {
      final albumName = song.album ?? 'Unknown Album';
      if (!albumGroups.containsKey(albumName)) {
        albumGroups[albumName] = [];
      }
      albumGroups[albumName]!.add(song);
    }

    final sortedAlbums = albumGroups.entries.map((entry) {
      final songs = entry.value;
      final representative = songs.first;
      return {
        'name': entry.key,
        'artist': representative.artist ?? 'Unknown Artist',
        'art': representative.albumArt,
        'songCount': songs.length,
        'songs': songs,
      };
    }).toList();

    sortedAlbums.sort((a, b) {
      final nameA = a['name'] as String;
      final nameB = b['name'] as String;
      final isUnknownA =
          nameA == 'Unknown Album' ||
          (a['artist'] as String) == 'Unknown Artist';
      final isUnknownB =
          nameB == 'Unknown Album' ||
          (b['artist'] as String) == 'Unknown Artist';

      if (isUnknownA && !isUnknownB) return 1;
      if (!isUnknownA && isUnknownB) return -1;
      return nameA.toLowerCase().compareTo(nameB.toLowerCase());
    });

    return sortedAlbums;
  }
}
