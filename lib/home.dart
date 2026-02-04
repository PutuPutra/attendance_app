import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'face_scan_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import 'attendance_history.dart';
import 'user_management_screen.dart';
import 'all_employee_history_screen.dart';
import 'l10n/app_localizations.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'blocs/settings/settings_bloc.dart';
import 'blocs/settings/settings_state.dart';

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final ThemeMode currentThemeMode;
  final String currentLanguage;
  final String currentFontStyle;
  final User currentUser;
  final bool biometricEnabled;

  const HomeScreen({
    super.key,
    required this.cameras,
    required this.currentThemeMode,
    required this.currentLanguage,
    required this.currentFontStyle,
    required this.currentUser,
    required this.biometricEnabled,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  // Admin-specific state
  List<User> _allUsers = [];
  User? _selectedEmployee;
  String _adminDateFilter = 'Last 7 days';
  String _userManagementAction = 'View Users';
  List<Map<String, dynamic>> _employeeHistory = [];

  @override
  void initState() {
    super.initState();
    _updateActivityTimestamp();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
    if (widget.currentUser.role == 'admin') {
      _loadAllUsers();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final justReset = prefs.getBool('just_reset_password') ?? false;
      if (justReset) {
        await prefs.remove('just_reset_password');
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SettingsScreen(
                currentUser: widget.currentUser,
                openChangePasswordDialog: true,
              ),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            final s = state as SettingsLoaded;
            return LoginScreen(
              cameras: widget.cameras,
              currentThemeMode: s.themeMode,
              currentLanguage: s.language,
              currentFontStyle: s.fontStyle,
              biometricEnabled: s.biometricEnabled,
            );
          },
        ),
      ),
      (route) => false,
    );
  }

  void _showLogoutConfirmation() {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              const SizedBox(width: 8),
              Text(localizations.logout),
            ],
          ),
          content: Text(localizations.confirmLogout),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(localizations.ok),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadAllUsers() async {
    final userService = UserService();
    _allUsers = await userService.loadUsers();
    setState(() {});
  }

  Future<void> _updateActivityTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_activity', DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).languageCode;
    final formattedDate = DateFormat('EEE, dd/MM/yyyy', locale).format(now);
    final formattedTime = locale == 'id'
        ? DateFormat('HH:mm').format(now)
        : DateFormat('hh:mm a').format(now);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 400.0 < 1.0 ? screenWidth / 400.0 : 1.0;

    return Scaffold(
      body: Stack(
        children: [
          // Blue background for top half
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height / 2,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          // Content on top
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: 40,
                  bottom: 40,
                  left: 16 * scale,
                  right: 16 * scale,
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.currentUser.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.currentUser.id} - ${widget.currentUser.role}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SettingsScreen(currentUser: widget.currentUser),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: _showLogoutConfirmation,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.0 * scale),
                //dari mulai line ini belum responsif
                child: Card(
                  elevation: 2,
                  color: isDarkMode ? Colors.grey[800] : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 16.0 * scale,
                      right: 16.0 * scale,
                      top: 16.0 * scale,
                      bottom: 8.0 * scale,
                    ),
                    child: Column(
                      children: [
                        Text(
                          localizations.liveAttendance,
                          style: TextStyle(
                            color: onSurfaceColor,
                            fontSize: 14 * scale,
                          ),
                        ),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            color: onSurfaceColor,
                            fontSize: 32 * scale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: onSurfaceColor,
                            fontSize: 14 * scale,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          height: 1,
                          color: onSurfaceColor.withOpacity(0.1),
                          margin: const EdgeInsets.symmetric(
                            vertical: 1,
                            horizontal: 2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          localizations.officeHours,
                          style: TextStyle(
                            color: onSurfaceColor,
                            fontSize: 14 * scale,
                          ),
                        ),
                        Text(
                          localizations.officeHoursTime,
                          style: TextStyle(
                            color: onSurfaceColor,
                            fontSize: 16 * scale,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio:
                              4.0, // Make buttons slimmer (wider than tall)
                          mainAxisSpacing: 8.0 * scale,
                          crossAxisSpacing: 8.0 * scale,
                          children: [
                            _buildButton(
                              context,
                              localizations.checkIn,
                              Colors.blue,
                            ),
                            _buildButton(
                              context,
                              localizations.breakTime,
                              Colors.blue,
                            ),
                            _buildButton(
                              context,
                              localizations.returnToWork,
                              Colors.blue,
                            ),
                            _buildButton(
                              context,
                              localizations.checkOut,
                              Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                //akhir nya disini juga belum responsif
              ),
              if (widget.currentUser.role == 'admin')
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 30.0 * scale,
                            vertical: 30.0,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Card(
                                  elevation: 2,
                                  color: isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => UserManagementScreen(
                                            currentUser: widget.currentUser,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.people,
                                            size: 40 * scale,
                                            color: onSurfaceColor,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            localizations.userManagement,
                                            style: TextStyle(
                                              color: onSurfaceColor,
                                              fontSize: 14 * scale,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Card(
                                  elevation: 2,
                                  color: isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AllEmployeeHistoryScreen(),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.history,
                                            size: 40 * scale,
                                            color: onSurfaceColor,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            localizations.allEmployeeHistory,
                                            style: TextStyle(
                                              color: onSurfaceColor,
                                              fontSize: 13 * scale,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AttendanceHistoryWidget(isScrollable: true),
                      ],
                    ),
                  ),
                )
              else
                Expanded(child: AttendanceHistoryWidget()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize =
        screenWidth * 0.18; // Adjust as needed for responsiveness
    return ElevatedButton(
      onPressed: () async {
        await _updateActivityTimestamp();
        // Navigate to FaceScanScreen based on label
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FaceScanScreen(
              type: label,
              cameras: widget.cameras,
              currentUser: widget.currentUser,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(double.infinity, double.infinity),
      ),
      child: Text(label),
    );
  }
}
