import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/media_item.dart';
import '../services/audio_provider.dart';
import '../pages/audio_player_page.dart';

class MediaSearchDelegate extends SearchDelegate<MediaItem?> {
  final List<MediaItem> musicList;
  final List<Map<String, dynamic>> albums;

  MediaSearchDelegate({required this.musicList, required this.albums});

  @override
  ThemeData appBarTheme(BuildContext context) {
    // Matches existing dark/Nothing OS theme
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        toolbarTextStyle: GoogleFonts.ibmPlexSerif(
          color: theme.colorScheme.onSurface,
          fontSize: 18,
        ),
        titleTextStyle: GoogleFonts.ibmPlexSerif(
          color: theme.colorScheme.onSurface,
          fontSize: 18,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.ibmPlexSerif(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Filter logic
    final results = _filterList(query);

    return _buildList(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = _filterList(query);
    return _buildList(context, results);
  }

  List<MediaItem> _filterList(String q) {
    if (q.isEmpty) return [];
    return musicList.where((item) {
      final nameLower = item.name.toLowerCase();
      final artistLower = (item.artist ?? '').toLowerCase();
      final albumLower = (item.album ?? '').toLowerCase();
      final queryLower = q.toLowerCase();

      return nameLower.contains(queryLower) ||
          artistLower.contains(queryLower) ||
          albumLower.contains(queryLower);
    }).toList();
  }

  Widget _buildList(BuildContext context, List<MediaItem> results) {
    if (results.isEmpty && query.isNotEmpty) {
      return Center(
        child: Text(
          "No results found",
          style: GoogleFonts.ibmPlexSerif(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.music_note, color: Colors.white),
          ),
          title: Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            "${item.artist ?? 'Unknown'} • ${item.album ?? 'Unknown'}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          onTap: () {
            // Play the song
            final provider = Provider.of<AudioProvider>(context, listen: false);
            provider.setPlaylist(results, index);

            // Navigate to player
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AudioPlayerPage(
                  audio: item,
                  playlist: results,
                  autoplay: true,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
