import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/login_screen.dart';
import '../features/boot/boot_screen.dart';
import '../features/home/home_shell.dart';
import '../state/smartvax_controller.dart';

export '../features/boot/boot_screen.dart' show SmartVaxSplash;

class SmartVaxRoot extends StatefulWidget {
  const SmartVaxRoot({
    super.key,
    required this.controller,
    this.showSplash = true,
  });
  final SmartVaxController controller;
  final bool showSplash;

  @override
  State<SmartVaxRoot> createState() => _SmartVaxRootState();
}

class _SmartVaxRootState extends State<SmartVaxRoot> {
  late bool _intro = widget.showSplash;
  bool _revealing = false;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) => MaterialApp(
      key: ValueKey(widget.controller.currentUid),
      title: 'SmartVax',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: Stack(
        fit: StackFit.expand,
        children: [
          Offstage(
            offstage: _intro && !_revealing,
            child: TickerMode(
              enabled: !_intro,
              child: IgnorePointer(
                ignoring: _intro,
                child: ExcludeSemantics(
                  excluding: _intro,
                  child: widget.controller.isLoggedIn
                      ? HomeShell(controller: widget.controller)
                      : LoginScreen(controller: widget.controller),
                ),
              ),
            ),
          ),
          if (_intro)
            SmartVaxSplash(
              onReveal: () => setState(() => _revealing = true),
              onCompleted: () => setState(() => _intro = false),
            ),
        ],
      ),
    ),
  );
}
