import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import '../services/media_service.dart';
import 'audio_player_page.dart';
// import 'video_player_page.dart'; // Assuming this exists or will be handled

class FolderContentPage extends StatelessWidget {
  final String folderName;
  final String folderPath;
  final MediaService mediaService;

  const FolderContentPage({
    Key? key,
    required this.folderName,
    required this.folderPath,
    required this.mediaService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter media items that belong to this folder
    final folderMusic = mediaService.music
        .where((item) => path.dirname(item.path) == folderPath)
        .toList();
    // final folderVideos = mediaService.videos.where((item) => path.dirname(item.path) == folderPath).toList();
    // For now we focus on music as per request context, but we can combine if needed.
    // Let's combine them for a full folder view.

    final allItems = [...folderMusic]; // Add videos if needed

    return Scaffold(
      appBar: AppBar(title: Text(folderName)),
      body: allItems.isEmpty
          ? const Center(child: Text("No media files found"))
          : ListView.separated(
              itemCount: allItems.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = allItems[index];
                return ListTile(
                  leading: const Icon(Icons.music_note), // Distinguish if video
                  title: Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(item.artist ?? "Unknown"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AudioPlayerPage(audio: item, playlist: allItems),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
