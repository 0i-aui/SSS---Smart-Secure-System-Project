// lib/presentation/screens/history/history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/alert_event.dart';
import '../../../services/alert_service.dart';
import '../../widgets/alerts/alert_cards.dart';
import '../../widgets/common/neon_card.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  AlertType? _filter;

  @override
  Widget build(BuildContext context) {
    final alert = context.watch<AlertService>();
    final history = _filter == null
        ? alert.history
        : alert.history.where((e) => e.type == _filter).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        title: const Text('EVENT HISTORY'),
        actions: [
          if (alert.history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.alertRed),
              onPressed: () => _confirmClear(context, alert),
              tooltip: 'Clear history',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildStats(context, alert),
          _buildFilters(),
          Expanded(
            child: history.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final event = history[index];
                      return HistoryItemTile(
                        event: event,
                        isFirst: index == 0,
                      )
                          .animate(delay: (index * 40).ms)
                          .fadeIn()
                          .slideX(begin: 0.1, end: 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, AlertService alert) {
    final motionCount =
        alert.history.where((e) => e.type == AlertType.motion).length;
    final smokeCount =
        alert.history.where((e) => e.type == AlertType.smoke).length;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'MOTION',
              count: motionCount,
              color: AppColors.alertOrange,
              icon: Icons.directions_run,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'SMOKE',
              count: smokeCount,
              color: AppColors.alertRed,
              icon: Icons.local_fire_department,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'TOTAL',
              count: alert.history.length,
              color: AppColors.neonBlue,
              icon: Icons.history,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _FilterChip(
            label: 'ALL',
            selected: _filter == null,
            color: AppColors.neonBlue,
            onTap: () => setState(() => _filter = null),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'MOTION',
            selected: _filter == AlertType.motion,
            color: AppColors.alertOrange,
            onTap: () => setState(() => _filter = AlertType.motion),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'SMOKE',
            selected: _filter == AlertType.smoke,
            color: AppColors.alertRed,
            onTap: () => setState(() => _filter = AlertType.smoke),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.history_toggle_off,
            color: AppColors.textMuted,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'NO EVENTS YET',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _filter == null
                ? 'Alert events will appear here'
                : 'No ${_filter?.name} events recorded',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, AlertService alert) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        title: const Text(
          'CLEAR HISTORY',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        content: const Text(
          'All recorded alert events will be permanently deleted.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'CLEAR',
              style: TextStyle(color: AppColors.alertRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await alert.clearHistory();
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      borderColor: color.withOpacity(0.3),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppColors.borderSubtle,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
