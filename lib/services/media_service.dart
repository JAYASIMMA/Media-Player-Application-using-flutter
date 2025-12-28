// ==================== lib/services/media_service.dart ====================
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import '../models/media_item.dart';

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
    
    // Add sample data for demonstration
    _addSampleData();
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
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
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
    return ['.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv', '.3gp', '.webm', '.m4v'].contains(ext);
  }

  bool _isAudioFile(String ext) {
    return ['.mp3', '.m4a', '.wav', '.flac', '.aac', '.ogg', '.wma', '.opus'].contains(ext);
  }

  Future<MediaItem> _createMediaItem(File file, {required bool isVideo}) async {
    final stat = await file.stat();
    final fileName = path.basenameWithoutExtension(file.path);
    final fileSize = _formatFileSize(stat.size);

    return MediaItem(
      name: fileName,
      path: file.path,
      duration: '00:00',
      size: fileSize,
      artist: isVideo ? null : 'Unknown Artist',
      album: isVideo ? null : 'Unknown Album',
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

  void _addSampleData() {
    // Sample videos
    videos.addAll([
      MediaItem(
        name: 'Sample Video 1',
        path: '/sample/path/video1.mp4',
        duration: '05:24',
        size: '125.5 MB',
      ),
      MediaItem(
        name: 'Movie Trailer',
        path: '/sample/path/trailer.mp4',
        duration: '02:30',
        size: '85.3 MB',
      ),
      MediaItem(
        name: 'Tutorial Video',
        path: '/sample/path/tutorial.mkv',
        duration: '18:42',
        size: '512.8 MB',
      ),
      MediaItem(
        name: 'Vacation 2024',
        path: '/sample/path/vacation.mp4',
        duration: '12:15',
        size: '256.3 MB',
      ),
    ]);

    // Sample music
    music.addAll([
      MediaItem(
        name: 'Summer Breeze',
        path: '/sample/path/summer.mp3',
        duration: '03:45',
        size: '5.2 MB',
        artist: 'The Artists',
        album: 'Summer Collection',
      ),
      MediaItem(
        name: 'Night Drive',
        path: '/sample/path/night.mp3',
        duration: '04:12',
        size: '6.1 MB',
        artist: 'Midnight Band',
        album: 'City Lights',
      ),
      MediaItem(
        name: 'Acoustic Dreams',
        path: '/sample/path/acoustic.mp3',
        duration: '03:28',
        size: '4.8 MB',
        artist: 'Guitar Masters',
        album: 'Unplugged Sessions',
      ),
      MediaItem(
        name: 'Electric Soul',
        path: '/sample/path/electric.mp3',
        duration: '05:15',
        size: '7.3 MB',
        artist: 'DJ Beats',
        album: 'Electronic Vibes',
      ),
      MediaItem(
        name: 'Classical Melody',
        path: '/sample/path/classical.mp3',
        duration: '06:32',
        size: '9.1 MB',
        artist: 'Orchestra',
        album: 'Timeless Classics',
      ),
    ]);
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
        .map((e) => {
              'name': path.basename(e.key),
              'path': e.key,
              'count': e.value,
            })
        .toList();
  }
}