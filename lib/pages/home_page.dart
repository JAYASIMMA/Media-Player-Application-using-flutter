// Save this in: lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'videos_page.dart';
import 'music_page.dart';
import 'folders_page.dart';
import '../../models/media_item.dart';
import '../../services/media_service.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final ThemeMode currentTheme;

  const HomePage({
    Key? key,
    required this.onThemeToggle,
    required this.currentTheme,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MediaService _mediaService = MediaService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _requestPermissionsAndLoadMedia();
  }

  Future<void> _requestPermissionsAndLoadMedia() async {
    setState(() => _isLoading = true);
    await _mediaService.requestPermissions();
    await _mediaService.loadMedia();
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.currentTheme == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MX Media Player',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'refresh') {
                _requestPermissionsAndLoadMedia();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Videos'),
            Tab(text: 'Music'),
            Tab(text: 'Folders'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                VideosPage(mediaService: _mediaService),
                MusicPage(mediaService: _mediaService),
                FoldersPage(mediaService: _mediaService),
              ],
            ),
    );
  }
}