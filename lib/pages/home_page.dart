import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_provider.dart' as Service;
import '../services/playlist_provider.dart' as PlaylistProv;
import '../services/theme_provider.dart';
import '../services/media_service.dart';
import '../models/media_item.dart';
import '../widgets/album_card.dart';
import '../widgets/playback_time_widget.dart';
import '../widgets/nothing_widget_container.dart';
import 'music_page.dart';

import '../widgets/custom_bottom_nav_bar.dart';
import 'audio_player_page.dart';
import 'favorites_detail_page.dart';
import 'album_detail_page.dart';
import 'videos_page.dart';
import 'folders_page.dart';
import 'playlist_page.dart'; // Ensure this is imported for navigation
import '../delegates/media_search_delegate.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MediaService _mediaService = MediaService();
  List<Map<String, dynamic>> _albums = [];

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndLoadMedia();
  }

  Future<void> _requestPermissionsAndLoadMedia() async {
    if (mounted) {
      final playlistProv = Provider.of<PlaylistProv.PlaylistProvider>(
        context,
        listen: false,
      );
      // Initialize playlist provider to load persisted paths
      await playlistProv.init();

      await _mediaService.requestPermissions();
      await _mediaService.loadMedia();

      // Combine music and videos for syncing
      final allMedia = [..._mediaService.music, ..._mediaService.videos];
      playlistProv.syncWithLibrary(allMedia);
    }

    if (mounted) {
      setState(() {
        _albums = _mediaService.getAlbums();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final totalSongs = _mediaService.music.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Stack to overlay the custom bottom nav bar
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 15,
                      bottom: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'NOTHING ',
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
                                text: 'PLAYER',
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
                        const SizedBox(height: 8),
                        Container(
                          height: 2,
                          width: 60,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                ),

                // 1. Dashboard Grid (Top Section)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // Row 1: Clock (Large) + Theme Toggle (Small)
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 2,
                                child: NothingWidgetContainer(
                                  onTap: () {
                                    final provider =
                                        Provider.of<Service.AudioProvider>(
                                          context,
                                          listen: false,
                                        );
                                    if (provider.currentAudio != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AudioPlayerPage(
                                            audio: provider.currentAudio!,
                                            playlist: provider.playlist,
                                            autoplay: false,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: const PlaybackTimeWidget(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: NothingWidgetContainer(
                                  onTap: () =>
                                      themeProvider.toggleTheme(isDark),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isDark
                                            ? Icons.light_mode
                                            : Icons.dark_mode,
                                        size: 36, // Increased from 32
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ), // Increased from 8
                                      Text(
                                        isDark ? "Light" : "Dark",
                                        style: const TextStyle(
                                          fontSize: 14, // Increased from 12
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        const SizedBox(height: 12),
                        // Row 2: Total Songs + Favorites + Quick Actions
                        // Wait, the design was Row 2: Songs | Favorites. Row 3: Quick Actions.
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: NothingWidgetContainer(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(
                                          12,
                                        ), // Increased from 8
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.music_note,
                                          color: Colors.white,
                                          size: 24, // Increased from 20
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$totalSongs',
                                            style: GoogleFonts.spaceMono(
                                              fontSize: 42, // Increased from 32
                                              fontWeight: FontWeight.bold,
                                              height: 1.0,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Songs",
                                            style: TextStyle(
                                              fontSize:
                                                  16, // Added explicit larger size
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color
                                                  ?.withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Consumer<PlaylistProv.PlaylistProvider>(
                                  builder: (context, playlistProvider, child) {
                                    return NothingWidgetContainer(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const FavoritesDetailPage(),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(
                                              12,
                                            ), // Increased from 8
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFD71920),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.favorite,
                                              color: Colors.white,
                                              size: 24, // Increased from 20
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${playlistProvider.favoriteCount}',
                                                style: GoogleFonts.spaceMono(
                                                  fontSize:
                                                      42, // Increased from 32
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.0,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Favorites",
                                                style: TextStyle(
                                                  fontSize:
                                                      16, // Added explicit larger size
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color
                                                      ?.withOpacity(0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Removed Quick Actions Row as requested to maintain clean look with new nav bar
                      ],
                    ),
                  ),
                ),

                // Library Section (Videos, Folders, Playlists)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLibraryItem(
                          context,
                          'Videos',
                          Icons.play_circle_outline,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VideosPage(mediaService: _mediaService),
                            ),
                          ),
                        ),
                        _buildLibraryItem(
                          context,
                          'Folders',
                          Icons.folder_open,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FoldersPage(mediaService: _mediaService),
                            ),
                          ),
                        ),
                        _buildLibraryItem(
                          context,
                          'Playlists',
                          Icons.queue_music,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PlaylistPage(mediaService: _mediaService),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Section Header
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "ALBUMS",
                          style: GoogleFonts.spaceMono(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MusicPage(mediaService: _mediaService),
                            ),
                          ),
                          child: const Text(
                            "See All",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Album Grid (Existing)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 0,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 24,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final album = _albums[index];
                      return AlbumCard(
                        albumName: album['name'],
                        artistName: album['artist'],
                        songCount: album['songCount'],
                        albumArt: album['art'],
                        onTap: () {
                          _showAlbumDetails(context, album);
                        },
                      );
                    }, childCount: _albums.length),
                  ),
                ),

                // Space for bottom nav
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
          ),

          // Custom Bottom Navigation Bar
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: CustomBottomNavBar(),
          ),
        ],
      ),
    );
  }

  void _showAlbumDetails(BuildContext context, Map<String, dynamic> album) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlbumDetailPage(
          albumName: album['name'],
          songs: List<MediaItem>.from(album['songs']),
        ),
      ),
    );
  }

  Widget _buildLibraryItem(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: NothingWidgetContainer(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 28,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
