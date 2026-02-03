import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'user_management_screen.dart';
import 'services/user_service.dart';

import '../models/user.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final Function(String) onLanguageChanged;
  final ThemeMode currentThemeMode;
  final String currentLanguage;
  final User currentUser;
  final bool openChangePasswordDialog;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    required this.currentThemeMode,
    required this.currentLanguage,
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
  late String _selectedFontStyle;
  final _userService = UserService();

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
    _loadBiometricEnabled();
    _loadFontStyle();
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

  Future<void> _loadFontStyle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedFontStyle = prefs.getString('fontStyle') ?? 'system';
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
    widget.onLanguageChanged(langCode);
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
    widget.onThemeChanged(mode);
    setState(() {
      _selectedThemeMode = mode;
    });
  }

  void _changeFontStyle(String font) {
    final prefs = SharedPreferences.getInstance();
    prefs.then((p) => p.setString('fontStyle', font));
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
