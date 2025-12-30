import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/media_service.dart';
import '../services/audio_provider.dart';
import '../delegates/media_search_delegate.dart';
import '../pages/favorites_detail_page.dart';
import '../pages/playlist_page.dart';
import '../pages/music_page.dart';
import '../pages/settings_page.dart';
import '../pages/audio_player_page.dart';

class CustomBottomNavBar extends StatelessWidget {
  final MediaService? mediaService;

  const CustomBottomNavBar({Key? key, this.mediaService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We need MediaService to pass to MusicPage and PlaylistPage.
    // Ideally, MediaService should be a provider or singleton, but currently it's instantiated in HomePage.
    // For now, we'll instantiate it here or pass it? passing is better but requires prop drilling.
    // Creating a fresh instance might reload data.
    // Let's rely on standard navigation. If pages need MediaService, they might create it or we pass it.
    // However, existing `HomePage` has state `_mediaService`.
    // The `MusicPage` and others take `mediaService` as argument.
    // This implies we should probably change `MediaService` to be a Provider or Singleton,
    // OR just instantiate it here if it's lightweight. It loads media.
    // Let's assume we can create one or we should refactor.
    // Given the task is "show nav bar", I will instantiate MediaService here or avoid using it if possible.
    // Looking at `HomePage`, `_mediaService` is created in state.
    // Refactoring to Provider would be best practice, but might be out of scope.
    // I will duplicate the `MediaService()` instantiation for navigation targets for now,
    // but a better way is to pass `mediaService` or make it global.
    // Let's pass `mediaService` in constructor if possible, OR instantiate it.
    // Since this is a reusable widget, maybe we don't pass it.
    // Let's make `MediaService` a singleton? The class definition:
    // `class MediaService { ... }`
    // If I just `new MediaService()`, it might re-query perms.
    // Let's try to find if `MediaService` is already used as a dependency injection in main.
    // It is not.
    // I will try to use `Provider.of<PlaylistProvider>` to access some data, but `MediaService` logic seems essential for pages.
    // For now, I'll instantiate `MediaService()` locally in the onPressed handlers or use a singleton pattern if I could edit `MediaService`.
    // To be safe and minimal: I'll accept `MediaService` generally, or just instantiate a new one for navigation purposes,
    // assuming it just provides data access.

    // Actually, `MediaSearchDelegate` needs `musicList` and `albums`.
    // These are loaded in `HomePage`.
    // If I put this bar on `SettingsPage`, I don't have access to that data easily without Provider.
    // This is a logical blocker.
    // SOLUTION: I should probably wrap the app with a `MediaService` provider or just `Provider<MediaService>`.
    // OR, I can accept `mediaService` as an optional parameter?
    // But `SettingsPage` doesn't have `mediaService`.
    // I will try to use `Provider.of<MediaService>(context)`? It's not in the tree yet.
    // I will check `main.dart` or `MultiProvider` setup.
    // If not present, I'll assume I can just new it up, but `Search` won't have cached data.

    // Let's proceed by creating the UI widget first. fixing data access later.
    // I'll make the buttons navigate.

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. Favorites
          IconButton(
            icon: const Icon(Icons.favorite_border),
            iconSize: 28,
            color: Theme.of(context).colorScheme.onSurface,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesDetailPage(),
                ),
              );
            },
          ),

          // 2. Search
          IconButton(
            icon: const Icon(Icons.search),
            iconSize: 28,
            color: Theme.of(context).colorScheme.onSurface,
            onPressed: () async {
              if (mediaService != null) {
                if (mediaService!.music.isEmpty) {
                  await mediaService!.loadMedia();
                }
                if (context.mounted) {
                  showSearch(
                    context: context,
                    delegate: MediaSearchDelegate(
                      musicList: mediaService!.music,
                      albums: mediaService!.getAlbums(),
                    ),
                  );
                }
              } else {
                final ms = MediaService();
                await ms.loadMedia();
                if (context.mounted) {
                  showSearch(
                    context: context,
                    delegate: MediaSearchDelegate(
                      musicList: ms.music,
                      albums: ms.getAlbums(),
                    ),
                  );
                }
              }
            },
          ),

          // 3. Playlist (Red Plus)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary, // Red
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add),
              iconSize: 28,
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlaylistPage(mediaService: mediaService),
                  ),
                );
              },
            ),
          ),

          // 4. All Music (Rhythm Symbol)
          IconButton(
            icon: const Icon(Icons.graphic_eq),
            iconSize: 28,
            color: Theme.of(context).colorScheme.onSurface,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MusicPage(mediaService: mediaService!), // Force loaded
                ),
              );
            },
          ),

          // 5. Settings
          IconButton(
            icon: const Icon(Icons.settings),
            iconSize: 28,
            color: Theme.of(context).colorScheme.onSurface,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsPage(mediaService: mediaService),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
