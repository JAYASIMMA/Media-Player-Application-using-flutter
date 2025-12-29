// ==================== lib/pages/music_page.dart ====================
import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/media_service.dart';
import 'audio_player_page.dart';

class MusicPage extends StatefulWidget {
  final MediaService mediaService;

  const MusicPage({Key? key, required this.mediaService}) : super(key: key);

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    final music = widget.mediaService.music;

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Music"),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: music.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_off, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No music found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pull down to refresh',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await widget.mediaService.loadMedia();
                setState(() {});
              },
              child: _isGridView
                  ? GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75, // Adjust for card height
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: music.length,
                      itemBuilder: (context, index) {
                        final audio = music[index];
                        return _buildGridItem(context, audio);
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: music.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, indent: 72),
                      itemBuilder: (context, index) {
                        final audio = music[index];
                        return _buildListItem(context, audio);
                      },
                    ),
            ),
    );
  }

  Widget _buildListItem(BuildContext context, MediaItem audio) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: audio.albumArt != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(audio.albumArt!, fit: BoxFit.cover),
              )
            : const Icon(Icons.music_note, size: 28, color: Colors.white),
      ),
      title: Text(
        audio.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            audio.artist ?? 'Unknown Artist',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 2),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          _showMusicOptions(context, audio);
        },
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AudioPlayerPage(
              audio: audio,
              playlist: widget.mediaService.music,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridItem(BuildContext context, MediaItem audio) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AudioPlayerPage(
              audio: audio,
              playlist: widget.mediaService.music,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: audio.albumArt != null
                    ? Image.memory(audio.albumArt!, fit: BoxFit.cover)
                    : const Icon(
                        Icons.music_note,
                        size: 50,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            audio.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            audio.artist ?? 'Unknown Artist',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showMusicOptions(BuildContext context, MediaItem audio) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.play_arrow, color: Colors.blue),
              title: const Text('Play'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AudioPlayerPage(
                      audio: audio,
                      playlist: widget.mediaService.music,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Add to Playlist'),
              onTap: () {
                Navigator.pop(context);
                // Implementation for adding to playlist would go here
                // For now just close the sheet
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Details'),
              onTap: () {
                Navigator.pop(context);
                _showDetailsDialog(context, audio);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, MediaItem audio) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Music Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Title', audio.name),
              _buildDetailRow('Artist', audio.artist ?? 'Unknown'),
              _buildDetailRow('Album', audio.album ?? 'Unknown'),
              _buildDetailRow('Duration', audio.duration),
              _buildDetailRow('Size', audio.size),
              _buildDetailRow('Path', audio.path),
            ],
          ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
