import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'services/theme_provider.dart';
import 'services/audio_provider.dart';

import 'services/playlist_provider.dart';
import 'services/settings_provider.dart';
import 'themes/nothing_theme.dart';

import 'package:just_audio_background/just_audio_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MediaPlayerApp(),
    ),
  );
}

class MediaPlayerApp extends StatelessWidget {
  const MediaPlayerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Nothing Player',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: NothingTheme.lightTheme,
          darkTheme: NothingTheme.darkTheme,
          home: const HomePage(),
        );
      },
    );
  }
}
