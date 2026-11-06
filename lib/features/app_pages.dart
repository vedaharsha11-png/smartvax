import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_theme.dart';
import '../core/widgets/glass.dart';
import '../data/models.dart';
import '../state/smartvax_controller.dart';

part 'pages/home_vaccine_tabs.dart';
part 'pages/alerts_family_pages.dart';
part 'pages/vaccine_pages.dart';
part 'pages/provider_appointment_pages.dart';
part 'pages/account_pages.dart';

void pushPage(BuildContext context, Widget page) {
  final routeInfo = switch (page) {
    SchedulePage p => ('Schedule', p.controller),
    RecordsPage p => ('Records', p.controller),
    AlertsPage p => ('Alerts', p.controller),
    ProfilePage p => ('Profile', p.controller),
    _ => null,
  };
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => routeInfo == null
          ? page
          : ListenableBuilder(
              listenable: routeInfo.$2,
              builder: (context, _) =>
                  AppPage(title: routeInfo.$1, child: page),
            ),
    ),
  );
}

String _recordStatus(VaccinationRecord record, DateTime now) {
  if (record.status == RecordStatus.completed) return 'Completed';
  final today = DateTime(now.year, now.month, now.day);
  if (record.plannedFor != null && record.plannedFor!.isBefore(today)) {
    return 'Past plan date';
  }
  return record.status == RecordStatus.pending
      ? 'Needs confirmation'
      : 'Planned';
}

Widget _contextNavigation(
  BuildContext context,
  List<(IconData, String, VoidCallback?)> destinations, {
  required String selected,
}) => SafeArea(
  top: false,
  child: Padding(
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
    child: LiquidGlassCard(
      radius: 32,
      padding: const EdgeInsets.all(5),
      child: Row(
        children: destinations
            .map(
              (item) => Expanded(
                child: Semantics(
                  selected: item.$2 == selected,
                  child: InkWell(
                    onTap: item.$3,
                    borderRadius: BorderRadius.circular(27),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(27),
                        gradient: item.$2 == selected
                            ? const LinearGradient(
                                colors: [Colors.white, Color(0xffafe7ff)],
                              )
                            : null,
                        border: Border.all(
                          color: item.$2 == selected
                              ? Colors.white
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.$1,
                            size: 26,
                            color: item.$2 == selected
                                ? AppColors.blue
                                : AppColors.secondary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.$2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: item.$2 == selected
                                  ? AppColors.blue
                                  : AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    ),
  ),
);

String dateLabel(DateTime date) =>
    '${date.day} ${_month(date.month)} ${date.year}';
String _month(int month) => const [
  '',
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
][month];
String timeLabel(TimeOfDay time) =>
    '${time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}';
String _fullDate(DateTime date) =>
    '${_weekday(date.weekday)}, ${date.day} ${_month(date.month)} ${date.year}';
String _weekday(int day) =>
    const ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day];

Color _statusColor(String value) => switch (value.toLowerCase()) {
  'completed' || 'attended' => AppColors.mint,
  'upcoming' || 'requested' || 'scheduled locally' => AppColors.blue,
  'planned' || 'confirm timing' => AppColors.amber,
  'cancelled' => AppColors.secondary,
  _ => AppColors.violet,
};

Widget _pageScroll(
  Widget child, {
  EdgeInsets padding = const EdgeInsets.fromLTRB(16, 8, 16, 104),
}) => SingleChildScrollView(padding: padding, child: child);

Widget _avatar(String emoji, {double size = 48, Color? tint}) => Container(
  width: size,
  height: size,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      colors: [
        tint?.withValues(alpha: .2) ?? AppColors.cyan.withValues(alpha: .2),
        AppColors.violet.withValues(alpha: .16),
      ],
    ),
    border: Border.all(color: Colors.white, width: 2),
  ),
  alignment: Alignment.center,
  child: Text(emoji, style: TextStyle(fontSize: size * .52)),
);

Widget _pageTitle(BuildContext context, String title, String subtitle) =>
    Padding(
      padding: const EdgeInsets.only(top: 9, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.secondary, fontSize: 13),
          ),
        ],
      ),
    );

Widget _rowLabel(String label, String value, {IconData? icon}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 5),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (icon != null) ...[
        Icon(icon, size: 17, color: AppColors.blue),
        const SizedBox(width: 8),
      ],
      SizedBox(
        width: icon == null ? 100 : 84,
        child: Text(
          label,
          style: const TextStyle(color: AppColors.secondary, fontSize: 13),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    ],
  ),
);

Future<bool> _confirm(
  BuildContext context,
  String title,
  String body, {
  String action = 'Continue',
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xfff7fbff),
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;
