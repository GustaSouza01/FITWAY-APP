import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

enum AppThemeStyle { blue, pink }

enum AppThemeModePreference { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  AppThemeStyle _style = AppThemeStyle.blue;
  AppThemeModePreference _modePreference = AppThemeModePreference.dark;

  AppThemeStyle get style => _style;
  AppThemeModePreference get modePreference => _modePreference;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final styleIndex = prefs.getInt('theme_style') ?? 0;
    final modeIndex = prefs.getInt('theme_mode') ?? 1;
    _style = AppThemeStyle
        .values[styleIndex.clamp(0, AppThemeStyle.values.length - 1)];
    _modePreference = AppThemeModePreference
        .values[modeIndex.clamp(0, AppThemeModePreference.values.length - 1)];
    notifyListeners();
  }

  Future<void> setThemeStyle(AppThemeStyle style) async {
    _style = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_style', style.index);
    notifyListeners();
  }

  Future<void> setThemeModePreference(AppThemeModePreference mode) async {
    _modePreference = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  ThemeMode get themeMode {
    switch (_modePreference) {
      case AppThemeModePreference.light:
        return ThemeMode.light;
      case AppThemeModePreference.dark:
        return ThemeMode.dark;
      case AppThemeModePreference.system:
        return ThemeMode.system;
    }
  }

  Color get primaryColor => _style == AppThemeStyle.blue
      ? AppColors.primaryBlue
      : AppColors.primaryPink;

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor,
        surface: AppColors.lightCard,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: Color(0xFF0F172A),
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightCard,
        indicatorColor: primaryColor.withValues(alpha: 0.14),
      ),
      textTheme: ThemeData.light().textTheme.apply(
            bodyColor: const Color(0xFF0F172A),
            displayColor: const Color(0xFF0F172A),
          ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: AppColors.darkCard,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkCard,
        indicatorColor: primaryColor.withValues(alpha: 0.18),
      ),
      textTheme: ThemeData.dark().textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
    );
  }
}
