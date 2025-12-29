import 'package:flutter/material.dart';
import '../models/media_item.dart';

class PlaylistProvider extends ChangeNotifier {
  final Map<String, List<MediaItem>> _playlists = {};

  final List<MediaItem> _favorites = [];

  List<String> get playlistNames => _playlists.keys.toList();
  List<MediaItem> get favorites => List.unmodifiable(_favorites);
  int get favoriteCount => _favorites.length;

  List<MediaItem> getPlaylistSongs(String playlistName) {
    return _playlists[playlistName] ?? [];
  }

  void createPlaylist(String name) {
    if (!_playlists.containsKey(name)) {
      _playlists[name] = [];
      notifyListeners();
    }
  }

  void addToPlaylist(String playlistName, MediaItem song) {
    if (_playlists.containsKey(playlistName)) {
      _playlists[playlistName]!.add(song);
      notifyListeners();
    }
  }

  void removeFromPlaylist(String playlistName, MediaItem song) {
    if (_playlists.containsKey(playlistName)) {
      _playlists[playlistName]!.remove(song);
      notifyListeners();
    }
  }

  void deletePlaylist(String name) {
    _playlists.remove(name);
    notifyListeners();
  }

  void toggleFavorite(MediaItem song) {
    if (_favorites.any((item) => item.path == song.path)) {
      _favorites.removeWhere((item) => item.path == song.path);
    } else {
      _favorites.add(song);
    }
    notifyListeners();
  }

  bool isFavorite(MediaItem song) {
    return _favorites.any((item) => item.path == song.path);
  }
}
