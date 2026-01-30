import 'dart:async';
import 'package:flutter/material.dart';
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

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Function(ThemeMode) onThemeChanged;
  final Function(String) onLanguageChanged;
  final ThemeMode currentThemeMode;
  final String currentLanguage;
  final User currentUser;

  const HomeScreen({
    super.key,
    required this.cameras,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    required this.currentThemeMode,
    required this.currentLanguage,
    required this.currentUser,
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
    if (widget.currentUser.role == 'admin') {
      _loadAllUsers();
    }
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
        builder: (_) => LoginScreen(
          cameras: widget.cameras,
          onThemeChanged: widget.onThemeChanged,
          onLanguageChanged: widget.onLanguageChanged,
          currentThemeMode: widget.currentThemeMode,
          currentLanguage: widget.currentLanguage,
        ),
      ),
      (route) => false,
    );
  }

  Future<void> _loadAllUsers() async {
    final userService = UserService();
    _allUsers = await userService.loadUsers();
    setState(() {});
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
                padding: const EdgeInsets.only(
                  top: 40,
                  bottom: 40,
                  left: 16,
                  right: 16,
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(
                        'assets/profile_placeholder.png',
                      ),
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
                            builder: (_) => SettingsScreen(
                              onThemeChanged: widget.onThemeChanged,
                              onLanguageChanged: widget.onLanguageChanged,
                              currentThemeMode: widget.currentThemeMode,
                              currentLanguage: widget.currentLanguage,
                              currentUser: widget.currentUser,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: _logout,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 2,
                  color: isDarkMode ? Colors.grey[800] : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          localizations.liveAttendance,
                          style: TextStyle(color: onSurfaceColor, fontSize: 14),
                        ),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            color: onSurfaceColor,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(color: onSurfaceColor, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 1,
                          color: onSurfaceColor.withOpacity(0.1),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          localizations.officeHours,
                          style: TextStyle(color: onSurfaceColor, fontSize: 14),
                        ),
                        Text(
                          localizations.officeHoursTime,
                          style: TextStyle(color: onSurfaceColor, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildButton(localizations.checkIn, Colors.blue),
                            _buildButton(localizations.breakTime, Colors.blue),
                            _buildButton(
                              localizations.returnToWork,
                              Colors.blue,
                            ),
                            _buildButton(localizations.checkOut, Colors.blue),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.currentUser.role == 'admin')
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30.0,
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
                                          builder: (_) =>
                                              const UserManagementScreen(),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.people,
                                            size: 40,
                                            color: onSurfaceColor,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'User Management',
                                            style: TextStyle(
                                              color: onSurfaceColor,
                                              fontSize: 16,
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
                                            size: 40,
                                            color: onSurfaceColor,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'All Employee History',
                                            style: TextStyle(
                                              color: onSurfaceColor,
                                              fontSize: 16,
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

  Widget _buildButton(String label, Color color) {
    return ElevatedButton(
      onPressed: () {
        // Navigate to FaceScanScreen based on label
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                FaceScanScreen(type: label, cameras: widget.cameras),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(80, 36),
      ),
      child: Text(label),
    );
  }
}
