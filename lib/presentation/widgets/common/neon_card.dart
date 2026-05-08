// lib/presentation/widgets/common/neon_card.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class NeonCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color? glowColor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double borderRadius;
  final double borderWidth;

  const NeonCard({
    super.key,
    required this.child,
    this.borderColor = AppColors.borderSubtle,
    this.glowColor,
    this.padding,
    this.onTap,
    this.borderRadius = 16,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: glowColor != null
              ? [
                  BoxShadow(
                    color: glowColor!,
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

// ── Glow Text ─────────────────────────────────────────────
class GlowText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color glowColor;
  final double blurRadius;
  final TextAlign? textAlign;

  const GlowText(
    this.text, {
    super.key,
    this.style,
    this.glowColor = AppColors.neonBlue,
    this.blurRadius = 12,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.bodyLarge!;
    return Text(
      text,
      textAlign: textAlign,
      style: base.copyWith(
        shadows: [
          Shadow(color: glowColor, blurRadius: blurRadius),
          Shadow(color: glowColor, blurRadius: blurRadius * 2),
        ],
      ),
    );
  }
}

// ── Status Dot ────────────────────────────────────────────
class StatusDot extends StatefulWidget {
  final Color color;
  final bool pulsing;
  final double size;

  const StatusDot({
    super.key,
    required this.color,
    this.pulsing = false,
    this.size = 10,
  });

  @override
  State<StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<StatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.pulsing) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(StatusDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulsing && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.pulsing && _ctrl.isAnimating) {
      _ctrl.stop();
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withOpacity(_anim.value),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.5),
              blurRadius: widget.size,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.neonBlue,
            borderRadius: BorderRadius.circular(2),
            boxShadow: const [
              BoxShadow(color: AppColors.neonBlueGlow, blurRadius: 8),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.neonBlue,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            fontSize: 12,
          ),
        ),
        if (trailing != null) ...[const Spacer(), trailing!],
      ],
    );
  }
}

// ── Cyber Divider ─────────────────────────────────────────
class CyberDivider extends StatelessWidget {
  const CyberDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.borderSubtle,
            AppColors.neonBlueDim,
            AppColors.borderSubtle,
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ── Hex Pattern Background Painter ───────────────────────
class HexPatternPainter extends CustomPainter {
  final Color color;

  HexPatternPainter({this.color = const Color(0xFF0D2035)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    const hexRadius = 18.0;

    for (double y = -hexRadius; y < size.height + hexRadius; y += spacing * 0.866) {
      for (double x = -hexRadius; x < size.width + hexRadius; x += spacing) {
        final offset = (y / (spacing * 0.866)).floor().isOdd ? spacing / 2 : 0;
        _drawHex(canvas, Offset(x + offset, y), hexRadius, paint);
      }
    }
  }

  void _drawHex(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (60 * i - 30) * 3.14159 / 180;
      final point = Offset(
        center.dx + r * 0.6 * (i == 0 ? 1 : 1) * _cos(angle),
        center.dy + r * 0.6 * _sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double _cos(double angle) => (angle == 0)
      ? 1.0
      : (angle == 3.14159 / 3)
          ? 0.5
          : (angle == 2 * 3.14159 / 3)
              ? -0.5
              : (angle == 3.14159)
                  ? -1.0
                  : (angle == 4 * 3.14159 / 3)
                      ? -0.5
                      : 0.5;

  double _sin(double angle) {
    return (angle == 0)
        ? 0.0
        : (angle == 3.14159 / 3)
            ? 0.866
            : (angle == 2 * 3.14159 / 3)
                ? 0.866
                : (angle == 3.14159)
                    ? 0.0
                    : (angle == 4 * 3.14159 / 3)
                        ? -0.866
                        : -0.866;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
