import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/media_item.dart';
import '../services/audio_provider.dart';

class AudioPlayerPage extends StatefulWidget {
  final MediaItem audio;
  final List<MediaItem> playlist;

  const AudioPlayerPage({Key? key, required this.audio, required this.playlist})
    : super(key: key);

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotateController;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      // Play the selected audio when page opens
      Provider.of<AudioProvider>(
        context,
        listen: false,
      ).play(widget.audio, widget.playlist);
      _isInit = true;
    }
  }

  @override
  void dispose() {
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
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        final currentAudio = audioProvider.currentAudio ?? widget.audio;
        final isPlaying = audioProvider.isPlaying;
        final position = audioProvider.position;
        final duration = audioProvider.duration;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Now Playing'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.playlist_play),
                onPressed: () => _showPlaylist(context, audioProvider),
              ),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
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
                            angle: isPlaying
                                ? _rotateController.value * 2 * 3.14159
                                : 0,
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
                                child: currentAudio.albumArt != null
                                    ? Image.memory(
                                        currentAudio.albumArt!,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.blue.shade300,
                                              Colors.purple.shade300,
                                            ],
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
                              currentAudio.name,
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
                              currentAudio.artist ?? 'Unknown Artist',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (currentAudio.album != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                currentAudio.album!,
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
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14,
                          ),
                        ),
                        child: Slider(
                          value: position.inSeconds.toDouble().clamp(
                            0.0,
                            duration.inSeconds.toDouble(),
                          ),
                          max: duration.inSeconds.toDouble() > 0
                              ? duration.inSeconds.toDouble()
                              : 1.0,
                          onChanged: (value) {
                            audioProvider.seek(
                              Duration(seconds: value.toInt()),
                            );
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
                              _formatDuration(position),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
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
                              audioProvider.isShuffling
                                  ? Icons.shuffle_on_outlined
                                  : Icons.shuffle,
                              color: audioProvider.isShuffling
                                  ? Colors.blue
                                  : null,
                            ),
                            iconSize: 28,
                            onPressed: audioProvider.toggleShuffle,
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_previous),
                            iconSize: 45,
                            onPressed: audioProvider.playPrevious,
                          ),
                          Container(
                            width: 70,
                            height: 70,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                              ),
                              iconSize: 40,
                              color: Colors.white,
                              onPressed: audioProvider.togglePlayPause,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next),
                            iconSize: 45,
                            onPressed: audioProvider.playNext,
                          ),
                          IconButton(
                            icon: Icon(
                              audioProvider.isRepeating
                                  ? Icons.repeat_one
                                  : Icons.repeat,
                              color: audioProvider.isRepeating
                                  ? Colors.blue
                                  : null,
                            ),
                            iconSize: 28,
                            onPressed: audioProvider.toggleRepeat,
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
      },
    );
  }

  void _showPlaylist(BuildContext context, AudioProvider audioProvider) {
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
                  final isPlaying = item == audioProvider.currentAudio;
                  return ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade300,
                            Colors.purple.shade300,
                          ],
                        ),
                      ),
                      child: item.albumArt != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                item.albumArt!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.music_note, color: Colors.white),
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        color: isPlaying ? Colors.blue : null,
                        fontWeight: isPlaying
                            ? FontWeight.bold
                            : FontWeight.normal,
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
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                    onTap: () {
                      Navigator.pop(context);
                      audioProvider.play(item, widget.playlist);
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
