// lib/presentation/screens/bluetooth/bluetooth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/bluetooth_service.dart';
import '../../../services/permission_service.dart';
import '../../widgets/common/neon_card.dart';
import '../../widgets/status/system_status_widget.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen>
    with SingleTickerProviderStateMixin {
  List<BluetoothDevice> _devices = [];
  bool _isLoading = false;
  bool _permissionsGranted = false;
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _requestPermissionsAndLoad();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissionsAndLoad() async {
    final granted = await PermissionService.requestBluetoothPermissions();
    if (mounted) {
      setState(() => _permissionsGranted = granted);
      if (granted) _loadPairedDevices();
    }
  }

  Future<void> _loadPairedDevices() async {
    setState(() => _isLoading = true);
    _scanController.repeat();

    final bt = context.read<BluetoothService>();
    final devices = await bt.getPairedDevices();

    if (mounted) {
      setState(() {
        _devices = devices;
        _isLoading = false;
      });
      _scanController.stop();
      _scanController.reset();
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    final bt = context.read<BluetoothService>();
    await bt.connectToDevice(device);
  }

  @override
  Widget build(BuildContext context) {
    final bt = context.watch<BluetoothService>();

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        title: const Text('BLUETOOTH'),
        actions: [
          if (_permissionsGranted)
            IconButton(
              icon: AnimatedBuilder(
                animation: _scanController,
                builder: (_, child) => Transform.rotate(
                  angle: _scanController.value * 6.28,
                  child: child,
                ),
                child: const Icon(Icons.refresh, color: AppColors.neonBlue),
              ),
              onPressed: _isLoading ? null : _loadPairedDevices,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: Column(
        children: [
          // Connection status bar
          _buildConnectionHeader(bt),
          // Device list
          Expanded(
            child: !_permissionsGranted
                ? _buildPermissionDenied()
                : _buildDeviceList(bt),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionHeader(BluetoothService bt) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: NeonCard(
        borderColor: bt.isConnected
            ? AppColors.statusGreen
            : AppColors.borderSubtle,
        glowColor: bt.isConnected ? AppColors.statusGreenGlow : null,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (bt.isConnected
                        ? AppColors.statusGreen
                        : AppColors.textMuted)
                    .withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                bt.isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                color: bt.isConnected
                    ? AppColors.statusGreen
                    : AppColors.textMuted,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bt.isConnected ? 'CONNECTED' : 'NOT CONNECTED',
                    style: TextStyle(
                      color: bt.isConnected
                          ? AppColors.statusGreen
                          : AppColors.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bt.statusMessage,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            if (bt.isConnected)
              TextButton(
                onPressed: () async {
                  await context.read<BluetoothService>().disconnect();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.alertRed,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text(
                  'DISCONNECT',
                  style: TextStyle(fontSize: 11, letterSpacing: 1.0),
                ),
              ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bluetooth_disabled,
              color: AppColors.alertRed,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'PERMISSIONS REQUIRED',
              style: TextStyle(
                color: AppColors.alertRed,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bluetooth and Location permissions are required to scan for devices.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _CyberButton(
              label: 'GRANT PERMISSIONS',
              onPressed: _requestPermissionsAndLoad,
              color: AppColors.neonBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList(BluetoothService bt) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ScanningAnimation(),
            const SizedBox(height: 20),
            Text(
              'SCANNING FOR DEVICES...',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.neonBlue,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      );
    }

    if (_devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bluetooth_searching,
              color: AppColors.textMuted,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'NO PAIRED DEVICES',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pair your HC-05 module in Android Bluetooth settings first.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _CyberButton(
              label: 'REFRESH',
              onPressed: _loadPairedDevices,
              color: AppColors.neonBlue,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _devices.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SectionHeader(title: 'Paired devices (${_devices.length})'),
          );
        }

        final device = _devices[index - 1];
        final isHC05 = (device.name ?? '').toUpperCase().contains('HC-05') ||
            (device.name ?? '').toUpperCase().contains('HC05');
        final isConnected = bt.connectedDevice?.address == device.address;

        return _DeviceTile(
          device: device,
          isHC05: isHC05,
          isConnected: isConnected,
          connectionStatus: bt.status,
          onConnect: () => _connectToDevice(device),
          onDisconnect: () => context.read<BluetoothService>().disconnect(),
        ).animate(delay: (index * 60).ms).fadeIn().slideX(begin: 0.15, end: 0);
      },
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final BluetoothDevice device;
  final bool isHC05;
  final bool isConnected;
  final ConnectionStatus connectionStatus;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const _DeviceTile({
    required this.device,
    required this.isHC05,
    required this.isConnected,
    required this.connectionStatus,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isConnected
        ? AppColors.statusGreen
        : isHC05
            ? AppColors.neonBlue
            : AppColors.borderSubtle;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: isHC05 ? 1.5 : 1),
        boxShadow: isHC05
            ? [BoxShadow(color: AppColors.neonBlueGlow, blurRadius: 8)]
            : null,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: (isConnected
                    ? AppColors.statusGreen
                    : isHC05
                        ? AppColors.neonBlue
                        : AppColors.textMuted)
                .withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
            color: isConnected
                ? AppColors.statusGreen
                : isHC05
                    ? AppColors.neonBlue
                    : AppColors.textMuted,
            size: 22,
          ),
        ),
        title: Row(
          children: [
            Text(
              device.name ?? 'Unknown Device',
              style: TextStyle(
                color: isHC05 ? AppColors.neonBlue : AppColors.textPrimary,
                fontWeight:
                    isHC05 ? FontWeight.w700 : FontWeight.w500,
                fontSize: 15,
              ),
            ),
            if (isHC05) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.neonBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'HC-05',
                  style: TextStyle(
                    color: AppColors.neonBlue,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          device.address,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(fontSize: 11),
        ),
        trailing: isConnected
            ? TextButton(
                onPressed: onDisconnect,
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.alertRed),
                child: const Text('DISCONNECT',
                    style: TextStyle(fontSize: 10)),
              )
            : _CyberButton(
                label: 'CONNECT',
                onPressed: connectionStatus == ConnectionStatus.connecting
                    ? null
                    : onConnect,
                color: AppColors.neonBlue,
                compact: true,
              ),
      ),
    );
  }
}

class _CyberButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final bool compact;

  const _CyberButton({
    required this.label,
    required this.onPressed,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 20,
          vertical: compact ? 6 : 12,
        ),
        decoration: BoxDecoration(
          color: onPressed == null
              ? color.withOpacity(0.05)
              : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: onPressed == null
                ? color.withOpacity(0.2)
                : color.withOpacity(0.6),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: onPressed == null
                ? color.withOpacity(0.4)
                : color,
            fontSize: compact ? 11 : 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

class _ScanningAnimation extends StatefulWidget {
  @override
  State<_ScanningAnimation> createState() => _ScanningAnimationState();
}

class _ScanningAnimationState extends State<_ScanningAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          for (int i = 0; i < 3; i++)
            Container(
              width: 60 + i * 30.0,
              height: 60 + i * 30.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.neonBlue.withOpacity(
                    (1 - _ctrl.value) * (1.0 - i * 0.25),
                  ),
                  width: 1.5,
                ),
              ),
            ),
          const Icon(
            Icons.bluetooth_searching,
            color: AppColors.neonBlue,
            size: 36,
          ),
        ],
      ),
    );
  }
}
