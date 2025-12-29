import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'PRIVACY POLICY',
          style: GoogleFonts.dotGothic16(
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
            // Last Updated
            Center(
              child: Text(
                'LAST UPDATED: DECEMBER 2025',
                style: GoogleFonts.spaceMono(
                  fontSize: 12,
                  color: Colors.grey,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Introduction
            _buildSectionTitle(context, 'INTRODUCTION'),
            const SizedBox(height: 16),
            _buildParagraph(
              context,
              'Nothing Player ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.',
            ),
            const SizedBox(height: 24),

            // Information We Collect
            _buildSectionTitle(context, 'INFORMATION WE COLLECT'),
            const SizedBox(height: 16),
            _buildSubsection(context, 'LOCAL MEDIA ACCESS'),
            _buildParagraph(
              context,
              'The app accesses your device\'s local storage to scan and display your audio and video files. This information is stored locally on your device and is not transmitted to our servers.',
            ),
            const SizedBox(height: 12),
            _buildSubsection(context, 'APP PREFERENCES'),
            _buildParagraph(
              context,
              'We store your app preferences (theme settings, playlists, favorites) locally on your device using secure storage mechanisms.',
            ),
            const SizedBox(height: 24),

            // How We Use Information
            _buildSectionTitle(context, 'HOW WE USE YOUR INFORMATION'),
            const SizedBox(height: 16),
            _buildBulletPoint(
              context,
              'To provide media playback functionality',
            ),
            _buildBulletPoint(
              context,
              'To remember your preferences and settings',
            ),
            _buildBulletPoint(context, 'To organize your media library'),
            _buildBulletPoint(
              context,
              'To enable playlist and favorites features',
            ),
            const SizedBox(height: 24),

            // Data Storage
            _buildSectionTitle(context, 'DATA STORAGE'),
            const SizedBox(height: 16),
            _buildParagraph(
              context,
              'All data collected by Nothing Player is stored locally on your device. We do not transmit, store, or process your personal information on external servers. Your media files, playlists, and preferences remain entirely under your control.',
            ),
            const SizedBox(height: 24),

            // Permissions
            _buildSectionTitle(context, 'PERMISSIONS'),
            const SizedBox(height: 16),
            _buildSubsection(context, 'STORAGE ACCESS'),
            _buildParagraph(
              context,
              'Required to read and display your media files.',
            ),
            const SizedBox(height: 12),
            _buildSubsection(context, 'MEDIA PLAYBACK'),
            _buildParagraph(
              context,
              'Required for audio and video playback functionality.',
            ),
            const SizedBox(height: 24),

            // Third-Party Services
            _buildSectionTitle(context, 'THIRD-PARTY SERVICES'),
            const SizedBox(height: 16),
            _buildParagraph(
              context,
              'Nothing Player does not integrate with any third-party analytics, advertising, or tracking services. Your usage data is not shared with any external parties.',
            ),
            const SizedBox(height: 24),

            // Children's Privacy
            _buildSectionTitle(context, 'CHILDREN\'S PRIVACY'),
            const SizedBox(height: 16),
            _buildParagraph(
              context,
              'Our app does not knowingly collect personal information from children under 13. The app is designed for general audiences and does not require any personal information to function.',
            ),
            const SizedBox(height: 24),

            // Changes to Policy
            _buildSectionTitle(context, 'CHANGES TO THIS POLICY'),
            const SizedBox(height: 16),
            _buildParagraph(
              context,
              'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date.',
            ),
            const SizedBox(height: 24),

            // Contact
            _buildSectionTitle(context, 'CONTACT US'),
            const SizedBox(height: 16),
            _buildParagraph(
              context,
              'If you have any questions about this Privacy Policy, please contact us at:',
            ),
            const SizedBox(height: 12),
            _buildContactInfo(context, 'Email', 'privacy@nothingplayer.com'),
            _buildContactInfo(context, 'Website', 'www.nothingplayer.com'),
            const SizedBox(height: 48),

            // Footer
            Center(
              child: Text(
                '© 2025 NOTHING PLAYER\nALL RIGHTS RESERVED',
                style: GoogleFonts.spaceMono(
                  fontSize: 12,
                  color: Colors.grey,
                  letterSpacing: 1,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
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
        style: GoogleFonts.dotGothic16(
          fontSize: 18,
          color: Theme.of(context).colorScheme.secondary,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildSubsection(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.dotGothic16(
        fontSize: 16,
        color: Theme.of(context).textTheme.bodyLarge?.color,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildParagraph(BuildContext context, String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: Theme.of(context).textTheme.bodyMedium?.color,
        height: 1.6,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.6,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.spaceMono(
              fontSize: 14,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.spaceMono(
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
