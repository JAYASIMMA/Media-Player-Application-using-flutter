import 'package:flutter/material.dart';
import '../services/media_service.dart';

class FoldersPage extends StatelessWidget {
  final MediaService mediaService;

  const FoldersPage({Key? key, required this.mediaService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final folders = mediaService.getFolders();

    if (folders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No folders found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: folders.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final folder = folders[index];
        final count = folder['count'] as int;
        final folderName = folder['name'] as String;
        final folderPath = folder['path'] as String;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.folder, size: 32, color: Colors.orange[700]),
          ),
          title: Text(
            folderName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '$count items',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              Text(
                folderPath,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening folder: $folderName')),
            );
          },
        );
      },
    );
  }
}