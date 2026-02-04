import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class ThemeChanged extends SettingsEvent {
  final ThemeMode themeMode;

  const ThemeChanged(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}

class LanguageChanged extends SettingsEvent {
  final String language;

  const LanguageChanged(this.language);

  @override
  List<Object> get props => [language];
}

class BiometricToggled extends SettingsEvent {
  final bool enabled;

  const BiometricToggled(this.enabled);

  @override
  List<Object> get props => [enabled];
}

class FontStyleChanged extends SettingsEvent {
  final String fontStyle;

  const FontStyleChanged(this.fontStyle);

  @override
  List<Object> get props => [fontStyle];
}
