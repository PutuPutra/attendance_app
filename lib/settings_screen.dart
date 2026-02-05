import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'user_management_screen.dart';
import 'services/user_service.dart';

import '../models/user.dart';
import 'blocs/settings/settings_bloc.dart';
import 'blocs/settings/settings_state.dart';
import 'blocs/settings/settings_event.dart';

class FaceSavedScreen extends StatefulWidget {
  final User currentUser;

  const FaceSavedScreen({super.key, required this.currentUser});

  @override
  State<FaceSavedScreen> createState() => _FaceSavedScreenState();
}

class _FaceSavedScreenState extends State<FaceSavedScreen> {
  final UserService _userService = UserService();
  List<User> _usersWithFaces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsersWithFaces();
  }

  Future<void> _loadUsersWithFaces() async {
    setState(() => _isLoading = true);
    try {
      final users = await _userService.loadUsers();
      setState(() {
        _usersWithFaces = users
            .where(
              (user) =>
                  user.faceImagePath != null && user.faceEmbeddings != null,
            )
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading face data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          localizations.faceSaved,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_usersWithFaces.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.face, size: 16, color: theme.primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    '${_usersWithFaces.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _usersWithFaces.isEmpty
          ? _buildEmptyState(localizations, theme, isDarkMode)
          : _buildFaceGrid(localizations, theme, isDarkMode),
    );
  }

  Widget _buildEmptyState(
    AppLocalizations localizations,
    ThemeData theme,
    bool isDarkMode,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.face_retouching_off,
                size: 64,
                color: theme.primaryColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Face Data Saved',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Register your face first to enable biometric attendance',
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop(); // Pop FaceSavedScreen
                Navigator.of(
                  context,
                ).pop(); // Pop SettingsScreen to go to HomeScreen
              },
              icon: const Icon(Icons.arrow_back),
              label: Text(localizations.ok),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaceGrid(
    AppLocalizations localizations,
    ThemeData theme,
    bool isDarkMode,
  ) {
    return RefreshIndicator(
      onRefresh: _loadUsersWithFaces,
      color: theme.primaryColor,
      child: ListView.builder(
        itemCount: _usersWithFaces.length,
        itemBuilder: (context, index) {
          final user = _usersWithFaces[index];
          return _buildFaceItem(
            context,
            user,
            localizations,
            theme,
            isDarkMode,
          );
        },
      ),
    );
  }

  Widget _buildFaceItem(
    BuildContext context,
    User user,
    AppLocalizations localizations,
    ThemeData theme,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Face Image at top center
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: FileImage(File(user.faceImagePath!)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // User Info
          Text(
            'ID: ${user.id}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            user.faceName ?? user.username,
            style: TextStyle(
              fontSize: 16,
              color: theme.textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          // Delete Button
          ElevatedButton(
            onPressed: () =>
                _showDeleteFaceDialog(context, user, localizations, theme),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(localizations.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceCard(
    BuildContext context,
    User user,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Face Image (3:4 aspect ratio)
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                image: DecorationImage(
                  image: FileImage(File(user.faceImagePath!)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // User Info
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ID: ${user.id}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color ?? Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.faceName ?? user.username,
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          theme.textTheme.bodyMedium?.color ?? Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Delete Button
          Container(
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: TextButton.icon(
              onPressed: () =>
                  _showDeleteFaceDialog(context, user, localizations, theme),
              icon: const Icon(Icons.delete, size: 14, color: Colors.white),
              label: const Text(
                'Delete',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(double.infinity, 32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFaceDetails(
    BuildContext context,
    User user,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: FileImage(File(user.faceImagePath!)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.faceName ?? user.username,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          'ID: ${user.id}',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('User ID', user.id, theme),
                  _buildDetailRow('Username', user.username, theme),
                  _buildDetailRow('Role', user.role, theme),
                  _buildDetailRow(
                    'Face Embeddings',
                    '${user.faceEmbeddings?.length ?? 0} dimensions',
                    theme,
                  ),
                  _buildDetailRow('Registration Status', 'Active', theme),
                ],
              ),
            ),

            // Close Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(localizations.ok),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteFaceDialog(
    BuildContext context,
    User user,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: theme.dialogBackgroundColor,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Delete Face Data',
                  style: TextStyle(
                    color: theme.textTheme.titleLarge?.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete face data for "${user.faceName ?? user.username}"?\n\nThis action cannot be undone and will remove all biometric authentication data for this user.',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                localizations.cancel,
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await _deleteFaceData(user);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(localizations.delete),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteFaceData(User user) async {
    try {
      // Delete face image file - fix the path construction
      if (user.faceImagePath != null) {
        // The faceImagePath is stored as 'assets/face_images/filename.jpg'
        // We need to construct the full path to the documents directory
        final directory = await getApplicationDocumentsDirectory();
        final fullPath = user.faceImagePath!.startsWith('/')
            ? user.faceImagePath!
            : '${directory.path}/${user.faceImagePath}';

        final file = File(fullPath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('Deleted face image: $fullPath');
        } else {
          debugPrint('Face image not found: $fullPath');
        }
      }

      // Update user data
      final updatedUser = User(
        id: user.id,
        username: user.username,
        password: user.password,
        email: user.email,
        role: user.role,
        faceImagePath: null,
        faceEmbeddings: null,
        faceName: null,
      );
      await _userService.updateUser(user.id, updatedUser);

      // Refresh the list
      await _loadUsersWithFaces();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(child: Text('Face data deleted successfully')),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting face data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error deleting face data: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}

class SettingsScreen extends StatefulWidget {
  final User currentUser;
  final bool openChangePasswordDialog;

  const SettingsScreen({
    super.key,
    required this.currentUser,
    this.openChangePasswordDialog = false,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _selectedLanguage;
  late ThemeMode _selectedThemeMode;
  final List<String> _languages = ['System', 'Indonesia', 'English'];

  // Additional state for toggles and selections
  bool _biometricEnabled = false; // Toggle for password/biometric
  String _selectedFontStyle = 'app'; // Default to app
  final _userService = UserService();

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsBloc>().state as SettingsLoaded;
    // Map language code to language selection
    if (settings.language == 'system') {
      _selectedLanguage = 'System';
    } else if (settings.language == 'id') {
      _selectedLanguage = 'Indonesia';
    } else if (settings.language == 'en') {
      _selectedLanguage = 'English';
    } else {
      _selectedLanguage = 'System';
    }
    _selectedThemeMode = settings.themeMode;
    _selectedFontStyle = settings.fontStyle;
    _loadBiometricEnabled();
    if (widget.openChangePasswordDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showChangePasswordDialog(context);
      });
    }
  }

  Future<void> _loadBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _biometricEnabled = prefs.getBool('biometricEnabled') ?? false;
    });
  }

  String _getThemeKey(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  String _getLocalizedTheme(String key, AppLocalizations localizations) {
    switch (key) {
      case 'light':
        return localizations.lightTheme;
      case 'dark':
        return localizations.darkTheme;
      default:
        return localizations.systemTheme;
    }
  }

  void _changeLanguage(String language) {
    String langCode;
    if (language == 'System') {
      langCode = 'system';
    } else if (language == 'Indonesia') {
      langCode = 'id';
    } else {
      langCode = 'en';
    }
    context.read<SettingsBloc>().add(LanguageChanged(langCode));
    setState(() {
      _selectedLanguage = language;
    });
  }

  void _changeTheme(String key) {
    ThemeMode mode;
    switch (key) {
      case 'light':
        mode = ThemeMode.light;
        break;
      case 'dark':
        mode = ThemeMode.dark;
        break;
      default:
        mode = ThemeMode.system;
    }
    context.read<SettingsBloc>().add(ThemeChanged(mode));
    setState(() {
      _selectedThemeMode = mode;
    });
  }

  void _changeFontStyle(String font) {
    context.read<SettingsBloc>().add(FontStyleChanged(font));
    setState(() {
      _selectedFontStyle = font;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settingsTitle), // Assuming 'Pengaturan'
        elevation: 0, // To match flat iOS-like style
      ),
      body: ListView(
        children: [
          // const Divider(),
          // Face Data Section (adding a new section for face-related features)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              localizations.faceDataSection,
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
          ),
          ListTile(
            // leading: const Icon(Icons.face),
            title: Text(localizations.faceSaved),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      FaceSavedScreen(currentUser: widget.currentUser),
                ),
              );
            },
          ),
          ListTile(
            // leading: const Icon(Icons.download),
            title: Text(
              localizations.getSelectedFaceData,
            ), // Assuming this is a new or corrected item
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Handle get selected face data
              _showGetSelectedFaceDataDialog(context);
            },
          ),
          ListTile(
            // leading: const Icon(Icons.download),
            title: Text(localizations.getPersonalFaceData),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showGetDataDialog(context);
            },
          ),
          ListTile(
            // leading: const Icon(Icons.delete_forever),
            title: Text(localizations.clearAllFaceData),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showClearDataDialog(context);
            },
          ),
          const Divider(),

          // Personalization Section
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              localizations.personalizationSection,
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
          ),
          ListTile(
            title: Text(localizations.themeLabel),
            subtitle: Text(
              _getLocalizedTheme(
                _getThemeKey(_selectedThemeMode),
                localizations,
              ),
              style: TextStyle(color: Colors.red[700]),
            ),
            onTap: () {
              _showThemeSelectionDialog(context);
            },
          ),
          ListTile(
            title: Text(localizations.languageLabel),
            subtitle: Text(
              _selectedLanguage,
              style: TextStyle(color: Colors.red[700]),
            ),
            onTap: () {
              _showLanguageSelectionDialog(context);
            },
          ),
          ListTile(
            title: Text(localizations.fontStyle),
            subtitle: Text(
              _selectedFontStyle == 'system'
                  ? localizations.systemFont
                  : localizations.appFont,
              style: TextStyle(color: Colors.red[700]),
            ),
            onTap: () {
              _showFontStyleSelectionDialog(context);
            },
          ),
          const Divider(),

          // General Section
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              localizations.generalSection,
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
          ),
          ListTile(
            // leading: const Icon(Icons.lock),
            title: Text(localizations.changePassword),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showChangePasswordDialog(context);
            },
          ),
          SwitchListTile(
            title: Text(localizations.passwordOrBiometric),
            value: _biometricEnabled,
            onChanged: (bool value) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('biometricEnabled', value);
              setState(() {
                _biometricEnabled = value;
              });
            },
            activeColor: Colors.blue,
          ),

          const SizedBox(height: 16),

          // Version Info
          Center(
            child: Text(
              localizations.version,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showThemeSelectionDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final List<String> themeKeys = ['system', 'light', 'dark'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.selectTheme),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: themeKeys.map((key) {
              return RadioListTile<String>(
                title: Text(_getLocalizedTheme(key, localizations)),
                value: key,
                groupValue: _getThemeKey(_selectedThemeMode),
                onChanged: (String? value) {
                  if (value != null) {
                    _changeTheme(value);
                    Navigator.of(context).pop();
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showLanguageSelectionDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _languages.map((language) {
              return RadioListTile<String>(
                title: Text(language),
                value: language,
                groupValue: _selectedLanguage,
                onChanged: (String? value) {
                  if (value != null) {
                    _changeLanguage(value);
                    Navigator.of(context).pop();
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(localizations.changePassword),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: localizations.newPassword,
                    ),
                  ),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: localizations.confirmNewPassword,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(localizations.cancel),
                ),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final newPassword = newPasswordController.text.trim();
                          final confirmPassword = confirmPasswordController.text
                              .trim();

                          if (newPassword.isEmpty || confirmPassword.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  localizations.pleaseEnterUsernameAndPassword,
                                ),
                              ),
                            );
                            return;
                          }

                          if (newPassword != confirmPassword) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  localizations.passwordsDoNotMatch,
                                ),
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isLoading = true;
                          });

                          try {
                            final success = await _userService.changePassword(
                              widget.currentUser.id,
                              newPassword,
                            );

                            if (success) {
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    localizations.passwordChangedSuccessfully,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to change password'),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : Text(localizations.ok),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showFaceSavedDialog(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final users = await _userService.loadUsers();
    final usersWithFaces = users
        .where(
          (user) => user.faceImagePath != null && user.faceEmbeddings != null,
        )
        .toList();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.face, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          localizations.faceSaved,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${usersWithFaces.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: usersWithFaces.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.face_retouching_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No face data saved',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(16),
                          child: GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 3 / 4, // 3:4 aspect ratio
                                ),
                            itemCount: usersWithFaces.length,
                            itemBuilder: (context, index) {
                              final user = usersWithFaces[index];
                              return _buildFaceCard(
                                context,
                                user,
                                localizations,
                              );
                            },
                          ),
                        ),
                ),

                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          localizations.ok,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFaceCard(
    BuildContext context,
    User user,
    AppLocalizations localizations,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Face Image (3:4 aspect ratio)
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                image: DecorationImage(
                  image: FileImage(File(user.faceImagePath!)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // User Info
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ID: ${user.id}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.faceName ?? user.username,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Delete Button
          Container(
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: TextButton.icon(
              onPressed: () => _showDeleteFaceDialog(context, user),
              icon: const Icon(Icons.delete, size: 14, color: Colors.white),
              label: const Text(
                'Delete',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(double.infinity, 32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteFaceDialog(BuildContext context, User user) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('DeleteData'),
          content: Text(
            'Are you sure you want to delete face data for ${user.faceName ?? user.username}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () async {
                // Delete face image file
                if (user.faceImagePath != null) {
                  try {
                    final file = File(user.faceImagePath!);
                    if (await file.exists()) {
                      await file.delete();
                    }
                  } catch (e) {
                    // Ignore file deletion errors
                  }
                }

                // Update user data
                final updatedUser = user.copyWith(
                  faceImagePath: null,
                  faceEmbeddings: null,
                  faceName: null,
                );
                await _userService.updateUser(user.id, updatedUser);

                Navigator.of(context).pop(); // Close delete dialog
                Navigator.of(context).pop(); // Close face saved dialog

                // Reopen face saved dialog to refresh
                _showFaceSavedDialog(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Face data deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(
                localizations.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showGetSelectedFaceDataDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.getSelectedFaceData),
          content: Text(localizations.notImplemented),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.ok),
            ),
          ],
        );
      },
    );
  }

  void _showGetDataDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.getPersonalFaceData),
          content: Text(localizations.notImplemented),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.ok),
            ),
          ],
        );
      },
    );
  }

  void _showClearDataDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.clearAllFaceData),
          content: Text(localizations.confirmDelete),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () {
                // Handle clear data logic here
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(localizations.dataDeleted)),
                );
              },
              child: Text(localizations.delete),
            ),
          ],
        );
      },
    );
  }

  void _showFontStyleSelectionDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Font Style'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['system', 'app'].map((font) {
              return RadioListTile<String>(
                title: Text(
                  font == 'system'
                      ? localizations.systemFont
                      : localizations.appFont,
                ),
                value: font,
                groupValue: _selectedFontStyle,
                onChanged: (String? value) {
                  if (value != null) {
                    _changeFontStyle(value);
                    Navigator.of(context).pop();
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
