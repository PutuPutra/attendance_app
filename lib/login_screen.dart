import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'models/user.dart';
import 'services/user_service.dart';
import 'home.dart';
import 'settings_screen.dart';
import 'l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Function(ThemeMode) onThemeChanged;
  final Function(String) onLanguageChanged;
  final ThemeMode currentThemeMode;
  final String currentLanguage;
  final bool biometricEnabled;

  const LoginScreen({
    super.key,
    required this.cameras,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    required this.currentThemeMode,
    required this.currentLanguage,
    required this.biometricEnabled,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum ForgotPasswordStep { username, code, password }

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _forgotUsernameController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _userService = UserService();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isCountdown = false;
  int _countdown = 0;
  Timer? _countdownTimer;
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
    _forgotUsernameController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _countdownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<bool> _authenticateBiometric() async {
    try {
      final bool canAuthenticateWithBiometric =
          await _localAuth.canCheckBiometrics;
      if (!canAuthenticateWithBiometric) {
        return false;
      }
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = widget.biometricEnabled
        ? ''
        : _passwordController.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    final localizations = AppLocalizations.of(context)!;

    if (username.isEmpty || (!widget.biometricEnabled && password.isEmpty)) {
      messenger.showSnackBar(
        SnackBar(content: Text(localizations.pleaseEnterUsernameAndPassword)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user;
      if (widget.biometricEnabled) {
        final authenticated = await _authenticateBiometric();
        if (!authenticated) {
          messenger.showSnackBar(
            SnackBar(content: Text('Biometric authentication failed')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
        // Find user by username
        final users = await _userService.loadUsers();
        user = users.firstWhere((u) => u.username == username);
      } else {
        user = await _userService.authenticate(username, password);
      }

      if (user != null) {
        // Save current user to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user_id', user.id);
        await prefs.setString('current_user_username', user.username);
        await prefs.setString('current_user_email', user.email);
        await prefs.setString('current_user_role', user.role);

        // Check if just reset password
        final justReset = prefs.getBool('just_reset_password') ?? false;
        if (justReset) {
          // Keep the flag for HomeScreen to handle
          // Navigate to HomeScreen, which will then push Settings
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
                  currentUser: user!,
                  biometricEnabled: widget.biometricEnabled,
                ),
              ),
            );
          }
        } else {
          // Navigate to HomeScreen
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
                  currentUser: user!,
                  biometricEnabled: widget.biometricEnabled,
                ),
              ),
            );
          }
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

  void _showForgotPasswordDialog() {
    if (_isCountdown) return; // Prevent multiple taps

    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter username first')));
      return;
    }

    _userService
        .sendResetCode(username)
        .then((code) {
          setState(() {
            _passwordController.text = code;
            _isCountdown = true;
            _countdown = 60;
          });
          _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            setState(() {
              _countdown--;
              if (_countdown <= 0) {
                _countdownTimer?.cancel();
                _isCountdown = false;
                _passwordController.clear();
              }
            });
          });
        })
        .catchError((e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        });
  }

  void _clearControllers() {
    _forgotUsernameController.clear();
    _codeController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.blue[700],
      body: Column(
        children: [
          Expanded(child: Container()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 10,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
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
                        textInputAction: widget.biometricEnabled
                            ? TextInputAction.done
                            : TextInputAction.next,
                        onSubmitted: widget.biometricEnabled
                            ? (_) => _login()
                            : null,
                      ),
                      const SizedBox(height: 20),
                      if (!widget.biometricEnabled)
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
                      if (!widget.biometricEnabled) const SizedBox(height: 8),
                      if (!widget.biometricEnabled)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _showForgotPasswordDialog,
                            child: Text(
                              _isCountdown
                                  ? '$_countdown detik'
                                  : localizations.forgotPassword,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
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
                                  widget.biometricEnabled
                                      ? localizations.passwordOrBiometric
                                      : localizations.login,
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
        ],
      ),
    );
  }
}
