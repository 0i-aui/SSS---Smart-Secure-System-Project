// lib/data/models/app_settings.dart

class AppSettings {
  final bool vibrationEnabled;
  final bool soundEnabled;
  final bool autoReconnect;

  const AppSettings({
    this.vibrationEnabled = true,
    this.soundEnabled = true,
    this.autoReconnect = true,
  });

  AppSettings copyWith({
    bool? vibrationEnabled,
    bool? soundEnabled,
    bool? autoReconnect,
  }) {
    return AppSettings(
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      autoReconnect: autoReconnect ?? this.autoReconnect,
    );
  }
}
