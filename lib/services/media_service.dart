// ==================== lib/services/media_service.dart ====================
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import '../models/media_item.dart';
import 'package:metadata_god/metadata_god.dart';
import 'dart:typed_data';

class MediaService {
  List<MediaItem> videos = [];
  List<MediaItem> music = [];

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
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
    ];

    for (final dirPath in directories) {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        await _scanDirectory(dir);
      }
    }
  }

  Future<void> _scanDirectory(Directory dir) async {
    try {
      await for (final entity in dir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File) {
          final ext = path.extension(entity.path).toLowerCase();

          if (_isVideoFile(ext)) {
            videos.add(await _createMediaItem(entity, isVideo: true));
          } else if (_isAudioFile(ext)) {
            music.add(await _createMediaItem(entity, isVideo: false));
          }
        }
      }
    } catch (e) {
      print('Error scanning directory ${dir.path}: $e');
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

    if (!isVideo) {
      try {
        final metadata = await MetadataGod.getMetadata(file.path);
        albumArt = metadata?.picture?.data;
        artist = metadata?.artist;
        album = metadata?.album;
      } catch (e) {
        print('Error extracting metadata for ${file.path}: $e');
      }
    }

    return MediaItem(
      name: fileName,
      path: file.path,
      duration: '00:00',
      size: fileSize,
      artist: artist ?? (isVideo ? null : 'Unknown Artist'),
      album: album ?? (isVideo ? null : 'Unknown Album'),
      albumArt: albumArt,
    );
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
}
