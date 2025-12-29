import 'package:flutter/material.dart';
import 'dart:async';
import 'audio_provider.dart';

class SettingsProvider extends ChangeNotifier {
  bool _showSubtitles = false;
  Timer? _sleepTimer;
  int? _sleepTimerDuration; // Minutes remaining

  bool get showSubtitles => _showSubtitles;
  int? get sleepTimerDuration => _sleepTimerDuration;

  void toggleSubtitles(bool value) {
    _showSubtitles = value;
    notifyListeners();
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

  @override
  void dispose() {
    _sleepTimer?.cancel();
    super.dispose();
  }
}
