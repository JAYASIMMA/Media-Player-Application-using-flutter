import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/playlist_provider.dart';
import '../pages/audio_player_page.dart';

class FavoritesDetailPage extends StatelessWidget {
  const FavoritesDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, playlistProvider, child) {
        final favorites = playlistProvider.favorites;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            iconTheme: Theme.of(context).iconTheme,
            title: Text(
              "Favorites",
              style: GoogleFonts.notoSans(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Theme.of(
                          context,
                        ).iconTheme.color?.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No favorites yet",
                        style: GoogleFonts.spaceMono(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: favorites.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final song = favorites[index];
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
                        icon: const Icon(
                          Icons.favorite,
                          color: Color(
                            0xFFD71920,
                          ), // Always red in this list to indicate it IS a favorite
                        ),
                        onPressed: () {
                          playlistProvider.toggleFavorite(song);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AudioPlayerPage(
                              audio: song,
                              playlist: favorites,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}
