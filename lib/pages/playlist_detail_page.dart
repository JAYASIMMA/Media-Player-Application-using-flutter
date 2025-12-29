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
    return Consumer<PlaylistProvider>(
      builder: (context, playlistProvider, child) {
        final songs = playlistProvider.getPlaylistSongs(playlistName);

        // If playlist deleted externally (shouldn't happen often but safe to check)
        if (!playlistProvider.playlistNames.contains(playlistName)) {
          return const SizedBox();
        }

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              playlistName,
              style: GoogleFonts.notoSans(
                color: Colors.white,
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
                        color: Colors.grey[800],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Playlist is empty",
                        style: GoogleFonts.spaceMono(color: Colors.grey),
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
                  separatorBuilder: (context, index) =>
                      const Divider(color: Colors.white24, height: 1),
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                          image: song.albumArt != null
                              ? DecorationImage(
                                  image: MemoryImage(song.albumArt!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: song.albumArt == null
                            ? const Icon(Icons.music_note, color: Colors.grey)
                            : null,
                      ),
                      title: Text(
                        song.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                      subtitle: Text(
                        song.artist ?? "Unknown Artist",
                        maxLines: 1,
                        style: GoogleFonts.inter(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.grey,
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
