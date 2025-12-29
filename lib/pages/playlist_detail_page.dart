import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/media_item.dart';
import '../services/playlist_provider.dart';
import '../services/media_service.dart';
import '../services/settings_provider.dart';
import '../pages/audio_player_page.dart';
import 'song_selection_page.dart';

class PlaylistDetailPage extends StatefulWidget {
  final String playlistName;
  final MediaService mediaService;

  const PlaylistDetailPage({
    Key? key,
    required this.playlistName,
    required this.mediaService,
  }) : super(key: key);

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  bool _isSelectionMode = false;
  final Set<String> _selectedPaths = {};

  void _toggleSelection(String path) {
    setState(() {
      if (_selectedPaths.contains(path)) {
        _selectedPaths.remove(path);
        if (_selectedPaths.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedPaths.add(path);
      }
    });
  }

  void _enterSelectionMode(String path) {
    setState(() {
      _isSelectionMode = true;
      _selectedPaths.add(path);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedPaths.clear();
    });
  }

  Future<void> _deleteSelected(PlaylistProvider provider) async {
    final count = _selectedPaths.length;
    if (count == 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Songs?'),
        content: Text('Remove $count songs from this playlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Find items to remove
      final songsToRemove = provider
          .getPlaylistSongs(widget.playlistName)
          .where((s) => _selectedPaths.contains(s.path))
          .toList();

      for (final song in songsToRemove) {
        provider.removeFromPlaylist(widget.playlistName, song);
      }

      _exitSelectionMode();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$count songs removed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Consumer<PlaylistProvider>(
      builder: (context, playlistProvider, child) {
        final songs = playlistProvider.getPlaylistSongs(widget.playlistName);

        // If playlist deleted externally
        if (!playlistProvider.playlistNames.contains(widget.playlistName)) {
          return const SizedBox();
        }

        return WillPopScope(
          onWillPop: () async {
            if (_isSelectionMode) {
              _exitSelectionMode();
              return false;
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              iconTheme: Theme.of(context).iconTheme,
              leading: _isSelectionMode
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _exitSelectionMode,
                    )
                  : null, // Default
              title: _isSelectionMode
                  ? Text("${_selectedPaths.length} Selected")
                  : Text(
                      widget.playlistName,
                      style: GoogleFonts.notoSans(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              actions: [
                if (_isSelectionMode)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteSelected(playlistProvider),
                  )
                else ...[
                  IconButton(
                    icon: Icon(
                      settings.isSongGrid ? Icons.view_list : Icons.grid_view,
                    ),
                    onPressed: () {
                      settings.toggleSongView();
                    },
                  ),
                ],
              ],
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
                : settings.isSongGrid
                ? GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return _buildGridItem(
                        context,
                        song,
                        playlistProvider,
                        songs,
                      );
                    },
                  )
                : ListView.separated(
                    itemCount: songs.length,
                    separatorBuilder: (context, index) => Divider(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return _buildListItem(
                        context,
                        song,
                        playlistProvider,
                        songs,
                      );
                    },
                  ),
            floatingActionButton: (!_isSelectionMode && songs.isNotEmpty)
                ? FloatingActionButton(
                    backgroundColor: const Color(0xFFD71920),
                    child: const Icon(Icons.add, color: Colors.white),
                    onPressed: () =>
                        _openSongSelection(context, playlistProvider),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildListItem(
    BuildContext context,
    MediaItem song,
    PlaylistProvider provider,
    List<MediaItem> songs,
  ) {
    final isSelected = _selectedPaths.contains(song.path);
    return ListTile(
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
      leading: Stack(
        children: [
          Container(
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
          if (_isSelectionMode && isSelected)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.check, color: Colors.white),
                ),
              ),
            ),
        ],
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
      trailing: _isSelectionMode
          ? Checkbox(
              value: isSelected,
              onChanged: (val) => _toggleSelection(song.path),
            )
          : IconButton(
              icon: Icon(
                Icons.remove_circle_outline,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
              ),
              onPressed: () {
                provider.removeFromPlaylist(widget.playlistName, song);
              },
            ),
      onLongPress: () => _enterSelectionMode(song.path),
      onTap: () {
        if (_isSelectionMode) {
          _toggleSelection(song.path);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AudioPlayerPage(audio: song, playlist: songs),
            ),
          );
        }
      },
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    MediaItem song,
    PlaylistProvider provider,
    List<MediaItem> songs,
  ) {
    final isSelected = _selectedPaths.contains(song.path);
    return GestureDetector(
      onLongPress: () => _enterSelectionMode(song.path),
      onTap: () {
        if (_isSelectionMode) {
          _toggleSelection(song.path);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AudioPlayerPage(audio: song, playlist: songs),
            ),
          );
        }
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
                    border: isSelected
                        ? Border.all(color: Colors.red, width: 2)
                        : null,
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
          if (_isSelectionMode)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.red : Colors.grey,
                ),
              ),
            ),
          // Existing quick remove button - hide in selection mode to avoid confusion?
          // User asked for long press select to remove.
          if (!_isSelectionMode)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  provider.removeFromPlaylist(widget.playlistName, song);
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openSongSelection(
    BuildContext context,
    PlaylistProvider provider,
  ) async {
    // Get all songs from media service (assuming it's loaded)
    final allSongs = widget.mediaService.music;

    final List<MediaItem>? selectedSongs = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongSelectionPage(allSongs: allSongs),
      ),
    );

    if (selectedSongs != null && selectedSongs.isNotEmpty) {
      for (final song in selectedSongs) {
        provider.addToPlaylist(widget.playlistName, song);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Added ${selectedSongs.length} songs")),
        );
      }
    }
  }
}
