// ==================== lib/services/media_service.dart ====================
import 'dart:io';
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

  MediaService();

  Future<void> _loadCustomThumbnails() async {
    final prefs = await SharedPreferences.getInstance();
    // Keys format: "thumb_video_path" -> "thumbnail_file_path"
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('thumb_')) {
        final videoPath = key.substring(6); // Remove 'thumb_' prefix
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
      final thumbFileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
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

        // Update in-memory list
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
      // For Android 11+ (API 30+)
      if (await Permission.manageExternalStorage.status.isDenied) {
        await Permission.manageExternalStorage.request();
      }

      if (await Permission.manageExternalStorage.status.isGranted) {
        return true;
      }

      // For older Android versions
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

    // Phase 1: Rapid file collection
    for (final dirPath in directories) {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        await _collectFiles(dir, allFiles);
      }
    }

    // Phase 2: Processing in batches
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

    // Process concurrently (batches of 10 to avoid OOM or Channel overloading)
    // We update the main lists as we go or at the end.
    // Ideally at the end to prevent partial state, but for speed perception, maybe incrementally?
    // Let's do batches and add them.

    await _processBatch(videoFiles, true);
    await _processBatch(audioFiles, false);
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
      print('Error collecting files from ${dir.path}: $e');
    }
  }

  Future<void> _processBatch(List<File> files, bool isVideo) async {
    const int batchSize = 10;
    for (var i = 0; i < files.length; i += batchSize) {
      final end = (i + batchSize < files.length) ? i + batchSize : files.length;
      final batch = files.sublist(i, end);

      final results = await Future.wait(
        batch.map((file) => _createMediaItem(file, isVideo: isVideo)),
      );

      if (isVideo) {
        videos.addAll(results);
      } else {
        music.addAll(results);
      }
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

  Future<MediaItem> _createMediaItem(File file, {required bool isVideo}) async {
    final stat = await file.stat();
    final fileName = path.basenameWithoutExtension(file.path);
    final fileSize = _formatFileSize(stat.size);

    Uint8List? albumArt;
    String? artist;
    String? album;

    String formattedDuration = '00:00';
    final videoInfo = FlutterVideoInfo();

    if (isVideo) {
      try {
        var info = await videoInfo.getVideoInfo(file.path);
        if (info?.duration != null) {
          // duration from flutter_video_info is in milliseconds
          formattedDuration = _formatDuration(info!.duration!.toInt());
        }
      } catch (e) {
        print('Error extracting video metadata for ${file.path}: $e');
      }

      // Generate Thumbnail
      if (_customThumbnails.containsKey(file.path)) {
        try {
          final thumbFile = File(_customThumbnails[file.path]!);
          if (await thumbFile.exists()) {
            albumArt = await thumbFile.readAsBytes();
          } else {
            // Fallback if custom file deleted
            final uint8list = await VideoThumbnail.thumbnailData(
              video: file.path,
              imageFormat: ImageFormat.JPEG,
              maxWidth: 200,
              quality: 50,
            );
            albumArt = uint8list;
          }
        } catch (e) {
          print("Error creating media item with custom thumb: $e");
        }
      } else {
        try {
          final uint8list = await VideoThumbnail.thumbnailData(
            video: file.path,
            imageFormat: ImageFormat.JPEG,
            maxWidth: 200, // Specify the width of the thumbnail
            quality: 50,
          );
          albumArt = uint8list;
        } catch (e) {
          print('Error generating thumbnail for ${file.path}: $e');
        }
      }
    } else {
      try {
        final tag = await AudioTags.read(file.path);
        // The first picture is usually the cover art
        if (tag?.pictures.isNotEmpty == true) {
          albumArt = tag!.pictures.first.bytes;
        }
        artist = tag?.trackArtist;
        album = tag?.album;
        if (tag?.duration != null) {
          // duration from audiotags is usually in seconds
          formattedDuration = _formatDuration(tag!.duration! * 1000);
        }
      } catch (e) {
        print('Error extracting metadata for ${file.path}: $e');
      }
    }

    return MediaItem(
      name: fileName,
      path: file.path,
      duration: formattedDuration,
      size: fileSize,
      artist: artist ?? (isVideo ? null : 'Unknown Artist'),
      album: album ?? (isVideo ? null : 'Unknown Album'),
      albumArt: albumArt,
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
