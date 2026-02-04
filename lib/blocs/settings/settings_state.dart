import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final ThemeMode themeMode;
  final String language;
  final bool biometricEnabled;
  final String fontStyle;

  const SettingsLoaded({
    required this.themeMode,
    required this.language,
    required this.biometricEnabled,
    required this.fontStyle,
  });

  @override
  List<Object> get props => [themeMode, language, biometricEnabled, fontStyle];
}
