import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'ABOUT US',
          style: TextStyle(
            fontFamily: 'Ndot57',
            fontSize: 24,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            letterSpacing: 2,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo/Icon Section
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.music_note,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // App Name
            Center(
              child: Text(
                'NOTHING PLAYER',
                style: TextStyle(
                  fontFamily: 'Ndot57',
                  fontSize: 32,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  letterSpacing: 3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),

            // Version
            Center(
              child: Text(
                'VERSION 1.0.0',
                style: TextStyle(
                  fontFamily: 'Ndot57',
                  fontSize: 16,
                  color: Colors.grey,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 48),

            // Description Section
            _buildSectionTitle(context, 'ABOUT'),
            const SizedBox(height: 16),
            Text(
              'Nothing Player is a minimalist media player designed with the Nothing OS aesthetic in mind. Experience your music and videos with a clean, distraction-free interface that puts your content first.',
              style: TextStyle(
                fontFamily: 'Ndot57',
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.6,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 32),

            // Features Section
            _buildSectionTitle(context, 'FEATURES'),
            const SizedBox(height: 16),
            _buildFeatureItem(
              context,
              'AUDIO PLAYBACK',
              'High-quality audio playback with background support',
            ),
            _buildFeatureItem(
              context,
              'VIDEO PLAYER',
              'Smooth video playback with gesture controls',
            ),
            _buildFeatureItem(
              context,
              'PLAYLISTS',
              'Create and manage custom playlists',
            ),
            _buildFeatureItem(
              context,
              'FAVORITES',
              'Mark your favorite tracks for quick access',
            ),
            _buildFeatureItem(
              context,
              'DARK MODE',
              'Beautiful dark and light themes',
            ),
            const SizedBox(height: 32),

            // Credits Section
            _buildSectionTitle(context, 'CREDITS'),
            const SizedBox(height: 16),
            Text(
              'Developed with Flutter\nInspired by Nothing OS Design Language\n\n© 2025 Jayasimma D',
              style: TextStyle(
                fontFamily: 'Ndot57',
                fontSize: 14,
                color: Colors.grey,
                height: 1.8,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 48),

            // Contact Section
            _buildSectionTitle(context, 'CONTACT'),
            const SizedBox(height: 16),
            _buildContactItem(context, Icons.email, 'jayasimma1@gmail.com'),
            _buildContactItem(
              context,
              Icons.language,
              'https://github.com/JAYASIMMA/',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
            width: 2,
          ),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Ndot57',
          fontSize: 20,
          color: Theme.of(context).colorScheme.secondary,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Ndot57',
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Ndot57',
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Ndot57',
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
