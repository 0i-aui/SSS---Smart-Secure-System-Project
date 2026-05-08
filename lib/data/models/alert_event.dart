// lib/data/models/alert_event.dart
import 'dart:convert';
import '../../core/constants/app_constants.dart';

class AlertEvent {
  final String id;
  final AlertType type;
  final DateTime timestamp;
  final String rawMessage;

  AlertEvent({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.rawMessage,
  });

  String get title => type == AlertType.motion ? 'Motion Detected' : 'Smoke Alert';

  String get description =>
      type == AlertType.motion
          ? 'PIR sensor triggered — intruder motion detected'
          : 'MQ-2 sensor triggered — smoke/gas detected';

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    'rawMessage': rawMessage,
  };

  factory AlertEvent.fromJson(Map<String, dynamic> json) => AlertEvent(
    id: json['id'] as String,
    type: AlertType.values.firstWhere((e) => e.name == json['type']),
    timestamp: DateTime.parse(json['timestamp'] as String),
    rawMessage: json['rawMessage'] as String,
  );

  static List<AlertEvent> listFromJsonString(String jsonStr) {
    if (jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => AlertEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static String listToJsonString(List<AlertEvent> events) {
    return jsonEncode(events.map((e) => e.toJson()).toList());
  }
}
