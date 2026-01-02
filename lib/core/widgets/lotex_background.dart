import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/lotex_ui_tokens.dart';

class LotexBackground extends StatelessWidget {
  final bool showNoise;

  const LotexBackground({super.key, this.showNoise = false});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(color: LotexUiColors.slate950),
        child: Stack(
          children: [
            const _GlowOrb(
              alignment: Alignment.topLeft,
              size: 500,
              color: Color.fromRGBO(76, 29, 149, 0.40),
              blurSigma: 100,
              offset: Offset(-80, -80),
            ),
            const _GlowOrb(
              alignment: Alignment.bottomRight,
              size: 600,
              color: Color.fromRGBO(30, 58, 138, 0.30),
              blurSigma: 120,
              offset: Offset(80, 80),
            ),
            const _GlowOrb(
              alignment: Alignment.center,
              size: 800,
              color: Color.fromRGBO(30, 27, 75, 0.20),
              blurSigma: 100,
            ),
            if (showNoise)
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.08,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withAlpha((0.06 * 255).round()),
                            Colors.transparent,
                          ],
                          radius: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Alignment alignment;
  final double size;
  final Color color;
  final double blurSigma;
  final Offset offset;

  const _GlowOrb({
    required this.alignment,
    required this.size,
    required this.color,
    required this.blurSigma,
    this.offset = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
