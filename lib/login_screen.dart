import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user.dart';
import 'services/user_service.dart';
import 'home.dart';
import 'l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Function(ThemeMode) onThemeChanged;
  final Function(String) onLanguageChanged;
  final ThemeMode currentThemeMode;
  final String currentLanguage;

  const LoginScreen({
    super.key,
    required this.cameras,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    required this.currentThemeMode,
    required this.currentLanguage,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userService = UserService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    final localizations = AppLocalizations.of(context)!;

    if (username.isEmpty || password.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(localizations.pleaseEnterUsernameAndPassword)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _userService.authenticate(username, password);
      if (user != null) {
        // Save current user to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user_id', user.id);
        await prefs.setString('current_user_username', user.username);
        await prefs.setString('current_user_email', user.email);
        await prefs.setString('current_user_role', user.role);

        // Navigate to AttendanceScreen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                cameras: widget.cameras,
                onThemeChanged: widget.onThemeChanged,
                onLanguageChanged: widget.onLanguageChanged,
                currentThemeMode: widget.currentThemeMode,
                currentLanguage: widget.currentLanguage,
                currentUser: user,
              ),
            ),
          );
        }
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text(localizations.invalidUsernameOrPassword)),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(localizations.loginFailed(e.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _switchTheme() {
    final currentIndex = widget.currentThemeMode.index;
    final nextIndex = (currentIndex + 1) % ThemeMode.values.length;
    widget.onThemeChanged(ThemeMode.values[nextIndex]);
  }

  void _switchLanguage() {
    const languages = ['system', 'en', 'id'];
    final currentIndex = languages.indexOf(widget.currentLanguage);
    final nextIndex = (currentIndex + 1) % languages.length;
    widget.onLanguageChanged(languages[nextIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Colors.grey[900]!, Colors.grey[800]!, Colors.grey[700]!]
                : [Colors.blue[50]!, Colors.blue[100]!, Colors.blue[200]!],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        localizations.appTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizations.companyName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      TextField(
                        controller: _usernameController,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: localizations.username,
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: localizations.password,
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                        ),
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _login(),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                )
                              : Text(
                                  localizations.login,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
