import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_provider.dart';

class SettingsProvider extends ChangeNotifier {
  bool _showSubtitles = false;
  Timer? _sleepTimer;
  int? _sleepTimerDuration; // Minutes remaining

  bool get showSubtitles => _showSubtitles;
  int? get sleepTimerDuration => _sleepTimerDuration;

  Future<void> toggleSubtitles(bool value) async {
    _showSubtitles = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_subtitles', _showSubtitles);
  }

  void setSleepTimer(int? minutes, AudioProvider audioProvider) {
    _sleepTimer?.cancel();
    _sleepTimerDuration = minutes;
    notifyListeners();

    if (minutes != null) {
      _sleepTimer = Timer(Duration(minutes: minutes), () {
        // Stop audio when timer ends
        if (audioProvider.isPlaying) {
          audioProvider.pause();
        }
        _sleepTimerDuration = null;
        _sleepTimer = null;
        notifyListeners();
      });
    }
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerDuration = null;
    notifyListeners();
  }

  bool _isSongGrid = false;
  int _videoLayoutMode = 0; // 0: List, 1: Grid, 2: Large

  bool get isSongGrid => _isSongGrid;
  int get videoLayoutMode => _videoLayoutMode;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isSongGrid = prefs.getBool('is_song_grid') ?? false;
    _videoLayoutMode = prefs.getInt('video_layout_mode') ?? 0;
    _showSubtitles = prefs.getBool('show_subtitles') ?? false;
    notifyListeners();
  }

  Future<void> toggleSongView() async {
    _isSongGrid = !_isSongGrid;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_song_grid', _isSongGrid);
  }

  Future<void> setVideoLayoutMode(int mode) async {
    _videoLayoutMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('video_layout_mode', _videoLayoutMode);
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    super.dispose();
  }
}
