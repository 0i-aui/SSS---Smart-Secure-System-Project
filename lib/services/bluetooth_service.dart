// lib/services/bluetooth_service.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../core/constants/app_constants.dart';

class BluetoothService extends ChangeNotifier {
  // Connection state
  ConnectionStatus _status = ConnectionStatus.disconnected;
  BluetoothConnection? _connection;
  BluetoothDevice? _connectedDevice;
  String _statusMessage = 'Not connected';
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  bool _autoReconnect = true;

  // Data stream
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();
  Stream<String> get messageStream => _messageController.stream;

  // Buffer for partial messages
  String _buffer = '';

  // Getters
  ConnectionStatus get status => _status;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  String get statusMessage => _statusMessage;
  bool get isConnected => _status == ConnectionStatus.connected;

  void setAutoReconnect(bool value) {
    _autoReconnect = value;
    if (!value) _cancelReconnect();
  }

  // --- Get paired devices ---
  Future<List<BluetoothDevice>> getPairedDevices() async {
    try {
      final devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      return devices;
    } catch (e) {
      debugPrint('[BT] Error getting paired devices: $e');
      return [];
    }
  }

  // --- Connect to device ---
  Future<bool> connectToDevice(BluetoothDevice device) async {
    if (_status == ConnectionStatus.connecting) return false;

    _setStatus(ConnectionStatus.connecting, 'Connecting to ${device.name}...');
    _cancelReconnect();

    try {
      final connection = await BluetoothConnection.toAddress(device.address)
          .timeout(
            const Duration(milliseconds: AppConstants.btConnectTimeoutMs),
            onTimeout: () => throw TimeoutException('Connection timed out'),
          );

      _connection = connection;
      _connectedDevice = device;
      _reconnectAttempts = 0;
      _setStatus(
        ConnectionStatus.connected,
        'Connected to ${device.name ?? device.address}',
      );

      _listenToData();
      return true;
    } on TimeoutException {
      _setStatus(ConnectionStatus.error, 'Connection timed out');
      _scheduleReconnect(device);
      return false;
    } catch (e) {
      debugPrint('[BT] Connection error: $e');
      _setStatus(ConnectionStatus.error, 'Connection failed');
      _scheduleReconnect(device);
      return false;
    }
  }

  // --- Listen to incoming serial data ---
  void _listenToData() {
    _connection?.input?.listen(
      (Uint8List data) {
        final incoming = String.fromCharCodes(data);
        _buffer += incoming;

        // Parse newline-delimited messages
        while (_buffer.contains('\n')) {
          final idx = _buffer.indexOf('\n');
          final line = _buffer.substring(0, idx).trim();
          _buffer = _buffer.substring(idx + 1);

          if (line.isNotEmpty) {
            debugPrint('[BT] Received: $line');
            _messageController.add(line);
          }
        }
        // Also check without newline for single-line bursts
        if (_buffer.contains(AppConstants.msgMotion) ||
            _buffer.contains(AppConstants.msgSmoke) ||
            _buffer.contains(AppConstants.msgNormal)) {
          final trimmed = _buffer.trim();
          _buffer = '';
          if (trimmed.isNotEmpty) {
            debugPrint('[BT] Received (no newline): $trimmed');
            _messageController.add(trimmed);
          }
        }
      },
      onDone: () {
        debugPrint('[BT] Connection closed by remote device');
        _handleDisconnect();
      },
      onError: (Object error) {
        debugPrint('[BT] Stream error: $error');
        _handleDisconnect();
      },
      cancelOnError: true,
    );
  }

  // --- Handle unexpected disconnect ---
  void _handleDisconnect() {
    final device = _connectedDevice;
    _connection = null;
    _buffer = '';
    _setStatus(ConnectionStatus.disconnected, 'Disconnected');

    if (_autoReconnect && device != null) {
      _scheduleReconnect(device);
    }
  }

  // --- Reconnect logic ---
  void _scheduleReconnect(BluetoothDevice device) {
    if (!_autoReconnect) return;
    if (_reconnectAttempts >= AppConstants.maxReconnectAttempts) {
      _setStatus(ConnectionStatus.error, 'Max reconnect attempts reached');
      _reconnectAttempts = 0;
      return;
    }

    _reconnectAttempts++;
    _setStatus(
      ConnectionStatus.connecting,
      'Reconnecting... (attempt $_reconnectAttempts)',
    );

    _reconnectTimer = Timer(
      const Duration(milliseconds: AppConstants.btReconnectDelayMs),
      () => connectToDevice(device),
    );
  }

  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  // --- Disconnect ---
  Future<void> disconnect() async {
    _cancelReconnect();
    _autoReconnect = false;

    try {
      await _connection?.close();
    } catch (_) {}

    _connection = null;
    _connectedDevice = null;
    _buffer = '';
    _reconnectAttempts = 0;
    _setStatus(ConnectionStatus.disconnected, 'Disconnected');
  }

  // --- Send data to Arduino ---
  Future<void> sendMessage(String msg) async {
    if (_connection == null || !isConnected) return;
    try {
      _connection!.output.add(Uint8List.fromList('$msg\n'.codeUnits));
      await _connection!.output.allSent;
    } catch (e) {
      debugPrint('[BT] Send error: $e');
    }
  }

  void _setStatus(ConnectionStatus status, String message) {
    _status = status;
    _statusMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelReconnect();
    _messageController.close();
    _connection?.close();
    super.dispose();
  }
}
