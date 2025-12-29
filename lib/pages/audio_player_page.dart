import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/media_item.dart';
import '../services/audio_provider.dart';
import '../services/playlist_provider.dart';

class AudioPlayerPage extends StatefulWidget {
  final MediaItem audio;
  final List<MediaItem> playlist;
  final bool autoplay;

  const AudioPlayerPage({
    Key? key,
    required this.audio,
    required this.playlist,
    this.autoplay = true,
  }) : super(key: key);

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
      if (widget.autoplay) {
        Provider.of<AudioProvider>(
          context,
          listen: false,
        ).play(widget.audio, widget.playlist);
      }
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

  void _addToPlaylist(BuildContext context, MediaItem song) {
    showDialog(
      context: context,
      builder: (context) {
        final playlistProvider = Provider.of<PlaylistProvider>(
          context,
          listen: false,
        );
        final playlists = playlistProvider.playlistNames;
        final TextEditingController _controller = TextEditingController();

        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Add to Playlist',
            style: GoogleFonts.ibmPlexSerif(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'New Playlist Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (playlists.isNotEmpty) ...[
                const Divider(),
                SizedBox(
                  height: 150,
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final name = playlists[index];
                      return ListTile(
                        title: Text(name, style: GoogleFonts.ibmPlexSerif()),
                        onTap: () {
                          playlistProvider.addToPlaylist(name, song);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added to $name')),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final newName = _controller.text.trim();
                if (newName.isNotEmpty) {
                  playlistProvider.createPlaylist(newName);
                  playlistProvider.addToPlaylist(newName, song);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Created and added to $newName')),
                  );
                }
              },
              child: Text(
                "CREATE",
                style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        final currentAudio = audioProvider.currentAudio ?? widget.audio;
        final isPlaying = audioProvider.isPlaying;
        final position = audioProvider.position;
        final duration = audioProvider.duration;

        // Control rotation
        if (isPlaying && !_rotateController.isAnimating) {
          _rotateController.repeat();
        } else if (!isPlaying && _rotateController.isAnimating) {
          _rotateController.stop();
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'NOTHING ',
                          style: GoogleFonts.ibmPlexSerif(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            letterSpacing: 2,
                          ),
                        ),
                        TextSpan(
                          text: 'PLAYER',
                          style: GoogleFonts.ibmPlexSerif(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 2,
                    width: 40,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                padding: const EdgeInsets.only(right: 24),
                icon: const Icon(Icons.expand_more),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: GestureDetector(
            onVerticalDragUpdate: (details) {
              // Right side of screen only
              if (details.globalPosition.dx >
                  MediaQuery.of(context).size.width / 2) {
                // Drag UP (negative dy) -> Increase volume
                // Drag DOWN (positive dy) -> Decrease volume
                // Sensitivity factor: 0.01 per pixel
                final sensitivity = 0.01;
                final delta = -details.delta.dy * sensitivity;
                final newVolume = audioProvider.volume + delta;
                audioProvider.setVolume(newVolume);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),
                  // Album Art (Squared for Nothing look)
                  RotationTransition(
                    turns: _rotateController,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // Circular vinyl look
                        color: Colors.black,
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            currentAudio.albumArt != null
                                ? Image.memory(
                                    currentAudio.albumArt!,
                                    width: 300,
                                    height: 300,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 300,
                                    height: 300,
                                    color: Colors.grey[900],
                                    child: const Icon(
                                      Icons.music_note,
                                      size: 100,
                                      color: Colors.white,
                                    ),
                                  ),
                            // Center hole for vinyl look
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Song Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentAudio.name,
                              style: GoogleFonts.ibmPlexSerif(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentAudio.artist ?? 'Unknown Artist',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.playlist_add),
                        onPressed: () => _addToPlaylist(context, currentAudio),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Progress Bar
                  Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          activeTrackColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          inactiveTrackColor: Colors.grey.withOpacity(0.3),
                          thumbColor: Theme.of(context).colorScheme.secondary,
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
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(position),
                              style: GoogleFonts.spaceMono(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: GoogleFonts.spaceMono(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Playback Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          audioProvider.isShuffling
                              ? Icons.shuffle_on_outlined
                              : Icons.shuffle,
                          color: audioProvider.isShuffling
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.grey,
                        ),
                        onPressed: audioProvider.toggleShuffle,
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous),
                            iconSize: 32,
                            onPressed: audioProvider.playPrevious,
                          ),
                          const SizedBox(width: 24),
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD71920), // Nothing Red
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                              ),
                              iconSize: 32,
                              color: Colors.white,
                              onPressed: audioProvider.togglePlayPause,
                            ),
                          ),
                          const SizedBox(width: 24),
                          IconButton(
                            icon: const Icon(Icons.skip_next),
                            iconSize: 32,
                            onPressed: audioProvider.playNext,
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          audioProvider.isRepeating
                              ? Icons.repeat_one
                              : Icons.repeat,
                          color: audioProvider.isRepeating
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.grey,
                        ),
                        onPressed: audioProvider.toggleRepeat,
                      ),
                    ],
                  ),

                  const Spacer(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
