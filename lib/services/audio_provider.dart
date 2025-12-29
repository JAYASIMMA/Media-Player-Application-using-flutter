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
    _playNextAutomatically = true; // Auto-play next song
  }

  bool _playNextAutomatically = true;

  bool get isPlaying => _isPlaying;
  bool get isShuffling => _isShuffling;
  bool get isRepeating => _isRepeating;
  Duration get duration => _duration;
  Duration get position => _position;
  MediaItem? get currentAudio => _currentAudio;
  List<MediaItem> get playlist => _playlist;

  void _initAudioPlayer() {
    // Enable background playback
    final AudioContext audioContext = AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {
          AVAudioSessionOptions.defaultToSpeaker,
          AVAudioSessionOptions.allowBluetooth,
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
    );
    AudioPlayer.global.setAudioContext(audioContext);

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
        if (_currentAudio != null && _playlist.isNotEmpty) {
          play(_currentAudio!, _playlist);
        }
      } else if (_playNextAutomatically) {
        playNext();
      }
    });
  }

  Future<void> play(MediaItem audio, List<MediaItem> playlist) async {
    _currentAudio = audio;
    _playlist = playlist; // This updates the working playlist.
    // If shuffle is ON, we should arguably effectively shuffle the incoming playlist
    // but the UI usually passes the raw album list.
    // For simplicity, we keep the passed list as the "source of truth".

    _currentIndex = _playlist.indexOf(audio);
    _position = Duration.zero;

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(DeviceFileSource(audio.path));
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
    notifyListeners();
  }

  Future<void> resume() async => await _audioPlayer.resume();
  Future<void> pause() async => await _audioPlayer.pause();

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      if (_currentAudio != null) {
        await resume();
      } else if (_playlist.isNotEmpty) {
        play(_playlist.first, _playlist);
      }
    }
  }

  Future<void> seek(Duration position) async =>
      await _audioPlayer.seek(position);

  Future<void> playNext() async {
    if (_playlist.isEmpty) return;

    if (_isShuffling) {
      // Pick random index
      // Simple logic: just pick random from playlist size, ensuring it's not current if possible
      final random = List.generate(_playlist.length, (index) => index);
      random.shuffle();
      int nextIndex = random.first;
      if (nextIndex == _currentIndex && _playlist.length > 1) {
        nextIndex = random[1];
      }
      play(_playlist[nextIndex], _playlist);
    } else {
      // Normal sequential
      if (_currentIndex < _playlist.length - 1) {
        play(_playlist[_currentIndex + 1], _playlist);
      } else {
        // Stop at end of list
      }
    }
  }

  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;

    if (_position.inSeconds > 3) {
      seek(Duration.zero);
    } else {
      // Ideally we track history for shuffle, but standard prev is fine too
      if (_currentIndex > 0) {
        play(_playlist[_currentIndex - 1], _playlist);
      }
    }
  }

  void toggleShuffle() {
    _isShuffling = !_isShuffling;
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeating = !_isRepeating;
    notifyListeners();
  }
}
