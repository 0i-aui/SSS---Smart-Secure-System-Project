// lib/services/permission_service.dart
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class PermissionService {
  static Future<bool> requestBluetoothPermissions() async {
    try {
      // Android 12+ requires BLUETOOTH_CONNECT and BLUETOOTH_SCAN
      // Android < 12 requires ACCESS_FINE_LOCATION
      final statuses = await [
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.location,
      ].request();

      final allGranted = statuses.values.every(
        (s) => s == PermissionStatus.granted || s == PermissionStatus.limited,
      );

      if (!allGranted) {
        debugPrint('[Permissions] Some permissions denied: $statuses');
      }

      return allGranted;
    } catch (e) {
      debugPrint('[Permissions] Error requesting permissions: $e');
      return false;
    }
  }

  static Future<bool> checkBluetoothEnabled() async {
    try {
      final status = await Permission.bluetooth.status;
      return status == PermissionStatus.granted;
    } catch (_) {
      return false;
    }
  }
}
