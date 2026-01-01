// ==================== lib/models/media_item.dart ====================
import 'dart:typed_data';

class MediaItem {
  final String name;
  final String path;
  final String duration;
  final String size;
  final Uint8List? thumbnail;
  final Uint8List? albumArt;
  final String? artUri;
  final String? artist;
  final String? album;

  MediaItem({
    required this.name,
    required this.path,
    required this.duration,
    required this.size,
    this.thumbnail,
    this.albumArt,
    this.artUri,
    this.artist,
    this.album,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MediaItem && other.path == path;
  }

  @override
  int get hashCode => path.hashCode;

  MediaItem copyWith({
    String? name,
    String? path,
    String? duration,
    String? size,
    Uint8List? albumArt,
    String? artUri,
    String? artist,
    String? album,
  }) {
    return MediaItem(
      name: name ?? this.name,
      path: path ?? this.path,
      duration: duration ?? this.duration,
      size: size ?? this.size,
      albumArt: albumArt ?? this.albumArt,
      artUri: artUri ?? this.artUri,
      artist: artist ?? this.artist,
      album: album ?? this.album,
    );
  }
}
