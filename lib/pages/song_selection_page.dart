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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Select Songs",
          style: GoogleFonts.ibmPlexSerif(color: Colors.white),
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
        separatorBuilder: (context, index) =>
            const Divider(color: Colors.white24, height: 1),
        itemBuilder: (context, index) {
          final song = widget.allSongs[index];
          final isSelected = _selectedSongs.contains(song);

          return ListTile(
            tileColor: isSelected ? Colors.white10 : null,
            leading: Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                    image: song.albumArt != null
                        ? DecorationImage(
                            image: MemoryImage(song.albumArt!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: song.albumArt == null
                      ? const Icon(Icons.music_note, color: Colors.grey)
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
              style: GoogleFonts.inter(color: Colors.white),
            ),
            subtitle: Text(
              song.artist ?? "Unknown Artist",
              maxLines: 1,
              style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
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
