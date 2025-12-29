import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import '../models/media_item.dart' as local; // Alias to avoid conflict
import 'audio_handler.dart';

class AudioProvider extends ChangeNotifier {
  final MyAudioHandler _audioHandler;

  bool _isPlaying = false;
  bool _isShuffling = false;
  bool _isRepeating = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  local.MediaItem? _currentAudio;
  List<local.MediaItem> _playlist = [];
  int _currentIndex = -1;
  double _volume = 1.0;

  AudioProvider(this._audioHandler) {
    _initAudioHandlerListeners();
  }

  void _initAudioHandlerListeners() {
    _audioHandler.playbackState.listen((state) {
      final playing = state.playing;
      final processingState = state.processingState;

      if (_isPlaying != playing) {
        _isPlaying = playing;
        notifyListeners();
      }

      if (processingState == AudioProcessingState.completed) {
        if (_isRepeating) {
          play(_currentAudio!, _playlist);
        } else {
          playNext();
        }
      }

      _position = state.position;
      notifyListeners();
    });

    _audioHandler.mediaItem.listen((item) {
      if (item != null) {
        _duration = item.duration ?? Duration.zero;
        notifyListeners();
      }
    });

    // Position stream for smoother UI updates if handler broadcasts it?
    // AudioService updates position in playbackState, but usually we need a ticker or periodic check in UI.
    // Ideally, UI uses StreamBuilder on _audioHandler.playbackState
  }

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isShuffling => _isShuffling;
  bool get isRepeating => _isRepeating;
  Duration get duration => _duration;
  Duration get position => _position;
  local.MediaItem? get currentAudio => _currentAudio;
  List<local.MediaItem> get playlist => _playlist;
  double get volume => _volume;

  Future<void> play(
    local.MediaItem audio,
    List<local.MediaItem> playlist,
  ) async {
    _currentAudio = audio;
    _playlist = playlist;
    _currentIndex = _playlist.indexOf(audio);
    _position = Duration.zero;

    final mediaItem = MediaItem(
      id: audio.path,
      album: audio.album ?? "Unknown Album",
      title: audio.name,
      artist: audio.artist ?? "Unknown Artist",
      duration: null, // Initial unknown, will be updated
      artUri:
          null, // Can't easily pass memory image bytes to URI here without saving to file.
      // For lock screen image, AudioService needs a file URI or URL.
      // Complex to handle in-memory bytes. For now, we skip art or use placeholder.
    );

    // If implementing Queue:
    // _audioHandler.updateQueue(playlist.map(...).toList());

    await _audioHandler.playMediaItem(mediaItem);
    notifyListeners();
  }

  Future<void> resume() async => await _audioHandler.play();
  Future<void> pause() async => await _audioHandler.pause();

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
      await _audioHandler.seek(position);

  Future<void> playNext() async {
    if (_playlist.isEmpty || _currentIndex == -1) return;
    if (_currentIndex < _playlist.length - 1) {
      play(_playlist[_currentIndex + 1], _playlist);
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
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeating = !_isRepeating;
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    // AudioService/Handler doesn't strictly have setVolume in base,
    // but we can add Custom Action or keep using AudioPlayer ref inside handler if exposed
    // Or just store volume locally. The underlying player in handler sets volume.
    // Ideally we add 'setVolume' to MyAudioHandler.
    // For now we will assume volume is handled by system buttons or we ignore it in provider for background?
    // User requested "song playing in background in lock screen".
    notifyListeners();
  }
}
