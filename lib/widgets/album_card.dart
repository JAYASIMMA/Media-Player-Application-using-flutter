import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlbumCard extends StatelessWidget {
  final String albumName;
  final String artistName;
  final int songCount;
  final Uint8List? albumArt;
  final VoidCallback onTap;

  const AlbumCard({
    Key? key,
    required this.albumName,
    required this.artistName,
    required this.songCount,
    this.albumArt,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[200],
                borderRadius: BorderRadius.circular(24),
                // "Nothing" style often has pixelated or distinct corners,
                // but for album art, a smooth curve or super-ellipse is good.
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: albumArt != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.memory(albumArt!, fit: BoxFit.cover),
                    )
                  : Center(
                      child: Icon(
                        Icons.album,
                        size: 48,
                        color: isDark ? Colors.grey[700] : Colors.grey[400],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            albumName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  artistName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$songCount',
                  style: GoogleFonts.spaceMono(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
