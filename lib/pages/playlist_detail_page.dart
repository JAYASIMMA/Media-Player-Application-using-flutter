import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/media_item.dart';
import '../services/playlist_provider.dart';
import '../services/media_service.dart';
import 'audio_player_page.dart';
import 'song_selection_page.dart';

class PlaylistDetailPage extends StatelessWidget {
  final String playlistName;
  final MediaService mediaService;

  const PlaylistDetailPage({
    Key? key,
    required this.playlistName,
    required this.mediaService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<PlaylistProvider>(
      builder: (context, playlistProvider, child) {
        final songs = playlistProvider.getPlaylistSongs(playlistName);

        // If playlist deleted externally (shouldn't happen often but safe to check)
        if (!playlistProvider.playlistNames.contains(playlistName)) {
          return const SizedBox();
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            iconTheme: Theme.of(context).iconTheme,
            title: Text(
              playlistName,
              style: GoogleFonts.notoSans(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: songs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.queue_music,
                        size: 80,
                        color: Theme.of(
                          context,
                        ).iconTheme.color?.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Playlist is empty",
                        style: GoogleFonts.spaceMono(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD71920),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () =>
                            _openSongSelection(context, playlistProvider),
                        icon: const Icon(Icons.add),
                        label: const Text("ADD SONGS"),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: songs.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          image: song.albumArt != null
                              ? DecorationImage(
                                  image: MemoryImage(song.albumArt!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: song.albumArt == null
                            ? Icon(
                                Icons.music_note,
                                color: Theme.of(
                                  context,
                                ).iconTheme.color?.withOpacity(0.5),
                              )
                            : null,
                      ),
                      title: Text(
                        song.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: Text(
                        song.artist ?? "Unknown Artist",
                        maxLines: 1,
                        style: GoogleFonts.inter(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: Theme.of(
                            context,
                          ).iconTheme.color?.withOpacity(0.5),
                        ),
                        onPressed: () {
                          playlistProvider.removeFromPlaylist(
                            playlistName,
                            song,
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AudioPlayerPage(audio: song, playlist: songs),
                          ),
                        );
                      },
                    );
                  },
                ),
          floatingActionButton: songs.isNotEmpty
              ? FloatingActionButton(
                  backgroundColor: const Color(0xFFD71920),
                  child: const Icon(Icons.add, color: Colors.white),
                  onPressed: () =>
                      _openSongSelection(context, playlistProvider),
                )
              : null,
        );
      },
    );
  }

  void _openSongSelection(
    BuildContext context,
    PlaylistProvider provider,
  ) async {
    // Get all songs from media service (assuming it's loaded)
    final allSongs = mediaService.music;

    final List<MediaItem>? selectedSongs = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongSelectionPage(allSongs: allSongs),
      ),
    );

    if (selectedSongs != null && selectedSongs.isNotEmpty) {
      for (final song in selectedSongs) {
        provider.addToPlaylist(playlistName, song);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Added ${selectedSongs.length} songs")),
      );
    }
  }
}
