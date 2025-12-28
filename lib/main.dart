import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MediaPlayerApp());
}

class MediaPlayerApp extends StatefulWidget {
  const MediaPlayerApp({Key? key}) : super(key: key);

  @override
  State<MediaPlayerApp> createState() => _MediaPlayerAppState();
}
class _MediaPlayerAppState extends State<MediaPlayerApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MX Media Player',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true, // It's good practice to enable Material 3
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        brightness: Brightness.light,
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // --- CHANGE IS HERE ---
        tabBarTheme: const TabBarThemeData( // Use TabBarThemeData
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true, // It's good practice to enable Material 3
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
        brightness: Brightness.dark,
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          centerTitle: false,
        ),
        // --- AND HERE ---
        tabBarTheme: const TabBarThemeData( // Use TabBarThemeData
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
        ),
      ),
      home: HomePage(onThemeToggle: toggleTheme, currentTheme: _themeMode),
    );
  }
}