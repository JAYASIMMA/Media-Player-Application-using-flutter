import 'package:flutter/material.dart';
import '../models/media_item.dart';

class PlaylistProvider extends ChangeNotifier {
  final Map<String, List<MediaItem>> _playlists = {};

  List<String> get playlistNames => _playlists.keys.toList();

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
}
