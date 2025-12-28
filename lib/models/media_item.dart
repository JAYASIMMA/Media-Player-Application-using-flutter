// ==================== lib/models/media_item.dart ====================
import 'dart:typed_data';

class MediaItem {
  final String name;
  final String path;
  final String duration;
  final String size;
  final Uint8List? thumbnail;
  final Uint8List? albumArt;
  final String? artist;
  final String? album;

  MediaItem({
    required this.name,
    required this.path,
    required this.duration,
    required this.size,
    this.thumbnail,
    this.albumArt,
    this.artist,
    this.album,
  });
}