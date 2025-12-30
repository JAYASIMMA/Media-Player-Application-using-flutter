import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/media_item.dart';
import '../services/settings_provider.dart';
import 'audio_player_page.dart';

class AlbumDetailPage extends StatefulWidget {
  final String albumName;
  final List<MediaItem> songs;

  const AlbumDetailPage({
    Key? key,
    required this.albumName,
    required this.songs,
  }) : super(key: key);

  @override
  State<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final songs = widget.songs;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.albumName,
          style: settings.useNdotFont
              ? const TextStyle(
                  fontFamily: 'Ndot57',
                  fontWeight: FontWeight.bold,
                )
              : GoogleFonts.notoSans(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(settings.isSongGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              settings.toggleSongView();
            },
          ),
        ],
      ),
      body: settings.isSongGrid
          ? GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return _buildGridItem(context, song, songs);
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
                return _buildListItem(context, song, songs);
              },
            ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    MediaItem song,
    List<MediaItem> allSongs,
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
      title: Text(song.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        song.artist ?? 'Unknown',
        maxLines: 1,
        style: TextStyle(
          color: Theme.of(
            context,
          ).textTheme.bodyMedium?.color?.withOpacity(0.7),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AudioPlayerPage(audio: song, playlist: allSongs),
          ),
        );
      },
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    MediaItem song,
    List<MediaItem> allSongs,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AudioPlayerPage(audio: song, playlist: allSongs),
          ),
        );
      },
      child: Column(
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
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            song.artist ?? 'Unknown',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
