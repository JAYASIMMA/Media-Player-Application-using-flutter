import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/media_item.dart';

class SongSelectionPage extends StatefulWidget {
  final List<MediaItem> allSongs;

  const SongSelectionPage({Key? key, required this.allSongs}) : super(key: key);

  @override
  State<SongSelectionPage> createState() => _SongSelectionPageState();
}

class _SongSelectionPageState extends State<SongSelectionPage> {
  final Set<MediaItem> _selectedSongs = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Select Songs",
          style: GoogleFonts.ibmPlexSerif(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        actions: [
          if (_selectedSongs.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.pop(context, _selectedSongs.toList());
              },
              child: Text(
                "ADD (${_selectedSongs.length})",
                style: GoogleFonts.spaceMono(
                  color: const Color(0xFFD71920), // Nothing Red
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: ListView.separated(
        itemCount: widget.allSongs.length,
        separatorBuilder: (context, index) => Divider(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final song = widget.allSongs[index];
          final isSelected = _selectedSongs.contains(song);

          return ListTile(
            tileColor: isSelected
                ? (isDark ? Colors.white10 : Colors.black12)
                : null,
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
                          color: Theme.of(
                            context,
                          ).iconTheme.color?.withOpacity(0.5),
                        )
                      : null,
                ),
                if (isSelected)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.check, color: Color(0xFFD71920)),
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
            trailing: Checkbox(
              value: isSelected,
              activeColor: const Color(0xFFD71920),
              checkColor: Colors.white,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedSongs.add(song);
                  } else {
                    _selectedSongs.remove(song);
                  }
                });
              },
            ),
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedSongs.remove(song);
                } else {
                  _selectedSongs.add(song);
                }
              });
            },
          );
        },
      ),
    );
  }
}
