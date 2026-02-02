import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'login_screen.dart';
import 'l10n/app_localizations.dart';
import 'models/user.dart';
import 'services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<CameraDescription>? cameras;
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale; // null means follow system
  bool _isLoading = true;
  User? _currentUser;
  bool _biometricEnabled = false;
  String _fontStyle = 'system';

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Load settings first before initializing cameras
    await _loadSettings();
    await _initCameras();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _initCameras() async {
    try {
      final cameraList = await availableCameras();
      setState(() {
        cameras = cameraList;
      });
    } catch (e) {
      setState(() {
        cameras = [];
      });
    }
  }

  String _currentLanguage = 'system'; // Track current language selection

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex =
        prefs.getInt('themeMode') ?? 0; // 0: system, 1: light, 2: dark
    final language = prefs.getString('language') ?? 'system';
    final biometricEnabled = prefs.getBool('biometricEnabled') ?? false;
    final fontStyle = prefs.getString('fontStyle') ?? 'system';

    // Load current user
    final userId = prefs.getString('current_user_id');
    if (userId != null) {
      final userService = UserService();
      final users = await userService.loadUsers();
      _currentUser = users.firstWhere((user) => user.id == userId);
    }

    setState(() {
      _themeMode = ThemeMode.values[themeIndex];
      _currentLanguage = language;
      _biometricEnabled = biometricEnabled;
      _fontStyle = fontStyle;
      // If language is 'system', set _locale to null to follow system language
      if (language == 'system') {
        _locale = null;
      } else {
        _locale = Locale(language);
      }
    });
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    setState(() {
      _themeMode = mode;
    });
  }

  Future<void> _saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);

    setState(() {
      _currentLanguage = language;
      // If language is 'system', set _locale to null to follow system language
      if (language == 'system') {
        _locale = null;
      } else {
        _locale = Locale(language);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || cameras == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Attendance App',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('id'), // Indonesian
      ],
      locale: _locale,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        cardColor: Colors.white,
        fontFamily: _fontStyle == 'app' ? 'Roboto' : null,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
        cardColor: Colors.grey,
        fontFamily: _fontStyle == 'app' ? 'Roboto' : null,

        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(color: Colors.grey.shade300),
        ),
      ),
      themeMode: _themeMode,
      home: _currentUser != null
          ? HomeScreen(
              cameras: cameras!,
              onThemeChanged: _saveThemeMode,
              onLanguageChanged: _saveLanguage,
              currentThemeMode: _themeMode,
              currentLanguage: _currentLanguage,
              currentUser: _currentUser!,
              biometricEnabled: _biometricEnabled,
            )
          : LoginScreen(
              cameras: cameras!,
              onThemeChanged: _saveThemeMode,
              onLanguageChanged: _saveLanguage,
              currentThemeMode: _themeMode,
              currentLanguage: _currentLanguage,
              biometricEnabled: _biometricEnabled,
            ),
    );
  }
}
