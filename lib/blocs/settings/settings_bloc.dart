import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitial()) {
    on<ThemeChanged>(_onThemeChanged);
    on<LanguageChanged>(_onLanguageChanged);
    on<BiometricToggled>(_onBiometricToggled);
    on<FontStyleChanged>(_onFontStyleChanged);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    final language = prefs.getString('language') ?? 'system';
    final biometricEnabled = prefs.getBool('biometricEnabled') ?? false;
    final fontStyle = prefs.getString('fontStyle') ?? 'app';

    emit(
      SettingsLoaded(
        themeMode: ThemeMode.values[themeIndex],
        language: language,
        biometricEnabled: biometricEnabled,
        fontStyle: fontStyle,
      ),
    );
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', event.themeMode.index);

    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(
        SettingsLoaded(
          themeMode: event.themeMode,
          language: currentState.language,
          biometricEnabled: currentState.biometricEnabled,
          fontStyle: currentState.fontStyle,
        ),
      );
    }
  }

  Future<void> _onLanguageChanged(
    LanguageChanged event,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', event.language);

    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(
        SettingsLoaded(
          themeMode: currentState.themeMode,
          language: event.language,
          biometricEnabled: currentState.biometricEnabled,
          fontStyle: currentState.fontStyle,
        ),
      );
    }
  }

  Future<void> _onBiometricToggled(
    BiometricToggled event,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometricEnabled', event.enabled);

    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(
        SettingsLoaded(
          themeMode: currentState.themeMode,
          language: currentState.language,
          biometricEnabled: event.enabled,
          fontStyle: currentState.fontStyle,
        ),
      );
    }
  }

  Future<void> _onFontStyleChanged(
    FontStyleChanged event,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontStyle', event.fontStyle);

    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(
        SettingsLoaded(
          themeMode: currentState.themeMode,
          language: currentState.language,
          biometricEnabled: currentState.biometricEnabled,
          fontStyle: event.fontStyle,
        ),
      );
    }
  }
}
