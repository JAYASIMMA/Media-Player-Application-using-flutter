import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/settings_provider.dart';
import '../services/audio_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            children: [
              ListTile(
                title: const Text('Theme'),
                leading: const Icon(Icons.brightness_6),
                subtitle: Text(_getThemeText(themeProvider.themeMode)),
                onTap: () => _showThemeDialog(context, themeProvider),
              ),
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Show Subtitles'),
                        subtitle: const Text(
                          'Display subtitles in video player',
                        ),
                        secondary: const Icon(Icons.subtitles),
                        value: settingsProvider.showSubtitles,
                        onChanged: (value) =>
                            settingsProvider.toggleSubtitles(value),
                      ),
                      ListTile(
                        title: const Text('Sleep Timer'),
                        leading: const Icon(Icons.timer),
                        subtitle: Text(
                          settingsProvider.sleepTimerDuration != null
                              ? 'Off in ${settingsProvider.sleepTimerDuration} min'
                              : 'Off',
                        ),
                        onTap: () =>
                            _showSleepTimerDialog(context, settingsProvider),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _getThemeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
    }
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('System Default'),
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  themeProvider.setThemeMode(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light Mode'),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  themeProvider.setThemeMode(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark Mode'),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  themeProvider.setThemeMode(value!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSleepTimerDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Sleep Timer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTimerOption(context, settingsProvider, 15, '15 Minutes'),
              _buildTimerOption(context, settingsProvider, 30, '30 Minutes'),
              _buildTimerOption(context, settingsProvider, 60, '1 Hour'),
              ListTile(
                title: const Text('Custom'),
                leading: const Icon(Icons.edit),
                onTap: () {
                  Navigator.pop(context);
                  _showCustomTimerDialog(context, settingsProvider);
                },
              ),
              if (settingsProvider.sleepTimerDuration != null)
                ListTile(
                  title: const Text('Turn Off Timer'),
                  leading: const Icon(Icons.timer_off),
                  onTap: () {
                    settingsProvider.cancelSleepTimer();
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerOption(
    BuildContext context,
    SettingsProvider provider,
    int minutes,
    String label,
  ) {
    return ListTile(
      title: Text(label),
      onTap: () {
        final audioProvider = Provider.of<AudioProvider>(
          context,
          listen: false,
        );
        provider.setSleepTimer(minutes, audioProvider);
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sleep timer set for $label')));
      },
    );
  }

  void _showCustomTimerDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _controller = TextEditingController();
        return AlertDialog(
          title: const Text('Set Custom Timer'),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Enter minutes',
              suffixText: 'min',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                final minutes = int.tryParse(_controller.text);
                if (minutes != null && minutes > 0) {
                  final audioProvider = Provider.of<AudioProvider>(
                    context,
                    listen: false,
                  );
                  settingsProvider.setSleepTimer(minutes, audioProvider);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sleep timer set for $minutes min')),
                  );
                }
              },
              child: const Text('SET'),
            ),
          ],
        );
      },
    );
  }
}
