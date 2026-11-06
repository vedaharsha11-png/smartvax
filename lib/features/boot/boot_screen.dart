import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// One continuous timeline, including the handoff to the app.
class SmartVaxSplash extends StatefulWidget {
  const SmartVaxSplash({super.key, this.onReveal, this.onCompleted});

  static const duration = Duration(seconds: 4);
  final VoidCallback? onReveal;
  final VoidCallback? onCompleted;

  @override
  State<SmartVaxSplash> createState() => _SmartVaxSplashState();
}

class _SmartVaxSplashState extends State<SmartVaxSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _timeline;
  bool _revealed = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _timeline =
        AnimationController(
            vsync: this,
            duration: SmartVaxSplash.duration,
            // Reduced motion keeps the same timing with a still composition.
            animationBehavior: AnimationBehavior.preserve,
          )
          ..addListener(() {
            if (!_revealed && _timeline.value >= .9) {
              _revealed = true;
              widget.onReveal?.call();
            }
            // Flutter's completed status arrives after the duration boundary.
            // Use the endpoint to hand off on the four-second frame itself.
            if (!_completed && _timeline.value >= 1) {
              _completed = true;
              widget.onCompleted?.call();
            }
          })
          ..forward();
  }

  @override
  void dispose() {
    _timeline.dispose();
    super.dispose();
  }

  double _phase(double t, double start, double end, Curve curve) =>
      curve.transform(((t - start) / (end - start)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _timeline,
      builder: (context, _) {
        final t = _timeline.value;
        final entrance = reducedMotion
            ? 1.0
            : _phase(t, .04, .34, Curves.easeOutCubic);
        final text = reducedMotion
            ? 1.0
            : _phase(t, .24, .46, Curves.easeOutCubic);
        final exit = _phase(t, .9, 1, Curves.easeInOutCubic);
        final drift = reducedMotion ? 0.0 : math.sin(t * math.pi * 2) * 5;
        return Opacity(
          opacity: 1 - exit,
          child: Scaffold(
            backgroundColor: AppColors.light,
            body: Stack(
              fit: StackFit.expand,
              children: [
                RepaintBoundary(
                  child: CustomPaint(
                    painter: _LiquidLightPainter(reducedMotion ? .45 : t),
                  ),
                ),
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final iconSize = math.min(
                        228.0,
                        math.min(
                          (constraints.maxWidth - 56) / 1.55,
                          constraints.maxHeight * .3,
                        ),
                      );
                      return Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 24,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.translate(
                                offset: Offset(0, 28 * (1 - entrance) + drift),
                                child: Transform.scale(
                                  scale: .78 + .22 * entrance,
                                  child: Opacity(
                                    opacity: entrance,
                                    child: _OrbitLogo(
                                      size: iconSize,
                                      progress: reducedMotion ? .45 : t,
                                      tilt: reducedMotion ? 0 : 1 - entrance,
                                      reducedMotion: reducedMotion,
                                      shimmer: reducedMotion
                                          ? -1
                                          : _phase(
                                              t,
                                              .36,
                                              .7,
                                              Curves.easeInOutCubic,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 22),
                              Opacity(
                                opacity: text,
                                child: Transform.translate(
                                  offset: Offset(0, 12 * (1 - text)),
                                  child: Column(
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: ShaderMask(
                                          blendMode: BlendMode.srcIn,
                                          shaderCallback: (bounds) =>
                                              const LinearGradient(
                                                colors: [
                                                  AppColors.navy,
                                                  AppColors.blue,
                                                  AppColors.mint,
                                                ],
                                              ).createShader(bounds),
                                          child: const Text(
                                            'SmartVax',
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -1.8,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Healthy today.\nBrighter tomorrows.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.secondary,
                                          fontSize: 16,
                                          height: 1.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 38),
                              Semantics(
                                label: 'Starting SmartVax',
                                child: SizedBox(
                                  width: 96,
                                  height: 4,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ColoredBox(
                                          color: Colors.white.withValues(
                                            alpha: .8,
                                          ),
                                        ),
                                        FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: t,
                                          child: const DecoratedBox(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8),
                                              ),
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppColors.blue,
                                                  AppColors.cyan,
                                                  AppColors.mint,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OrbitLogo extends StatelessWidget {
  const _OrbitLogo({
    required this.size,
    required this.progress,
    required this.shimmer,
    required this.tilt,
    required this.reducedMotion,
  });

  final double size;
  final double progress;
  final double shimmer;
  final double tilt;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    final angle = progress * math.pi * 2;
    return SizedBox.square(
      dimension: size * 1.55,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: CustomPaint(
                painter: _OrbitPainter(progress: progress, front: false),
              ),
            ),
          ),
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, .0014)
              ..rotateX(reducedMotion ? 0 : -.4 * tilt + .065 * math.sin(angle))
              ..rotateY(reducedMotion ? 0 : .9 * tilt + .13 * math.sin(angle))
              ..rotateZ(reducedMotion ? 0 : -.09 * tilt),
            child: _GlassIcon(size: size, shimmer: shimmer),
          ),
          Positioned.fill(
            child: ExcludeSemantics(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _OrbitPainter(progress: progress, front: true),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Project tilted circles into perspective and split them by depth, so each
/// luminous ring travels behind the icon and back across its foreground.
class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({required this.progress, required this.front});
  final double progress;
  final bool front;
  static const _colors = [
    AppColors.cyan,
    AppColors.blue,
    AppColors.violet,
    AppColors.pink,
    AppColors.cyan,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .46);
    final radius = size.width * .425;
    final phase = progress * math.pi * 4;
    final bounds = Rect.fromCircle(center: center, radius: radius * 1.2);

    if (!front) {
      final platform = Rect.fromCenter(
        center: Offset(center.dx, size.height * .91),
        width: size.width * .76,
        height: size.height * .13,
      );
      canvas.drawOval(
        platform,
        Paint()
          ..shader = const RadialGradient(
            colors: [Color(0x553678ff), Color(0x0021ceef)],
          ).createShader(platform)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
      for (var i = 0; i < 3; i++) {
        final oval = platform.deflate(i * size.width * .032);
        canvas.drawOval(
          oval,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = i == 0 ? 1.4 : .7
            ..shader = LinearGradient(
              colors: [
                AppColors.cyan.withValues(alpha: .6),
                AppColors.violet.withValues(alpha: .3),
                AppColors.pink.withValues(alpha: .6),
              ],
            ).createShader(oval),
        );
      }
      // Pinpoints drift along the outer circular field like tiny satellites.
      for (var i = 0; i < 12; i++) {
        final angle = i * math.pi / 6 + phase * .18;
        final point =
            center + Offset(math.cos(angle), math.sin(angle)) * radius * 1.1;
        final color = _colors[i % 4];
        canvas.drawCircle(
          point,
          i % 3 == 0 ? 2.2 : 1.1,
          Paint()..color = color.withValues(alpha: .55),
        );
      }
      canvas.drawCircle(
        center,
        radius * 1.16,
        Paint()
          ..shader = ui.Gradient.radial(
            center,
            radius * 1.16,
            [
              AppColors.cyan.withValues(alpha: .04),
              AppColors.violet.withValues(alpha: .13),
              AppColors.cyan.withValues(alpha: 0),
            ],
            [.25, .66, 1],
          ),
      );
      // The thin circular halo rotates independently of the tilted orbits.
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 1.09),
        -phase * .65,
        math.pi * 1.6,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..shader = SweepGradient(
            colors: _colors.map((c) => c.withValues(alpha: .32)).toList(),
            transform: GradientRotation(-phase * .65),
          ).createShader(bounds),
      );
    }

    for (var ring = 0; ring < 3; ring++) {
      final rotation = [-.42, .92, -1.18][ring] + .24 * math.sin(phase * .3);
      final inclination = [.72, .84, .95][ring];
      final ringRadius = radius * (1 - ring * .035);
      (Offset, double) project(double angle) {
        final x = ringRadius * math.cos(angle);
        final y = ringRadius * math.sin(angle) * math.cos(inclination);
        final z = ringRadius * math.sin(angle) * math.sin(inclination);
        final perspective = 1 / (1 - z / (radius * 5));
        return (
          center +
              Offset(
                (x * math.cos(rotation) - y * math.sin(rotation)) * perspective,
                (x * math.sin(rotation) + y * math.cos(rotation)) * perspective,
              ),
          z,
        );
      }

      final path = Path();
      var connected = false;
      for (var i = 0; i <= 160; i++) {
        final (point, z) = project(i / 160 * math.pi * 2);
        if ((z >= 0) == front) {
          if (connected) {
            path.lineTo(point.dx, point.dy);
          } else {
            path.moveTo(point.dx, point.dy);
          }
          connected = true;
        } else {
          connected = false;
        }
      }
      final shader = SweepGradient(
        colors: _colors,
        transform: GradientRotation(phase + ring * 1.4),
      ).createShader(bounds);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = front ? 8 : 5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
          ..shader = shader
          ..color = Colors.white.withValues(alpha: front ? .6 : .25),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = front ? 2.4 : 1.4
          ..shader = shader
          ..color = Colors.white.withValues(alpha: front ? .9 : .4),
      );

      // A short comet trail makes the direction of rotation visible.
      final head = phase * (ring == 1 ? -1 : 1) + ring * 2.1;
      final color = [AppColors.cyan, AppColors.pink, AppColors.violet][ring];
      for (var i = 24; i > 0; i--) {
        final (point, z) = project(head - i * .026);
        final (next, _) = project(head - (i - 1) * .026);
        if ((z >= 0) != front) continue;
        canvas.drawLine(
          point,
          next,
          Paint()
            ..strokeWidth = 2.5
            ..strokeCap = StrokeCap.round
            ..color = color.withValues(alpha: (1 - i / 25) * .8),
        );
      }
      final (point, z) = project(head);
      if ((z >= 0) == front) {
        final dotRadius = front ? 4.8 : 3.2;
        canvas.drawCircle(
          point,
          dotRadius * 3,
          Paint()
            ..color = color.withValues(alpha: .6)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
        canvas.drawCircle(
          point,
          dotRadius,
          Paint()
            ..shader = ui.Gradient.radial(
              point - const Offset(1, 1),
              dotRadius * 2,
              [Colors.white, color],
            ),
        );
        canvas.drawCircle(
          point - const Offset(.7, .7),
          1.1,
          Paint()..color = Colors.white,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.front != front;
}

class _GlassIcon extends StatelessWidget {
  const _GlassIcon({required this.size, required this.shimmer});
  final double size;
  final double shimmer;

  @override
  Widget build(BuildContext context) => Container(
    width: size + 24,
    height: size + 24,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: AppColors.blue.withValues(alpha: .22),
          blurRadius: 44,
          offset: const Offset(0, 22),
        ),
        BoxShadow(
          color: AppColors.pink.withValues(alpha: .16),
          blurRadius: 24,
          offset: const Offset(-10, -10),
        ),
      ],
    ),
    child: ClipOval(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: .9),
              width: 2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: .88),
                AppColors.cyan.withValues(alpha: .16),
                AppColors.violet.withValues(alpha: .22),
                Colors.white.withValues(alpha: .7),
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: EdgeInsets.all((size + 24) * .15),
                child: Image.asset(
                  'assets/images/app_icon_source.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  semanticLabel: 'SmartVax app icon',
                  cacheWidth: 640,
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _SphereReflectionPainter()),
                ),
              ),
              if (shimmer > 0 && shimmer < 1)
                IgnorePointer(
                  child: CustomPaint(painter: _ShimmerPainter(shimmer)),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SphereReflectionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final rim = Rect.fromCircle(center: center, radius: size.width * .47);
    canvas.drawArc(
      rim,
      math.pi * 1.05,
      math.pi * .58,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * .028
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: .8),
    );
    canvas.drawArc(
      rim.deflate(size.width * .018),
      .1,
      math.pi * .4,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = AppColors.cyan.withValues(alpha: .8),
    );
    final highlight = Rect.fromCenter(
      center: Offset(size.width * .32, size.height * .15),
      width: size.width * .26,
      height: size.height * .06,
    );
    canvas.save();
    canvas.translate(highlight.center.dx, highlight.center.dy);
    canvas.rotate(-.4);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: highlight.width,
        height: highlight.height,
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: .75)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SphereReflectionPainter oldDelegate) => false;
}

class _ShimmerPainter extends CustomPainter {
  const _ShimmerPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(-size.width + progress * size.width * 3, 0);
    canvas.rotate(.3);
    final rect = Rect.fromLTWH(
      0,
      -size.height,
      size.width * .45,
      size.height * 3,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: .38),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShimmerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Soft radial fields and fine glass contours avoid full-screen blur passes.
class _LiquidLightPainter extends CustomPainter {
  const _LiquidLightPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffd8f5ff), Color(0xffede3ff), Color(0xffd9f5ff)],
        ).createShader(bounds),
    );
    final phase = progress * math.pi * 2;
    void glow(Offset center, double radius, Color color) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = ui.Gradient.radial(center, radius, [
            color.withValues(alpha: .48),
            color.withValues(alpha: 0),
          ]),
      );
    }

    glow(
      Offset(size.width * (.1 + .12 * math.sin(phase)), size.height * .25),
      size.width * .85,
      AppColors.cyan,
    );
    glow(
      Offset(size.width * .94, size.height * (.45 + .08 * math.cos(phase))),
      size.width * .8,
      AppColors.violet,
    );
    glow(
      Offset(size.width * .35, size.height * .9),
      size.width * .8,
      AppColors.cyan,
    );
    glow(
      Offset(size.width * .9, size.height * .7),
      size.width * .7,
      AppColors.pink,
    );

    for (var i = 0; i < 3; i++) {
      final y = size.height * (.12 + i * .36);
      final movement = math.sin(phase + i) * size.width * .06;
      final path = Path()
        ..moveTo(-30, y)
        ..cubicTo(
          size.width * .28 + movement,
          y - 100,
          size.width * .65,
          y + 130,
          size.width + 30,
          y - 15,
        );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..color = Colors.white.withValues(alpha: .62),
      );
      canvas.drawPath(
        path.shift(const Offset(0, 8)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..color = AppColors.blue.withValues(alpha: .025),
      );
    }
  }

  @override
  bool shouldRepaint(_LiquidLightPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
