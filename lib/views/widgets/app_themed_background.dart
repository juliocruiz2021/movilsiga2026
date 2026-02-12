import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppThemedBackground extends StatelessWidget {
  const AppThemedBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orbAlpha = isDark ? 0.28 : 0.35;
    final glowAlpha = isDark ? 0.32 : 0.45;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            palette.gradientStart,
            palette.gradientMid,
            palette.gradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _GlowOrb(
              size: 220,
              color: palette.orbA,
              orbAlpha: orbAlpha,
              glowAlpha: glowAlpha,
            ),
          ),
          Positioned(
            bottom: -90,
            left: -40,
            child: _GlowOrb(
              size: 200,
              color: palette.orbB,
              orbAlpha: orbAlpha,
              glowAlpha: glowAlpha,
            ),
          ),
          Positioned(
            top: 140,
            left: 30,
            child: _GlowOrb(
              size: 120,
              color: palette.orbC,
              orbAlpha: orbAlpha,
              glowAlpha: glowAlpha,
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    required this.orbAlpha,
    required this.glowAlpha,
  });

  final double size;
  final Color color;
  final double orbAlpha;
  final double glowAlpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: orbAlpha),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: glowAlpha),
            blurRadius: 60,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}
