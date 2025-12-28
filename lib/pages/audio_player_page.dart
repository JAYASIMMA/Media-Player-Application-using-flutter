// ==================== lib/pages/audio_player_page.dart ====================
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import '../models/media_item.dart';

class AudioPlayerPage extends StatefulWidget {
  final MediaItem audio;
  final List<MediaItem> playlist;

  const AudioPlayerPage({
    Key? key,
    required this.audio,
    required this.playlist,
  }) : super(key: key);

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isShuffling = false;
  bool _isRepeating = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int _currentIndex = 0;
  late MediaItem _currentAudio;
  
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _currentAudio = widget.audio;
    _currentIndex = widget.playlist.indexOf(widget.audio);
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _initializeAudio();
  }

  void _initializeAudio() {
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _duration = duration);
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) setState(() => _position = position);
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (_isRepeating) {
        _playAudio();
      } else {
        _playNext();
      }
    });

    _playAudio();
  }

  void _playAudio() async {
    try {
      await _audioPlayer.play(DeviceFileSource(_currentAudio.path));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.resume();
    }
  }

  void _playNext() {
    if (_currentIndex < widget.playlist.length - 1) {
      setState(() {
        _currentIndex++;
        _currentAudio = widget.playlist[_currentIndex];
        _position = Duration.zero;
      });
      _audioPlayer.stop();
      _playAudio();
    }
  }

  void _playPrevious() {
    if (_position.inSeconds > 3) {
      _audioPlayer.seek(Duration.zero);
    } else if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _currentAudio = widget.playlist[_currentIndex];
        _position = Duration.zero;
      });
      _audioPlayer.stop();
      _playAudio();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_play),
            onPressed: _showPlaylist,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Album Art
                  AnimatedBuilder(
                    animation: _rotateController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _isPlaying ? _rotateController.value * 2 * 3.14159 : 0,
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _currentAudio.albumArt != null
                                ? Image.memory(_currentAudio.albumArt!, fit: BoxFit.cover)
                                : Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.blue.shade300, Colors.purple.shade300],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.music_note,
                                      size: 120,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 50),
                  
                  // Song Info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Text(
                          _currentAudio.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentAudio.artist ?? 'Unknown Artist',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_currentAudio.album != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _currentAudio.album!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Controls Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Progress Bar
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                    ),
                    child: Slider(
                      value: _position.inSeconds.toDouble(),
                      max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
                      onChanged: (value) {
                        _audioPlayer.seek(Duration(seconds: value.toInt()));
                      },
                      activeColor: Colors.blue,
                    ),
                  ),
                  
                  // Time Labels
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_position),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Playback Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isShuffling ? Icons.shuffle_on_outlined : Icons.shuffle,
                          color: _isShuffling ? Colors.blue : null,
                        ),
                        iconSize: 28,
                        onPressed: () {
                          setState(() => _isShuffling = !_isShuffling);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 45,
                        onPressed: _playPrevious,
                      ),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                          iconSize: 40,
                          color: Colors.white,
                          onPressed: _togglePlayPause,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        iconSize: 45,
                        onPressed: _playNext,
                      ),
                      IconButton(
                        icon: Icon(
                          _isRepeating ? Icons.repeat_one : Icons.repeat,
                          color: _isRepeating ? Colors.blue : null,
                        ),
                        iconSize: 28,
                        onPressed: () {
                          setState(() => _isRepeating = !_isRepeating);
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaylist() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text(
                    'Playlist',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.playlist.length} songs',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: widget.playlist.length,
                itemBuilder: (context, index) {
                  final item = widget.playlist[index];
                  final isPlaying = index == _currentIndex;
                  return ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade300, Colors.purple.shade300],
                        ),
                      ),
                      child: item.albumArt != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(item.albumArt!, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.music_note, color: Colors.white),
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        color: isPlaying ? Colors.blue : null,
                        fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      item.artist ?? 'Unknown Artist',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: isPlaying
                        ? const Icon(Icons.equalizer, color: Colors.blue)
                        : Text(
                            item.duration,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentIndex = index;
                        _currentAudio = widget.playlist[index];
                        _position = Duration.zero;
                      });
                      _audioPlayer.stop();
                      _playAudio();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
