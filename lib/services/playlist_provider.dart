import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path_utils;
import '../models/media_item.dart';

class PlaylistProvider extends ChangeNotifier {
  final Map<String, List<MediaItem>> _playlists = {};
  final List<MediaItem> _favorites = [];

  List<String> get playlistNames => _playlists.keys.toList();
  List<MediaItem> get favorites => List.unmodifiable(_favorites);
  int get favoriteCount => _favorites.length;

  PlaylistProvider() {
    _loadData();
  }

  List<MediaItem> getPlaylistSongs(String playlistName) {
    return _playlists[playlistName] ?? [];
  }

  void createPlaylist(String name) {
    if (!_playlists.containsKey(name)) {
      _playlists[name] = [];
      _saveData();
      notifyListeners();
    }
  }

  void addToPlaylist(String playlistName, MediaItem song) {
    if (_playlists.containsKey(playlistName)) {
      if (!_playlists[playlistName]!.any((item) => item.path == song.path)) {
        _playlists[playlistName]!.add(song);
        _saveData();
        notifyListeners();
      }
    }
  }

  void removeFromPlaylist(String playlistName, MediaItem song) {
    if (_playlists.containsKey(playlistName)) {
      _playlists[playlistName]!.removeWhere((item) => item.path == song.path);
      _saveData();
      notifyListeners();
    }
  }

  void deletePlaylist(String name) {
    _playlists.remove(name);
    _saveData();
    notifyListeners();
  }

  void toggleFavorite(MediaItem song) {
    if (_favorites.any((item) => item.path == song.path)) {
      _favorites.removeWhere((item) => item.path == song.path);
    } else {
      _favorites.add(song);
    }
    _saveData();
    notifyListeners();
  }

  bool isFavorite(MediaItem song) {
    return _favorites.any((item) => item.path == song.path);
  }

  // --- Persistence Logic ---

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save Favorites (List of paths)
    final favoritePaths = _favorites.map((e) => e.path).toList();
    await prefs.setString('favorites_paths', jsonEncode(favoritePaths));

    // Save Playlists (Map Name -> List of paths)
    final Map<String, List<String>> playlistPaths = {};
    _playlists.forEach((name, items) {
      playlistPaths[name] = items.map((e) => e.path).toList();
    });
    await prefs.setString('playlists_map', jsonEncode(playlistPaths));
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Favorites
    final favString = prefs.getString('favorites_paths');
    if (favString != null) {
      final List<dynamic> paths = jsonDecode(favString);
      _favorites.clear();
      for (final p in paths) {
        _favorites.add(_createTempItem(p.toString()));
      }
    }

    // Load Playlists
    final plString = prefs.getString('playlists_map');
    if (plString != null) {
      final Map<String, dynamic> plMap = jsonDecode(plString);
      _playlists.clear();
      plMap.forEach((name, paths) {
        final List<dynamic> pathList = paths;
        _playlists[name] = pathList
            .map((p) => _createTempItem(p.toString()))
            .toList();
      });
    }
    notifyListeners();
  }

  /// Create a temporary MediaItem from a path (used before full metadata is available)
  MediaItem _createTempItem(String path) {
    return MediaItem(
      name: path_utils.basenameWithoutExtension(path),
      path: path,
      duration: '00:00',
      size: '0 B',
      artist: 'Loading...',
      album: 'Unknown',
    );
  }

  /// Called after MediaService loads all songs.
  /// Replaces temporary items with full-metadata items.
  void syncWithLibrary(List<MediaItem> library) {
    final Map<String, MediaItem> libraryMap = {
      for (var item in library) item.path: item,
    };

    // Sync Favorites
    for (int i = 0; i < _favorites.length; i++) {
      if (libraryMap.containsKey(_favorites[i].path)) {
        _favorites[i] = libraryMap[_favorites[i].path]!;
      }
    }

    // Sync Playlists
    _playlists.forEach((name, items) {
      for (int i = 0; i < items.length; i++) {
        if (libraryMap.containsKey(items[i].path)) {
          items[i] = libraryMap[items[i].path]!;
        }
      }
    });

    notifyListeners();
  }
}
