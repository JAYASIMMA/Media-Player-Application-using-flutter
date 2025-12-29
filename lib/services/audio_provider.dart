import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/media_item.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPlaying = false;
  bool _isShuffling = false;
  bool _isRepeating = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  MediaItem? _currentAudio;
  List<MediaItem> _playlist = [];
  int _currentIndex = -1;

  AudioProvider() {
    _initAudioPlayer();
  }

  bool get isPlaying => _isPlaying;
  bool get isShuffling => _isShuffling;
  bool get isRepeating => _isRepeating;
  Duration get duration => _duration;
  Duration get position => _position;
  MediaItem? get currentAudio => _currentAudio;
  List<MediaItem> get playlist => _playlist;

  void _initAudioPlayer() {
    // Configure for background playback
    _audioPlayer.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {
            AVAudioSessionOptions.defaultToSpeaker,
            AVAudioSessionOptions.allowAirPlay,
          },
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );

    _audioPlayer.onDurationChanged.listen((duration) {
      _duration = duration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _position = position;
      notifyListeners();
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (_isRepeating) {
        play(_currentAudio!, _playlist); // Replay current
      } else {
        playNext();
      }
    });
  }

  Future<void> play(MediaItem audio, List<MediaItem> playlist) async {
    _currentAudio = audio;
    _playlist = playlist;
    _currentIndex = _playlist.indexOf(audio);

    // Reset state if new song
    _position = Duration.zero;

    try {
      await _audioPlayer.stop(); // Stop potential previous
      await _audioPlayer.play(DeviceFileSource(audio.path));
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
    notifyListeners();
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      if (_currentAudio != null) {
        await resume();
      } else if (_playlist.isNotEmpty) {
        // Play first if nothing is current but playlist exists
        play(_playlist.first, _playlist);
      }
    }
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> playNext() async {
    if (_playlist.isEmpty || _currentIndex == -1) return;

    if (_currentIndex < _playlist.length - 1) {
      play(_playlist[_currentIndex + 1], _playlist);
    } else {
      // Loop back to start or stop? Let's stop for now unless repeat is global
      // If we want infinite loop:
      // play(_playlist.first, _playlist);
    }
  }

  Future<void> playPrevious() async {
    if (_playlist.isEmpty || _currentIndex == -1) return;

    if (_position.inSeconds > 3) {
      seek(Duration.zero);
    } else if (_currentIndex > 0) {
      play(_playlist[_currentIndex - 1], _playlist);
    }
  }

  void toggleShuffle() {
    _isShuffling = !_isShuffling;
    // Implementation of shuffle logic would go here (reordering playlist or random index)
    // For now just toggling the flag
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeating = !_isRepeating;
    notifyListeners();
  }
}
