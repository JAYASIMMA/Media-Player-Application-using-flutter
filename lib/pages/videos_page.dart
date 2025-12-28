
import 'package:flutter/material.dart';
import '../../models/media_item.dart';
import '../../services/media_service.dart';
import 'video_player_page.dart';

class VideosPage extends StatelessWidget {
  final MediaService mediaService;

  const VideosPage({Key? key, required this.mediaService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final videos = mediaService.videos;

    if (videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No videos found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await mediaService.loadMedia();
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: videos.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final video = videos[index];
          return ListTile(
            leading: Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: video.thumbnail != null
                    ? Image.memory(video.thumbnail!, fit: BoxFit.cover)
                    : Icon(Icons.movie, size: 30, color: Colors.grey[600]),
              ),
            ),
            title: Text(
              video.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  video.duration,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  video.size,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                _showVideoOptions(context, video);
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerPage(video: video),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showVideoOptions(BuildContext context, MediaItem video) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('Play'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerPage(video: video),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Details'),
            onTap: () {
              Navigator.pop(context);
              _showDetailsDialog(context, video);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, MediaItem video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${video.name}'),
            const SizedBox(height: 8),
            Text('Duration: ${video.duration}'),
            const SizedBox(height: 8),
            Text('Size: ${video.size}'),
            const SizedBox(height: 8),
            Text('Path: ${video.path}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}