import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/media_item.dart' as model;
// Note: AudioService's MediaItem might conflict if we import audio_service.
// just_audio_background exports MediaItem from audio_service_platform_interface.
// So we use it from there.

class AudioProvider extends ChangeNotifier {
  late AudioPlayer _audioPlayer;

  bool _isPlaying = false;
  bool _isShuffling = false;
  bool _isRepeating = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  List<model.MediaItem> _playlist = [];
  int _currentIndex = -1;
  double _volume = 1.0;

  AudioProvider() {
    _initAudioPlayer();
  }

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isShuffling => _isShuffling;
  bool get isRepeating => _isRepeating;
  Duration get duration => _duration;
  Duration get position => _position;
  model.MediaItem? get currentAudio =>
      (_currentIndex != -1 && _currentIndex < _playlist.length)
      ? _playlist[_currentIndex]
      : null;
  List<model.MediaItem> get playlist => _playlist;
  double get volume => _volume;

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer();

    // Listen to playback state
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      _isPlaying = isPlaying && processingState != ProcessingState.completed;
      notifyListeners();
    });

    // Listen to position
    _audioPlayer.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    // Listen to duration
    _audioPlayer.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });

    // Listen to current item index
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null) {
        _currentIndex = index;
        notifyListeners();
      }
    });

    // Listen to shuffle/loop mode to update UI state
    _audioPlayer.shuffleModeEnabledStream.listen((enabled) {
      _isShuffling = enabled;
      notifyListeners();
    });

    _audioPlayer.loopModeStream.listen((loopMode) {
      _isRepeating = loopMode == LoopMode.one;
      notifyListeners();
    });
  }

  Future<void> play(
    model.MediaItem audio,
    List<model.MediaItem> playlist,
  ) async {
    _playlist = playlist;

    // Find index of the selected audio
    final initialIndex = playlist.indexOf(audio);
    if (initialIndex == -1) return;

    // Create AudioSources with Metadata
    final audioSources = playlist.map((item) {
      return AudioSource.file(
        item.path,
        tag: MediaItem(
          id: item.path,
          album: item.album ?? "Unknown Album",
          title: item.name,
          artist: item.artist ?? "Unknown Artist",
          artUri: item.artUri != null ? Uri.parse(item.artUri!) : null,
        ),
      );
    }).toList();

    try {
      await _audioPlayer.setAudioSource(
        ConcatenatingAudioSource(children: audioSources),
        initialIndex: initialIndex,
      );
      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Error loading playlist: $e");
    }
  }

  // Helper for starting playback from search/lists
  Future<void> setPlaylist(List<model.MediaItem> newPlaylist, int index) async {
    await play(newPlaylist[index], newPlaylist);
  }

  // TODO: Fix Album Art URI.
  // We need a path. Models might have art bytes but not path.
  // We should rely on MediaService to provide paths or cache.

  Future<void> resume() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> playNext() async {
    await _audioPlayer.seekToNext();
  }

  Future<void> playPrevious() async {
    await _audioPlayer.seekToPrevious();
  }

  Future<void> toggleShuffle() async {
    _isShuffling = !_isShuffling;
    await _audioPlayer.setShuffleModeEnabled(_isShuffling);
  }

  Future<void> toggleRepeat() async {
    // Check current loop mode.
    // Logic: If off -> One. If One -> All? Or just Off/One toggle.
    // UI usually toggles Repeat One vs Repeat Off for single tap?
    // Or Repeat Off -> Repeat All -> Repeat One.
    // User code had boolean `isRepeating`.
    // Let's toggle between One and Off/All.
    if (_isRepeating) {
      await _audioPlayer.setLoopMode(LoopMode.off); // or all
    } else {
      await _audioPlayer.setLoopMode(LoopMode.one);
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(_volume);
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
