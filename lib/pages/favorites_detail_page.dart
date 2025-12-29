import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/playlist_provider.dart';
import '../services/settings_provider.dart';
import '../models/media_item.dart';
import '../pages/audio_player_page.dart';

class FavoritesDetailPage extends StatefulWidget {
  const FavoritesDetailPage({Key? key}) : super(key: key);

  @override
  State<FavoritesDetailPage> createState() => _FavoritesDetailPageState();
}

class _FavoritesDetailPageState extends State<FavoritesDetailPage> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

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
            actions: [
              IconButton(
                icon: Icon(
                  settings.isSongGrid ? Icons.view_list : Icons.grid_view,
                ),
                onPressed: () {
                  settings.toggleSongView();
                },
              ),
            ],
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
              : settings.isSongGrid
              ? GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final song = favorites[index];
                    return _buildGridItem(
                      context,
                      song,
                      playlistProvider,
                      favorites,
                    );
                  },
                )
              : ListView.separated(
                  itemCount: favorites.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final song = favorites[index];
                    return _buildListItem(
                      context,
                      song,
                      playlistProvider,
                      favorites,
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildListItem(
    BuildContext context,
    MediaItem song,
    PlaylistProvider provider,
    List<MediaItem> favorites,
  ) {
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
                color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
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
          provider.toggleFavorite(song);
        },
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AudioPlayerPage(audio: song, playlist: favorites),
          ),
        );
      },
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    MediaItem song,
    PlaylistProvider provider,
    List<MediaItem> favorites,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AudioPlayerPage(audio: song, playlist: favorites),
          ),
        );
      },
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: song.albumArt != null
                        ? Image.memory(song.albumArt!, fit: BoxFit.cover)
                        : Icon(
                            Icons.music_note,
                            size: 50,
                            color: Theme.of(
                              context,
                            ).iconTheme.color?.withOpacity(0.5),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                song.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                song.artist ?? "Unknown Artist",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                provider.toggleFavorite(song);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Color(0xFFD71920),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
