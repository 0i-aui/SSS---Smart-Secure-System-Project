// lib/presentation/widgets/status/system_status_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../common/neon_card.dart';

class SystemStatusWidget extends StatelessWidget {
  final SystemStatus status;

  const SystemStatusWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: _buildStatusCard(context),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    switch (status) {
      case SystemStatus.normal:
        return _NormalStatusCard(key: const ValueKey('normal'));
      case SystemStatus.motion:
        return _MotionStatusCard(key: const ValueKey('motion'));
      case SystemStatus.smoke:
        return _SmokeStatusCard(key: const ValueKey('smoke'));
    }
  }
}

class _NormalStatusCard extends StatelessWidget {
  const _NormalStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      borderColor: AppColors.statusGreen,
      glowColor: AppColors.statusGreenGlow,
      child: Column(
        children: [
          // Radar ring
          Stack(
            alignment: Alignment.center,
            children: [
              _RadarRing(color: AppColors.statusGreen)
                  .animate(onPlay: (c) => c.repeat())
                  .scale(
                    begin: const Offset(0.6, 0.6),
                    end: const Offset(1.2, 1.2),
                    duration: 2000.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeOut(duration: 2000.ms, curve: Curves.easeIn),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.statusGreen.withOpacity(0.1),
                  border: Border.all(
                    color: AppColors.statusGreen.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppColors.statusGreen,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GlowText(
            'SYSTEM NORMAL',
            glowColor: AppColors.statusGreen,
            style: const TextStyle(
              color: AppColors.statusGreen,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 3.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'All sensors operational — No threats detected',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SensorChip(label: 'PIR', status: 'OK', color: AppColors.statusGreen),
              const SizedBox(width: 8),
              _SensorChip(label: 'MQ-2', status: 'OK', color: AppColors.statusGreen),
              const SizedBox(width: 8),
              _SensorChip(label: 'BT', status: 'RX', color: AppColors.neonBlue),
            ],
          ),
        ],
      ),
    );
  }
}

class _MotionStatusCard extends StatelessWidget {
  const _MotionStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      borderColor: AppColors.alertOrange,
      glowColor: AppColors.alertOrangeGlow,
      borderWidth: 1.5,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.alertOrange.withOpacity(0.15),
              border: Border.all(color: AppColors.alertOrange, width: 2),
            ),
            child: const Icon(
              Icons.directions_run,
              color: AppColors.alertOrange,
              size: 32,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.05, 1.05),
                duration: 600.ms,
              ),
          const SizedBox(height: 16),
          GlowText(
            'MOTION DETECTED',
            glowColor: AppColors.alertOrange,
            style: const TextStyle(
              color: AppColors.alertOrange,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'PIR sensor triggered — possible intrusion',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.alertOrange.withOpacity(0.8),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SmokeStatusCard extends StatelessWidget {
  const _SmokeStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      borderColor: AppColors.alertRed,
      glowColor: AppColors.alertRedGlow,
      borderWidth: 2,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.alertRed.withOpacity(0.2),
              border: Border.all(color: AppColors.alertRed, width: 2),
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: AppColors.alertRed,
              size: 38,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.92, 0.92),
                end: const Offset(1.08, 1.08),
                duration: 400.ms,
              )
              .then()
              .shake(hz: 3, offset: const Offset(3, 0), duration: 300.ms),
          const SizedBox(height: 14),
          GlowText(
            '⚠  SMOKE ALERT',
            glowColor: AppColors.alertRed,
            blurRadius: 20,
            style: const TextStyle(
              color: AppColors.alertRed,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.alertRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.alertRed.withOpacity(0.3)),
            ),
            child: Text(
              'EVACUATE IMMEDIATELY',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.alertRed,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.5,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .tint(color: AppColors.alertRed.withOpacity(0.05), duration: 500.ms);
  }
}

class _RadarRing extends StatelessWidget {
  final Color color;

  const _RadarRing({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
    );
  }
}

class _SensorChip extends StatelessWidget {
  final String label;
  final String status;
  final Color color;

  const _SensorChip({
    required this.label,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Connection status bar ─────────────────────────────────
class ConnectionStatusBar extends StatelessWidget {
  final ConnectionStatus status;
  final String message;
  final VoidCallback? onTap;

  const ConnectionStatusBar({
    super.key,
    required this.status,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    bool pulsing = false;

    switch (status) {
      case ConnectionStatus.connected:
        color = AppColors.statusGreen;
        pulsing = false;
        break;
      case ConnectionStatus.connecting:
        color = AppColors.statusYellow;
        pulsing = true;
        break;
      case ConnectionStatus.error:
        color = AppColors.alertRed;
        pulsing = false;
        break;
      case ConnectionStatus.disconnected:
        color = AppColors.textMuted;
        pulsing = false;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusDot(color: color, pulsing: pulsing, size: 8),
            const SizedBox(width: 8),
            Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            if (status == ConnectionStatus.disconnected ||
                status == ConnectionStatus.error) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, color: color, size: 14),
            ],
          ],
        ),
      ),
    );
  }
}
