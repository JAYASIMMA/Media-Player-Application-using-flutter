import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/playlist_provider.dart';
import '../widgets/nothing_widget_container.dart';
import 'audio_player_page.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({Key? key}) : super(key: key);

  void _createPlaylist(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _controller = TextEditingController();
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          title: Text(
            'New Playlist',
            style: GoogleFonts.ibmPlexSerif(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Playlist Name',
              hintStyle: GoogleFonts.inter(color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "CANCEL",
                style: GoogleFonts.spaceMono(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                final name = _controller.text.trim();
                if (name.isNotEmpty) {
                  Provider.of<PlaylistProvider>(
                    context,
                    listen: false,
                  ).createPlaylist(name);
                  Navigator.pop(context);
                }
              },
              child: Text(
                "create",
                style: GoogleFonts.spaceMono(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 0,
                bottom: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'YOUR ',
                              style: GoogleFonts.ibmPlexSerif(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                                letterSpacing: 2,
                              ),
                            ),
                            TextSpan(
                              text: 'PLAYLISTS',
                              style: GoogleFonts.ibmPlexSerif(
                                fontSize: 28,
                                fontWeight: FontWeight.w300,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 2,
                    width: 60,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
            ),

            Expanded(
              child: Consumer<PlaylistProvider>(
                builder: (context, playlistProvider, child) {
                  final playlists = playlistProvider.playlistNames;

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Widget type grid
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.0, // Square widgets
                        ),
                    itemCount: playlists.length + 1, // +1 for "Add New" button
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Add New Playlist Button
                        return NothingWidgetContainer(
                          onTap: () => _createPlaylist(context),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 32,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Create New",
                                style: GoogleFonts.ibmPlexSerif(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final playlistName = playlists[index - 1];
                      final songs = playlistProvider.getPlaylistSongs(
                        playlistName,
                      );

                      return NothingWidgetContainer(
                        onTap: () {
                          if (songs.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AudioPlayerPage(
                                  audio: songs.first,
                                  playlist: songs,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Playlist is empty'),
                              ),
                            );
                          }
                        },
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon or basic art
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.queue_music,
                                    size: 28,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      playlistName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.ibmPlexSerif(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${songs.length} Tracks",
                                      style: GoogleFonts.spaceMono(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => playlistProvider.deletePlaylist(
                                  playlistName,
                                ),
                                child: Icon(
                                  Icons.remove_circle_outline,
                                  size: 20,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
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
