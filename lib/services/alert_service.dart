// lib/services/alert_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import '../core/constants/app_constants.dart';
import '../data/models/alert_event.dart';
import '../data/repositories/settings_repository.dart';
import 'bluetooth_service.dart';

class AlertService extends ChangeNotifier {
  final BluetoothService _bluetoothService;
  final SettingsRepository _repo;

  StreamSubscription<String>? _btSubscription;

  SystemStatus _systemStatus = SystemStatus.normal;
  AlertEvent? _activeMotionAlert;
  AlertEvent? _activeSmokeAlert;
  List<AlertEvent> _history = [];
  Timer? _motionClearTimer;
  Timer? _smokeClearTimer;

  bool _vibrationEnabled = true;
  bool _soundEnabled = true;

  AlertService({
    required BluetoothService bluetoothService,
    required SettingsRepository repo,
  })  : _bluetoothService = bluetoothService,
        _repo = repo {
    _history = repo.loadHistory();
    final settings = repo.loadSettings();
    _vibrationEnabled = settings.vibrationEnabled;
    _soundEnabled = settings.soundEnabled;
    _startListening();
  }

  // Getters
  SystemStatus get systemStatus => _systemStatus;
  AlertEvent? get activeMotionAlert => _activeMotionAlert;
  AlertEvent? get activeSmokeAlert => _activeSmokeAlert;
  List<AlertEvent> get history => List.unmodifiable(_history);
  bool get vibrationEnabled => _vibrationEnabled;
  bool get soundEnabled => _soundEnabled;

  void setVibration(bool value) {
    _vibrationEnabled = value;
    notifyListeners();
  }

  void setSoundEnabled(bool value) {
    _soundEnabled = value;
    notifyListeners();
  }

  void _startListening() {
    _btSubscription = _bluetoothService.messageStream.listen(_onMessage);
  }

  void _onMessage(String message) {
    final upper = message.toUpperCase().trim();

    if (upper.contains(AppConstants.msgMotion)) {
      _triggerMotionAlert(message);
    } else if (upper.contains(AppConstants.msgSmoke)) {
      _triggerSmokeAlert(message);
    } else if (upper.contains(AppConstants.msgNormal) ||
        upper.contains(AppConstants.msgClear)) {
      _clearAlerts();
    }
  }

  void _triggerMotionAlert(String raw) {
    _motionClearTimer?.cancel();

    final event = AlertEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: AlertType.motion,
      timestamp: DateTime.now(),
      rawMessage: raw,
    );

    _activeMotionAlert = event;
    _addToHistory(event);

    if (_systemStatus != SystemStatus.smoke) {
      _systemStatus = SystemStatus.motion;
    }

    _vibrateMotion();
    notifyListeners();

    // Auto-clear motion after 30 seconds
    _motionClearTimer = Timer(AppConstants.alertClearDuration, () {
      if (_activeMotionAlert?.id == event.id) {
        _activeMotionAlert = null;
        if (_activeSmokeAlert == null) {
          _systemStatus = SystemStatus.normal;
        }
        notifyListeners();
      }
    });
  }

  void _triggerSmokeAlert(String raw) {
    _smokeClearTimer?.cancel();

    final event = AlertEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: AlertType.smoke,
      timestamp: DateTime.now(),
      rawMessage: raw,
    );

    _activeSmokeAlert = event;
    _addToHistory(event);
    _systemStatus = SystemStatus.smoke;

    _vibrateSmoke();
    notifyListeners();

    // Auto-clear smoke after 30 seconds
    _smokeClearTimer = Timer(AppConstants.alertClearDuration, () {
      if (_activeSmokeAlert?.id == event.id) {
        _activeSmokeAlert = null;
        if (_activeMotionAlert == null) {
          _systemStatus = SystemStatus.normal;
        } else {
          _systemStatus = SystemStatus.motion;
        }
        notifyListeners();
      }
    });
  }

  void _clearAlerts() {
    _motionClearTimer?.cancel();
    _smokeClearTimer?.cancel();
    _activeMotionAlert = null;
    _activeSmokeAlert = null;
    _systemStatus = SystemStatus.normal;
    notifyListeners();
  }

  void _addToHistory(AlertEvent event) {
    _history.insert(0, event);
    if (_history.length > AppConstants.maxHistoryItems) {
      _history = _history.sublist(0, AppConstants.maxHistoryItems);
    }
    _repo.saveHistory(_history);
  }

  Future<void> clearHistory() async {
    _history = [];
    await _repo.clearHistory();
    notifyListeners();
  }

  Future<void> _vibrateMotion() async {
    if (!_vibrationEnabled) return;
    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        await Vibration.vibrate(pattern: AppConstants.vibrationMotion);
      }
    } catch (e) {
      debugPrint('[Alert] Vibration error: $e');
    }
  }

  Future<void> _vibrateSmoke() async {
    if (!_vibrationEnabled) return;
    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        await Vibration.vibrate(pattern: AppConstants.vibrationSmoke);
      }
    } catch (e) {
      debugPrint('[Alert] Vibration error: $e');
    }
  }

  @override
  void dispose() {
    _btSubscription?.cancel();
    _motionClearTimer?.cancel();
    _smokeClearTimer?.cancel();
    super.dispose();
  }
}
