import 'package:flutter/material.dart';

/// Bundled decorative artwork behind the interactive glass surfaces.
class LiquidScene extends StatelessWidget {
  const LiquidScene({super.key});
  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: ExcludeSemantics(
      child: IgnorePointer(
        child: Image.asset(
          'assets/images/theme/liquid_background.png',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
      ),
    ),
  );
}
