import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass.dart';
import '../../state/smartvax_controller.dart';
import '../app_pages.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.controller});
  final SmartVaxController controller;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) => Scaffold(
      extendBody: true,
      appBar: widget.controller.accountRepository == null
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(28),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        widget.controller.syncMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    if (widget.controller.accountError != null)
                      TextButton(
                        onPressed: widget.controller.retryAccount,
                        child: const Text('Retry'),
                      ),
                  ],
                ),
              ),
            ),
      body: LiquidBackground(
        child: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _selected,
            children: [
              DashboardPage(
                controller: widget.controller,
                onTab: (index) => setState(() => _selected = index),
              ),
              SchedulePage(controller: widget.controller),
              RecordsPage(controller: widget.controller),
              AlertsPage(controller: widget.controller),
              ProfilePage(controller: widget.controller),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: LiquidGlassCard(
            radius: 32,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            opacity: .74,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                  selected: _selected,
                  onTap: _select,
                ),
                _NavItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'Schedule',
                  index: 1,
                  selected: _selected,
                  onTap: _select,
                ),
                _NavItem(
                  icon: Icons.assignment_rounded,
                  label: 'Records',
                  index: 2,
                  selected: _selected,
                  onTap: _select,
                ),
                _NavItem(
                  icon: Icons.notifications_rounded,
                  label: 'Alerts',
                  index: 3,
                  selected: _selected,
                  onTap: _select,
                  badge: widget.controller.unreadCount,
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  index: 4,
                  selected: _selected,
                  onTap: _select,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  void _select(int index) => setState(() => _selected = index);
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });
  final IconData icon;
  final String label;
  final int index;
  final int selected;
  final ValueChanged<int> onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final active = index == selected;
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: () => onTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 190),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: active
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xffecffff),
                        Color(0xffa5dcff),
                        Color(0xffd2f8ff),
                      ],
                    )
                  : null,
              border: Border.all(
                color: active ? Colors.white : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AppColors.blue.withValues(alpha: .1),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      color: active ? AppColors.blue : AppColors.secondary,
                      size: 26,
                    ),
                    if (badge > 0)
                      Positioned(
                        right: -8,
                        top: -7,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: AppColors.pink,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$badge',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    color: active ? AppColors.blue : AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
