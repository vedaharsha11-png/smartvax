import 'dart:ui';

import 'liquid_scene.dart';

import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../theme/app_theme.dart';

class LiquidBackground extends StatelessWidget {
  const LiquidBackground({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      Stack(fit: StackFit.expand, children: [const LiquidScene(), child]);
}

class LiquidGlassCard extends StatelessWidget {
  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius = 27,
    this.opacity = .76,
    this.borderColor,
    this.gradient,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double opacity;
  final Color? borderColor;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final surface = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            gradient:
                gradient ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: .88),
                    const Color(0xffe8faff).withValues(alpha: opacity),
                    const Color(0xffdcedff).withValues(alpha: opacity * .75),
                    Colors.white.withValues(alpha: .70),
                  ],
                  stops: const [0, .18, .72, 1],
                ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor ?? Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff176bc7).withValues(alpha: .16),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(color: Colors.transparent, child: child),
        ),
      ),
    );
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: onTap == null
          ? surface
          : Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(radius),
                onTap: onTap,
                child: surface,
              ),
            ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'SmartVax',
    child: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 15 : 23,
          vertical: compact ? 6 : 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(38),
          border: Border.all(color: Colors.white, width: 2),
          gradient: const LinearGradient(
            colors: [Color(0xfffaffff), Color(0xffc2f5ff), Color(0xffecffff)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue.withValues(alpha: .17),
              blurRadius: 13,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xff006dff),
              Color(0xff080b94),
              Color(0xff0cbea2),
              Color(0xff00a977),
            ],
            stops: [0, .48, .68, 1],
          ).createShader(bounds),
          child: Text(
            'SmartVax',
            style: TextStyle(
              fontFamily: 'Nunito',
              color: Colors.white,
              fontSize: compact ? 28 : 38,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.7,
            ),
          ),
        ),
      ),
    ),
  );
}

class DoctorChildArt extends StatelessWidget {
  const DoctorChildArt({super.key, this.height = 180});
  final double height;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Image.asset(
      'assets/images/theme/doctor_child.png',
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    ),
  );
}

class GlossyIcon extends StatelessWidget {
  const GlossyIcon({
    super.key,
    required this.icon,
    this.color = AppColors.blue,
    this.size = 48,
  });
  final IconData icon;
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        center: const Alignment(-.4, -.6),
        colors: [
          Colors.white,
          color.withValues(alpha: .14),
          color.withValues(alpha: .28),
        ],
      ),
      border: Border.all(color: Colors.white.withValues(alpha: .95), width: 2),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: .18),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Icon(
      icon,
      color: color,
      size: size * .51,
      shadows: [
        Shadow(
          color: Colors.white.withValues(alpha: .8),
          offset: const Offset(0, -1),
        ),
      ],
    ),
  );
}

class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: label,
    onPressed: onPressed,
    padding: EdgeInsets.zero,
    icon: GlossyIcon(icon: icon, size: 44),
  );
}

class GlossyProgress extends StatelessWidget {
  const GlossyProgress({super.key, required this.value});
  final double value;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Tracked record progress',
    value: '${(value * 100).round()} percent',
    child: Container(
      height: 13,
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: .16),
        border: Border.all(color: Colors.white, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0, 1),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff39e3af), Color(0xff02baae)],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class ChildAvatar extends StatelessWidget {
  const ChildAvatar({
    super.key,
    required this.child,
    this.size = 52,
    this.selected = false,
  });
  final ChildProfile child;
  final double size;
  final bool selected;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        colors: [Color(0xff9aefff), Color(0xffc5b7ff)],
      ),
      border: Border.all(
        color: selected ? AppColors.blue : Colors.white,
        width: selected ? 3 : 2,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.blue.withValues(alpha: .15),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Center(
      child: ClipOval(
        child: SizedBox(
          width: size - 5,
          height: size - 5,
          child: OverflowBox(
            alignment: Alignment(_portraitIndex(child) - 1.0, 0),
            minWidth: (size - 5) * 3,
            maxWidth: (size - 5) * 3,
            minHeight: size - 5,
            maxHeight: size - 5,
            child: Image.asset(
              'assets/images/theme/family_portraits.png',
              fit: BoxFit.fill,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ),
    ),
  );
}

int _portraitIndex(ChildProfile child) {
  if (child.id == 'child_vihaan' || child.avatar.contains('👶')) return 2;
  if (child.gender == ChildGender.female) return 1;
  return 0;
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
    this.danger = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final bool danger;
  @override
  Widget build(BuildContext context) {
    final button = Container(
      constraints: const BoxConstraints(minHeight: 52),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: danger
              ? const [Color(0xfff37a9b), Color(0xffe84d7f)]
              : const [AppColors.cyan, AppColors.blue, AppColors.violet],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: .75),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (danger ? AppColors.pink : AppColors.blue).withValues(
              alpha: .24,
            ),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.white60,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    super.key,
    this.action,
    this.onAction,
    this.icon,
  });
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: AppColors.blue, size: 21),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    ),
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.white.withValues(alpha: .65),
          color.withValues(alpha: .24),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: .18)),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
    ),
  );
}

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.bottomBar,
  });
  final String title;
  final Widget child;
  final Widget? trailing;
  final Widget? bottomBar;
  @override
  Widget build(BuildContext context) => Scaffold(
    extendBody: true,
    extendBodyBehindAppBar: true,
    bottomNavigationBar: bottomBar,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.navy,
          fontWeight: FontWeight.w800,
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(5),
        child: GlassIconButton(
          label: 'Back',
          onPressed: () => Navigator.maybePop(context),
          icon: Icons.arrow_back_rounded,
        ),
      ),
      actions: trailing == null ? null : [trailing!],
    ),
    body: LiquidBackground(
      child: SafeArea(
        child: Padding(padding: const EdgeInsets.only(top: 8), child: child),
      ),
    ),
  );
}

Widget appNotice(String message) => LiquidGlassCard(
  radius: 18,
  opacity: .45,
  padding: const EdgeInsets.all(12),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Icon(Icons.info_outline_rounded, color: AppColors.blue, size: 20),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          message,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ),
    ],
  ),
);
