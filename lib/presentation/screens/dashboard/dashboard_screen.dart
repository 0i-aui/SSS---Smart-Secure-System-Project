// lib/presentation/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/bluetooth_service.dart';
import '../../../services/alert_service.dart';
import '../../widgets/alerts/alert_cards.dart';
import '../../widgets/common/neon_card.dart';
import '../../widgets/status/system_status_widget.dart';
import '../bluetooth/bluetooth_screen.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onNavigateToHistory;

  const DashboardScreen({super.key, this.onNavigateToHistory});

  @override
  Widget build(BuildContext context) {
    final bt = context.watch<BluetoothService>();
    final alert = context.watch<AlertService>();

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, bt),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Connection status
                _buildConnectionBar(context, bt),
                const SizedBox(height: 20),
                // System status
                SectionHeader(title: 'System Status'),
                const SizedBox(height: 10),
                SystemStatusWidget(status: alert.systemStatus),
                const SizedBox(height: 20),

                // Active Alerts section
                if (alert.activeMotionAlert != null ||
                    alert.activeSmokeAlert != null) ...[
                  SectionHeader(title: 'Active Alerts'),
                  const SizedBox(height: 10),
                  if (alert.activeSmokeAlert != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SmokeAlertCard(event: alert.activeSmokeAlert!),
                    ),
                  if (alert.activeMotionAlert != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: MotionAlertCard(event: alert.activeMotionAlert!),
                    ),
                  const SizedBox(height: 10),
                ],

                // Sensor grid
                SectionHeader(title: 'Sensor Overview'),
                const SizedBox(height: 10),
                _SensorGrid(alertService: alert),
                const SizedBox(height: 20),

                // Recent activity
                if (alert.history.isNotEmpty) ...[
                  SectionHeader(
                    title: 'Recent Events',
                    trailing: GestureDetector(
                      onTap: onNavigateToHistory,
                      child: const Text(
                        'VIEW ALL',
                        style: TextStyle(
                          color: AppColors.neonBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...alert.history
                      .take(3)
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: HistoryItemTile(
                              event: e,
                              isFirst: e == alert.history.first,
                            ),
                          ))
                      ,
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, BluetoothService bt) {
    return SliverAppBar(
      backgroundColor: AppColors.bgDeep,
      expandedHeight: 100,
      floating: false,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF050A0F), Color(0xFF081525)],
            ),
          ),
          child: Stack(
            children: [
              // Subtle grid pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: _GridPainter(),
                ),
              ),
              // Logo
              Positioned(
                left: 20,
                bottom: 16,
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.neonBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.neonBlue.withOpacity(0.4),
                        ),
                      ),
                      child: const Icon(
                        Icons.shield,
                        color: AppColors.neonBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GlowText(
                          'SECUREGUARD',
                          glowColor: AppColors.neonBlue,
                          style: const TextStyle(
                            color: AppColors.neonBlue,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3.0,
                          ),
                        ),
                        Text(
                          'SECURITY MONITOR v1.0',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 9,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        titlePadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildConnectionBar(BuildContext context, BluetoothService bt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ConnectionStatusBar(
        status: bt.status,
        message: bt.statusMessage,
        onTap: () {
          if (!bt.isConnected) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BluetoothScreen(),
              ),
            );
          }
        },
      ),
    );
  }
}

class _SensorGrid extends StatelessWidget {
  final AlertService alertService;

  const _SensorGrid({required this.alertService});

  @override
  Widget build(BuildContext context) {
    final motionActive = alertService.activeMotionAlert != null;
    final smokeActive = alertService.activeSmokeAlert != null;

    return Row(
      children: [
        Expanded(
          child: _SensorCard(
            label: 'PIR SENSOR',
            sublabel: 'Motion Detection',
            icon: Icons.sensors,
            status: motionActive ? 'TRIGGERED' : 'STANDBY',
            statusColor:
                motionActive ? AppColors.alertOrange : AppColors.statusGreen,
            active: motionActive,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SensorCard(
            label: 'MQ-2 SENSOR',
            sublabel: 'Smoke / Gas',
            icon: Icons.air,
            status: smokeActive ? 'TRIGGERED' : 'STANDBY',
            statusColor:
                smokeActive ? AppColors.alertRed : AppColors.statusGreen,
            active: smokeActive,
          ),
        ),
      ],
    );
  }
}

class _SensorCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final String status;
  final Color statusColor;
  final bool active;

  const _SensorCard({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.status,
    required this.statusColor,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      borderColor: active ? statusColor : AppColors.borderSubtle,
      glowColor: active ? statusColor.withOpacity(0.3) : null,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: statusColor, size: 20),
              const Spacer(),
              StatusDot(color: statusColor, pulsing: active, size: 8),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            sublabel,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0D2035)
      ..strokeWidth = 0.5;

    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
