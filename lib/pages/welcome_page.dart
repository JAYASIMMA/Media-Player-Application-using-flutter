import 'package:flutter/material.dart';
import 'package:media_player/pages/home_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine colors based on theme, though Nothing theme is usually monochrome
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(
      context,
    ).colorScheme.secondary; // Usually red in NothingOS
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              // Logo or Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(40), // Circle
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'NOTHING\nPLAYER',
                style: TextStyle(
                  fontFamily: 'Ndot57',
                  fontSize: 48,
                  height: 1.1,
                  color: textColor,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                'PURE AUDIO.\nZERO DISTRACTIONS.',
                style: TextStyle(
                  fontFamily: 'Ndot57',
                  fontSize: 20,
                  color: Colors.grey,
                  letterSpacing: 1,
                ),
              ),

              const Spacer(flex: 3),

              // Instructions / Philosophy
              _buildInstructionItem(
                context,
                'DESIGN',
                'Minimalist interface inspired by Nothing OS. Black, white, and red aesthetics.',
              ),
              const SizedBox(height: 24),
              _buildInstructionItem(
                context,
                'GESTURES',
                'Swipe for volume and brightness. Pinch to zoom video. Intuitive controls.',
              ),

              const Spacer(flex: 4),

              // Get Started Button
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to Home Page with a replacement to prevent going back
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'GET STARTED',
                          style: TextStyle(
                            fontFamily: 'Ndot57',
                            fontSize: 18,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(
    BuildContext context,
    String title,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Ndot57',
            fontSize: 16,
            color: Theme.of(context).colorScheme.secondary, // Red accent
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontFamily: 'Ndot57',
            fontSize: 14,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.8),
            height: 1.4,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
