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
import 'videos_page.dart';
import 'folders_page.dart';
import 'settings_page.dart';
import 'playlist_page.dart';
import 'audio_player_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MediaService _mediaService = MediaService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _albums = [];

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndLoadMedia();
  }

  Future<void> _requestPermissionsAndLoadMedia() async {
    setState(() => _isLoading = true);
    await _mediaService.requestPermissions();
    await _mediaService.loadMedia();
    _albums = _mediaService.getAlbums();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final totalSongs = _mediaService.music.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isDark
                                              ? Icons.light_mode
                                              : Icons.dark_mode,
                                          size: 32,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          isDark ? "Light" : "Dark",
                                          style: const TextStyle(
                                            fontSize: 12,
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
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.music_note,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '$totalSongs',
                                              style: GoogleFonts.spaceMono(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                height: 1.0,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Songs",
                                              style: TextStyle(
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
                                          if (playlistProvider
                                              .favorites
                                              .isNotEmpty) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AudioPlayerPage(
                                                      audio: playlistProvider
                                                          .favorites
                                                          .first,
                                                      playlist: playlistProvider
                                                          .favorites,
                                                      autoplay: false,
                                                    ),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "No favorites yet!",
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFD71920),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.favorite,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${playlistProvider.favoriteCount}',
                                                  style: GoogleFonts.spaceMono(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1.0,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Favorites",
                                                  style: TextStyle(
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
                          const SizedBox(height: 12),
                          // Row 3: Quick Actions
                          IntrinsicHeight(
                            child: NothingWidgetContainer(
                              padding: EdgeInsets.zero,
                              child: Row(
                                children: [
                                  _buildQuickAction(
                                    context,
                                    "Videos",
                                    Icons.videocam_outlined,
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => Scaffold(
                                          appBar: AppBar(
                                            title: const Text("Videos"),
                                          ),
                                          body: VideosPage(
                                            mediaService: _mediaService,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    color: Theme.of(
                                      context,
                                    ).dividerColor.withOpacity(0.1),
                                  ),
                                  _buildQuickAction(
                                    context,
                                    "Folders",
                                    Icons.folder_open_outlined,
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => Scaffold(
                                          appBar: AppBar(
                                            title: const Text("Folders"),
                                          ),
                                          body: FoldersPage(
                                            mediaService: _mediaService,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    color: Theme.of(
                                      context,
                                    ).dividerColor.withOpacity(0.1),
                                  ),
                                  _buildQuickAction(
                                    context,
                                    "Playlists",
                                    Icons.playlist_play,
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PlaylistPage(
                                          mediaService: _mediaService,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    color: Theme.of(
                                      context,
                                    ).dividerColor.withOpacity(0.1),
                                  ),
                                  _buildQuickAction(
                                    context,
                                    "Settings",
                                    Icons.settings,
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SettingsPage(),
                                      ),
                                    ),
                                  ),
                                ],
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
                                builder: (context) => Scaffold(
                                  appBar: AppBar(
                                    title: const Text("All Music"),
                                  ),
                                  body: MusicPage(mediaService: _mediaService),
                                ),
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

                  const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
                ],
              ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showAlbumDetails(BuildContext context, Map<String, dynamic> album) {
    // Navigate to a temporary simple list view for the album
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(album['name'])),
          body: ListView.builder(
            itemCount: album['songs'].length,
            itemBuilder: (context, index) {
              final MediaItem song = album['songs'][index];
              return ListTile(
                leading: const Icon(Icons.music_note),
                title: Text(song.name),
                subtitle: Text(song.artist ?? 'Unknown'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AudioPlayerPage(
                        audio: song,
                        playlist: List<MediaItem>.from(album['songs']),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
