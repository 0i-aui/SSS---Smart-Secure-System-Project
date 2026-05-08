// lib/presentation/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../services/alert_service.dart';
import '../../../services/bluetooth_service.dart';
import '../../widgets/common/neon_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final alert = context.watch<AlertService>();
    final bt = context.watch<BluetoothService>();

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(title: const Text('SETTINGS')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // Alerts
          _buildGroup(
            title: 'ALERTS & NOTIFICATIONS',
            children: [
              _ToggleTile(
                icon: Icons.vibration,
                iconColor: AppColors.neonBlue,
                title: 'Vibration',
                subtitle: 'Haptic feedback on alerts',
                value: alert.vibrationEnabled,
                onChanged: (val) async {
                  alert.setVibration(val);
                  final repo = await SettingsRepository.getInstance();
                  final settings = repo.loadSettings();
                  await repo.saveSettings(settings.copyWith(vibrationEnabled: val));
                },
              ),
              const CyberDivider(),
              _ToggleTile(
                icon: Icons.volume_up,
                iconColor: AppColors.neonBlue,
                title: 'Sound',
                subtitle: 'Audio alerts when threats detected',
                value: alert.soundEnabled,
                onChanged: (val) async {
                  alert.setSoundEnabled(val);
                  final repo = await SettingsRepository.getInstance();
                  final settings = repo.loadSettings();
                  await repo.saveSettings(settings.copyWith(soundEnabled: val));
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bluetooth
          _buildGroup(
            title: 'BLUETOOTH',
            children: [
              _ToggleTile(
                icon: Icons.bluetooth,
                iconColor: AppColors.accentCyan,
                title: 'Auto Reconnect',
                subtitle: 'Automatically reconnect on disconnect',
                value: true,
                onChanged: (val) async {
                  bt.setAutoReconnect(val);
                  final repo = await SettingsRepository.getInstance();
                  final settings = repo.loadSettings();
                  await repo.saveSettings(settings.copyWith(autoReconnect: val));
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Info
          _buildGroup(
            title: 'HARDWARE',
            children: [
              _InfoTile(
                icon: Icons.developer_board,
                iconColor: AppColors.statusGreen,
                title: 'Arduino Module',
                value: 'Arduino Uno',
              ),
              const CyberDivider(),
              _InfoTile(
                icon: Icons.bluetooth,
                iconColor: AppColors.accentCyan,
                title: 'Bluetooth Module',
                value: 'HC-05 (Classic)',
              ),
              const CyberDivider(),
              _InfoTile(
                icon: Icons.sensors,
                iconColor: AppColors.alertOrange,
                title: 'Sensors',
                value: 'PIR + MQ-2',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // About
          _buildGroup(
            title: 'ABOUT',
            children: [
              _InfoTile(
                icon: Icons.shield,
                iconColor: AppColors.neonBlue,
                title: 'SecureGuard',
                value: 'v1.0.0',
              ),
              const CyberDivider(),
              _InfoTile(
                icon: Icons.school,
                iconColor: AppColors.neonBlue,
                title: 'Project Type',
                value: 'Cybersecurity Demo',
              ),
              const CyberDivider(),
              _InfoTile(
                icon: Icons.memory,
                iconColor: AppColors.statusGreen,
                title: 'Communication',
                value: 'Bluetooth Classic RFCOMM',
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Version tag
          Center(
            child: Text(
              'SECUREGUARD  •  EMBEDDED SYSTEMS PROJECT',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 2.0,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: 10),
        NeonCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.neonBlue,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
