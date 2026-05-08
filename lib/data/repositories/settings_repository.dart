// lib/data/repositories/settings_repository.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/alert_event.dart';
import '../../core/constants/app_constants.dart';

class SettingsRepository {
  static SettingsRepository? _instance;
  late SharedPreferences _prefs;

  SettingsRepository._();

  static Future<SettingsRepository> getInstance() async {
    if (_instance == null) {
      _instance = SettingsRepository._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // --- Settings ---
  AppSettings loadSettings() {
    return AppSettings(
      vibrationEnabled: _prefs.getBool(AppConstants.prefVibration) ?? true,
      soundEnabled: _prefs.getBool(AppConstants.prefSound) ?? true,
      autoReconnect: _prefs.getBool(AppConstants.prefAutoReconnect) ?? true,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setBool(AppConstants.prefVibration, settings.vibrationEnabled);
    await _prefs.setBool(AppConstants.prefSound, settings.soundEnabled);
    await _prefs.setBool(AppConstants.prefAutoReconnect, settings.autoReconnect);
  }

  // --- Alert History ---
  List<AlertEvent> loadHistory() {
    final jsonStr = _prefs.getString(AppConstants.prefAlertHistory) ?? '';
    return AlertEvent.listFromJsonString(jsonStr);
  }

  Future<void> saveHistory(List<AlertEvent> events) async {
    final trimmed = events.take(AppConstants.maxHistoryItems).toList();
    await _prefs.setString(
      AppConstants.prefAlertHistory,
      AlertEvent.listToJsonString(trimmed),
    );
  }

  Future<void> clearHistory() async {
    await _prefs.remove(AppConstants.prefAlertHistory);
  }

  // --- Last Device ---
  String? getLastDeviceAddress() {
    return _prefs.getString(AppConstants.prefLastDeviceAddress);
  }

  Future<void> saveLastDeviceAddress(String address) async {
    await _prefs.setString(AppConstants.prefLastDeviceAddress, address);
  }
}
