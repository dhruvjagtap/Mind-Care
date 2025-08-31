// import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum for theme modes
enum AppThemeMode { system, light, dark }

/// Riverpod provider to hold the current theme mode
final themeModeProvider = StateProvider<AppThemeMode>((ref) {
  return AppThemeMode.system; // default
});
