import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'login_screen.dart';
import 'l10n/app_localizations.dart';
import 'models/user.dart';
import 'services/user_service.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/user/user_bloc.dart';
import 'blocs/attendance/attendance_bloc.dart';
import 'blocs/settings/settings_bloc.dart';
import 'blocs/settings/settings_state.dart';

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
  bool _isLoading = true;
  User? _currentUser;

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

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load current user
    final userId = prefs.getString('current_user_id');
    final lastActivity = prefs.getInt('last_activity');
    if (userId != null && lastActivity != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final timeDiff = now - lastActivity;
      // 5 minutes = 5 * 60 * 1000 = 300000 milliseconds
      if (timeDiff <= 300000) {
        final userService = UserService();
        final users = await userService.loadUsers();
        _currentUser = users.firstWhere((user) => user.id == userId);
      } else {
        // Session expired, clear user data
        await prefs.remove('current_user_id');
        await prefs.remove('current_user_username');
        await prefs.remove('current_user_email');
        await prefs.remove('current_user_role');
        await prefs.remove('last_activity');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || cameras == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(userService: UserService())),
        BlocProvider(create: (context) => UserBloc(userService: UserService())),
        BlocProvider(create: (context) => AttendanceBloc()),
        BlocProvider(create: (context) => SettingsBloc()),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsInitial) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          final settings = state as SettingsLoaded;
          final locale = settings.language == 'system'
              ? null
              : Locale(settings.language);

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
            locale: locale,
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.grey[100],
              cardColor: Colors.white,
              fontFamily: settings.fontStyle == 'app' ? 'Poppins' : null,
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
              fontFamily: settings.fontStyle == 'app' ? 'Poppins' : null,

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
            themeMode: settings.themeMode,
            home: _currentUser != null
                ? HomeScreen(
                    cameras: cameras!,
                    currentThemeMode: settings.themeMode,
                    currentLanguage: settings.language,
                    currentFontStyle: settings.fontStyle,
                    currentUser: _currentUser!,
                    biometricEnabled: settings.biometricEnabled,
                  )
                : LoginScreen(
                    cameras: cameras!,
                    currentThemeMode: settings.themeMode,
                    currentLanguage: settings.language,
                    currentFontStyle: settings.fontStyle,
                    biometricEnabled: settings.biometricEnabled,
                  ),
          );
        },
      ),
    );
  }
}
