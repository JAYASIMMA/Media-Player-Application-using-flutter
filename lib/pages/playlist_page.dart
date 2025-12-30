import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/playlist_provider.dart';
import '../services/media_service.dart';
import '../widgets/nothing_widget_container.dart';
import 'playlist_detail_page.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class PlaylistPage extends StatefulWidget {
  final MediaService?
  mediaService; // Optional to prevent breaking if not passed immediately, but aimed to be required.

  const PlaylistPage({Key? key, this.mediaService}) : super(key: key);

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final Set<String> _selectedPlaylists = {};
  bool _isSelectionMode = false;

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
                "CREATE",
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

  void _toggleSelection(String playlistName) {
    setState(() {
      if (_selectedPlaylists.contains(playlistName)) {
        _selectedPlaylists.remove(playlistName);
        if (_selectedPlaylists.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedPlaylists.add(playlistName);
      }
    });
  }

  void _deleteSelected(PlaylistProvider provider) {
    for (final name in _selectedPlaylists) {
      provider.deletePlaylist(name);
    }
    setState(() {
      _selectedPlaylists.clear();
      _isSelectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isSelectionMode
              ? '${_selectedPlaylists.length} Selected'
              : 'Playlists',
        ),
        actions: [
          if (_isSelectionMode)
            IconButton(
              onPressed: () {
                final provider = Provider.of<PlaylistProvider>(
                  context,
                  listen: false,
                );
                _deleteSelected(provider);
              },
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Consumer<PlaylistProvider>(
                    builder: (context, playlistProvider, child) {
                      final playlists = playlistProvider.playlistNames;

                      return GridView.builder(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          bottom: 100, // Padding for nav bar
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // Widget type grid
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.0, // Square widgets
                            ),
                        itemCount:
                            playlists.length + 1, // +1 for "Add New" button
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
                          final isSelected = _selectedPlaylists.contains(
                            playlistName,
                          );

                          return NothingWidgetContainer(
                            onTap: () {
                              if (_isSelectionMode) {
                                _toggleSelection(playlistName);
                              } else {
                                if (widget.mediaService != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlaylistDetailPage(
                                        playlistName: playlistName,
                                        mediaService: widget.mediaService!,
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Media Service not available",
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            onLongPress: () {
                              setState(() {
                                _isSelectionMode = true;
                                _toggleSelection(playlistName);
                              });
                            },
                            decoration: isSelected
                                ? BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFFD71920),
                                      width: 3,
                                    ), // Nothing Red
                                    borderRadius: BorderRadius.circular(24),
                                    color: Theme.of(context).cardColor,
                                  )
                                : null,
                            child: Stack(
                              children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                if (isSelected)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFD71920),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
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

          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: CustomBottomNavBar(mediaService: widget.mediaService),
          ),
        ],
      ),
    );
  }
}
