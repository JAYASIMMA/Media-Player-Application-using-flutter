import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/media_item.dart';
import '../../services/media_service.dart';
import '../../services/settings_provider.dart';
import 'video_player_page.dart';

enum VideoLayoutMode { list, grid, large }

class VideosPage extends StatefulWidget {
  final MediaService mediaService;

  const VideosPage({Key? key, required this.mediaService}) : super(key: key);

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  @override
  Widget build(BuildContext context) {
    final videos = widget.mediaService.videos;
    final settings = Provider.of<SettingsProvider>(context);
    // Convert int setting to Enum for local usage if needed, or just use int directly in UI logic.
    // Provider stores int: 0=List, 1=Grid, 2=Large.
    final currentMode = VideoLayoutMode.values[settings.videoLayoutMode];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Videos',
          style: TextStyle(
            fontFamily: settings.useNdotFont ? 'Ndot57' : null,
            fontWeight: settings.useNdotFont
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
      body: Column(
        children: [
          // Layout Toggle Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildLayoutToggle(
                  Icons.view_list,
                  VideoLayoutMode.list,
                  settings,
                ),
                const SizedBox(width: 8),
                _buildLayoutToggle(
                  Icons.grid_view,
                  VideoLayoutMode.grid,
                  settings,
                ),
                const SizedBox(width: 8),
                _buildLayoutToggle(
                  Icons.crop_square,
                  VideoLayoutMode.large,
                  settings,
                ),
              ],
            ),
          ),

          // Video List/Grid
          Expanded(
            child: videos.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async {
                      await widget.mediaService.loadMedia();
                      setState(() {});
                    },
                    child: _buildVideoView(videos, currentMode),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutToggle(
    IconData icon,
    VideoLayoutMode mode,
    SettingsProvider settings,
  ) {
    final isSelected = settings.videoLayoutMode == mode.index;
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.secondary
            : Colors.grey,
      ),
      onPressed: () {
        settings.setVideoLayoutMode(mode.index);
      },
    );
  }

  Widget _buildEmptyState() {
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

  Widget _buildVideoView(List<MediaItem> videos, VideoLayoutMode mode) {
    switch (mode) {
      case VideoLayoutMode.grid:
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: videos.length,
          itemBuilder: (context, index) => _buildGridItem(videos[index]),
        );
      case VideoLayoutMode.large:
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: videos.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _buildLargeItem(videos[index]),
        );
      case VideoLayoutMode.list:
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: videos.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) => _buildListItem(videos[index]),
        );
    }
  }

  Widget _buildTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'VIDEO',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGridItem(MediaItem video) {
    return GestureDetector(
      onTap: () => _openVideoPlayer(video),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: video.thumbnail != null
                ? Image.memory(video.thumbnail!, fit: BoxFit.cover)
                : Container(
                    color: Colors.black,
                    child: Icon(Icons.movie, size: 40, color: Colors.grey[800]),
                  ),
          ),
          Positioned(top: 8, right: 8, child: _buildTag()),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Text(
                video.name,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeItem(MediaItem video) {
    return GestureDetector(
      onTap: () => _openVideoPlayer(video),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: video.thumbnail != null
                      ? Image.memory(video.thumbnail!, fit: BoxFit.cover)
                      : Container(
                          color: Colors.black,
                          child: Icon(
                            Icons.movie,
                            size: 60,
                            color: Colors.grey[800],
                          ),
                        ),
                ),
              ),
              Positioned(top: 12, right: 12, child: _buildTag()),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    video.duration,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            video.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            video.size,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(MediaItem video) {
    return ListTile(
      leading: Stack(
        children: [
          Container(
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
                  : Container(
                      color: Colors.black,
                      child: Icon(
                        Icons.movie,
                        size: 30,
                        color: Colors.grey[800],
                      ),
                    ),
            ),
          ),
          Positioned(top: 4, right: 4, child: _buildTag()),
        ],
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
        onPressed: () => _showVideoOptions(context, video),
      ),
      onTap: () => _openVideoPlayer(video),
    );
  }

  void _openVideoPlayer(MediaItem video) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VideoPlayerPage(video: video)),
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
              _openVideoPlayer(video);
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
