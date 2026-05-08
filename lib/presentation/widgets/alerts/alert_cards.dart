// lib/presentation/widgets/alerts/alert_cards.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/alert_event.dart';
import '../common/neon_card.dart';
import 'package:intl/intl.dart';

// ── Motion Alert Card ─────────────────────────────────────
class MotionAlertCard extends StatelessWidget {
  final AlertEvent event;

  const MotionAlertCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      borderColor: AppColors.alertOrange,
      glowColor: AppColors.alertOrangeGlow,
      borderWidth: 1.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.alertOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.directions_run,
                  color: AppColors.alertOrange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlowText(
                      'MOTION DETECTED',
                      glowColor: AppColors.alertOrange,
                      style: const TextStyle(
                        color: AppColors.alertOrange,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'PIR SENSOR TRIGGERED',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.alertOrange.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              StatusDot(
                color: AppColors.alertOrange,
                pulsing: true,
                size: 12,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.alertOrange.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Text(
                DateFormat('HH:mm:ss  •  MMM dd').format(event.timestamp),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.alertOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.alertOrange.withOpacity(0.4),
                  ),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: AppColors.alertOrange,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
          duration: 2000.ms,
          color: AppColors.alertOrange.withOpacity(0.05),
        );
  }
}

// ── Smoke Alert Card ──────────────────────────────────────
class SmokeAlertCard extends StatelessWidget {
  final AlertEvent event;

  const SmokeAlertCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      borderColor: AppColors.alertRed,
      glowColor: AppColors.alertRedGlow,
      borderWidth: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.alertRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.alertRed.withOpacity(0.4),
                  ),
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: AppColors.alertRed,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlowText(
                      '⚠  SMOKE ALERT',
                      glowColor: AppColors.alertRed,
                      blurRadius: 16,
                      style: const TextStyle(
                        color: AppColors.alertRed,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'MQ-2 SENSOR — CRITICAL',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.alertRed.withOpacity(0.8),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              StatusDot(color: AppColors.alertRed, pulsing: true, size: 14),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.alertRed.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.alertRed.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.alertRed,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Smoke or combustible gas detected. Evacuate immediately.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.alertRed.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Text(
                DateFormat('HH:mm:ss  •  MMM dd').format(event.timestamp),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.alertRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.alertRed.withOpacity(0.5)),
                ),
                child: const Text(
                  '⚡ CRITICAL',
                  style: TextStyle(
                    color: AppColors.alertRed,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shake(duration: 600.ms, delay: 1000.ms, hz: 2, offset: const Offset(2, 0))
        .then()
        .shake(duration: 600.ms, delay: 3000.ms, hz: 2, offset: const Offset(2, 0));
  }
}

// ── History Item Tile ─────────────────────────────────────
class HistoryItemTile extends StatelessWidget {
  final AlertEvent event;
  final bool isFirst;

  const HistoryItemTile({
    super.key,
    required this.event,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSmoke = event.type == AlertType.smoke;
    final color = isSmoke ? AppColors.alertRed : AppColors.alertOrange;
    final icon = isSmoke ? Icons.local_fire_department : Icons.directions_run;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFirst ? color.withOpacity(0.5) : AppColors.borderSubtle,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          event.title,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        subtitle: Text(
          DateFormat('MMM dd, yyyy  •  HH:mm:ss').format(event.timestamp),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isSmoke ? 'SMOKE' : 'MOTION',
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
