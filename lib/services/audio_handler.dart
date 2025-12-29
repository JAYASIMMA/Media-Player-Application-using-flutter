import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();

  Duration _currentPosition = Duration.zero;

  MyAudioHandler() {
    _init();
  }

  void _init() {
    // Propagate playback state changes
    _player.onPlayerStateChanged.listen((state) {
      _broadcastState();
    });

    // Propagate position changes (optional, can be spammy)
    _player.onPositionChanged.listen((position) {
      _currentPosition = position;
      _broadcastState();
    });

    _player.onDurationChanged.listen((duration) {
      _broadcastState();
    });

    _player.onPlayerComplete.listen((event) {
      // Loop or Stop handled by Provider logic, but here we just update state
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.completed,
        ),
      );
    });
  }

  void _broadcastState() {
    final playing = _player.state == PlayerState.playing;

    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0, 1, 2],
        playing: playing,
        processingState: AudioProcessingState.ready,
        updatePosition: _currentPosition,
        bufferedPosition: _currentPosition,
        speed: 1.0,
        queueIndex: 0, // Should be updated if queue is supported
      ),
    );
  }

  @override
  Future<void> play() => _player.resume();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  Future<void> playMediaItem(MediaItem item) async {
    mediaItem.add(item);
    try {
      await _player.play(DeviceFileSource(item.id)); // Assuming ID is path
    } catch (e) {
      // Error handling
    }
  }
}
