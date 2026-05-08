// lib/core/constants/app_constants.dart

class AppConstants {
  // Bluetooth
  static const String hc05Name = 'HC-05';
  static const int btConnectTimeoutMs = 10000;
  static const int btReconnectDelayMs = 3000;
  static const int maxReconnectAttempts = 5;

  // Arduino message tokens
  static const String msgMotion = 'MOTION DETECTED';
  static const String msgSmoke = 'SMOKE ALERT';
  static const String msgNormal = 'SYSTEM NORMAL';
  static const String msgClear = 'ALL CLEAR';

  // SharedPreferences keys
  static const String prefVibration = 'vibration_enabled';
  static const String prefSound = 'sound_enabled';
  static const String prefAutoReconnect = 'auto_reconnect';
  static const String prefAlertHistory = 'alert_history';
  static const String prefLastDeviceAddress = 'last_device_address';

  // UI
  static const int maxHistoryItems = 200;
  static const Duration alertClearDuration = Duration(seconds: 30);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 400);
  static const Duration animationSlow = Duration(milliseconds: 800);

  // Vibration patterns (ms)
  static const List<int> vibrationMotion = [0, 200, 100, 200];
  static const List<int> vibrationSmoke = [0, 500, 100, 500, 100, 500];
}

enum AlertType { motion, smoke }
enum ConnectionStatus { disconnected, connecting, connected, error }
enum SystemStatus { normal, motion, smoke }
