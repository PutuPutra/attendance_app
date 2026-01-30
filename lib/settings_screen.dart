import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'user_management_screen.dart';

import '../models/user.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final Function(String) onLanguageChanged;
  final ThemeMode currentThemeMode;
  final String currentLanguage;
  final User currentUser;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    required this.currentThemeMode,
    required this.currentLanguage,
    required this.currentUser,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _selectedLanguage;
  late ThemeMode _selectedThemeMode;
  final List<String> _languages = ['System', 'Indonesia', 'English'];
  final List<String> _themeOptions = ['System', 'Light', 'Dark'];

  // Additional state for toggles and selections
  bool _biometricEnabled = false; // Toggle for password/biometric

  @override
  void initState() {
    super.initState();
    // Map language code to language selection
    if (widget.currentLanguage == 'system') {
      _selectedLanguage = 'System';
    } else if (widget.currentLanguage == 'id') {
      _selectedLanguage = 'Indonesia';
    } else if (widget.currentLanguage == 'en') {
      _selectedLanguage = 'English';
    } else {
      _selectedLanguage = 'System';
    }
    _selectedThemeMode = widget.currentThemeMode;
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
    widget.onLanguageChanged(langCode);
    setState(() {
      _selectedLanguage = language;
    });
  }

  void _changeTheme(String theme) {
    ThemeMode mode;
    switch (theme) {
      case 'Light':
        mode = ThemeMode.light;
        break;
      case 'Dark':
        mode = ThemeMode.dark;
        break;
      default:
        mode = ThemeMode.system;
    }
    widget.onThemeChanged(mode);
    setState(() {
      _selectedThemeMode = mode;
    });
  }

  String get _currentTheme {
    switch (_selectedThemeMode) {
      case ThemeMode.light:
        return 'Terang';
      case ThemeMode.dark:
        return 'Gelap';
      default:
        return 'System';
    }
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
          // Account Section
          // ListTile(
          //   title: Text('Akun Sagaku'),
          //   subtitle: Text(
          //     'putuputrae@gmail.com',
          //     style: TextStyle(color: Colors.red[700]),
          //   ),
          // ),
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
              _showFaceSavedDialog(context);
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
              _currentTheme,
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
            onChanged: (bool value) {
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
        ],
      ),
    );
  }

  void _showThemeSelectionDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.selectTheme),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _themeOptions.map((theme) {
              return RadioListTile<String>(
                title: Text(theme),
                value: theme,
                groupValue: _currentTheme == 'Terang'
                    ? 'Light'
                    : _currentTheme == 'Gelap'
                    ? 'Dark'
                    : 'System',
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.changePassword),
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

  void _showFaceSavedDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.faceSaved),
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
}
