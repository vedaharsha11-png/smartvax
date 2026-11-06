part of '../app_pages.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.controller,
    required this.onTab,
  });
  final SmartVaxController controller;
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    final child = controller.selectedChild;
    final guardian = controller.activeGuardian;
    if (child == null || guardian == null) {
      return _pageScroll(
        EmptyStateView(
          title: 'No child selected',
          message: 'Add a child profile to begin.',
          icon: Icons.child_care_rounded,
          action: 'Add child',
          onPressed: () =>
              pushPage(context, ChildFormPage(controller: controller)),
        ),
      );
    }
    final next = controller.nextAppointmentFor(child.id);
    return _pageScroll(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: BrandMark(compact: true)),
              IconButton(
                tooltip: 'Notifications',
                onPressed: () => onTab(3),
                icon: Badge(
                  isLabelVisible: controller.unreadCount > 0,
                  label: Text('${controller.unreadCount}'),
                  child: const GlossyIcon(
                    icon: Icons.notifications_rounded,
                    size: 44,
                  ),
                ),
              ),
            ],
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final scale = MediaQuery.textScalerOf(context).scale(1);
              if (scale > 1.3) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: DoctorChildArt(height: 165)),
                    Text(
                      'Hello, ${guardian.name.split(' ').first}!',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(fontSize: 26),
                    ),
                    const Text(
                      'Let’s keep your little one healthy and protected.',
                    ),
                  ],
                );
              }
              return SizedBox(
                height: 130,
                child: Stack(
                  children: [
                    Positioned(
                      right: -6,
                      bottom: 0,
                      width: constraints.maxWidth * .65,
                      child: const DoctorChildArt(height: 128),
                    ),
                    Positioned(
                      left: 0,
                      bottom: 12,
                      width: constraints.maxWidth * .51,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${guardian.name.split(' ').first}!',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontSize: 26, height: 1.1),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Let’s keep your little one healthy and protected.',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SectionHeader(
            'My children',
            action: 'Manage',
            onAction: () =>
                pushPage(context, ChildrenPage(controller: controller)),
          ),
          SizedBox(
            height: 70 * MediaQuery.textScalerOf(context).scale(1),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.activeChildren.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == controller.activeChildren.length) {
                  return _AddChildMini(controller: controller);
                }
                final item = controller.activeChildren[index];
                final selected = item.id == child.id;
                return SizedBox(
                  width: 156,
                  child: LiquidGlassCard(
                    radius: 21,
                    padding: const EdgeInsets.all(8),
                    borderColor: selected ? AppColors.blue : Colors.white,
                    onTap: () => controller.selectChild(item.id),
                    child: Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ChildAvatar(
                              child: item,
                              size: 49,
                              selected: selected,
                            ),
                            if (selected)
                              const Positioned(
                                bottom: -1,
                                right: -1,
                                child: Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: AppColors.blue,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name.split(' ').first,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.navy,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                ageLabel(item.dob, controller.now),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          LiquidGlassCard(
            padding: const EdgeInsets.all(16),
            onTap: () => pushPage(
              context,
              ChildProfilePage(controller: controller, childId: child.id),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ChildAvatar(child: child, size: 52, selected: true),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            child.name,
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(fontSize: 21),
                          ),
                          Text(
                            '${ageLabel(child.dob, controller.now)}  •  ${child.gender.name}',
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.blue),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Tracked record progress',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                    Text(
                      '${(controller.progress * 100).round()}%',
                      style: const TextStyle(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                GlossyProgress(value: controller.progress),
                const SizedBox(height: 5),
                Text(
                  '${controller.completedCount} of ${controller.trackedCount} tracked dose records completed',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          LiquidGlassCard(
            padding: const EdgeInsets.all(13),
            gradient: const LinearGradient(
              colors: [Color(0xfff5efff), Color(0xffe9daff), Color(0xffeefaff)],
            ),
            onTap: () =>
                pushPage(context, AppointmentsPage(controller: controller)),
            child: Row(
              children: [
                const GlossyIcon(
                  icon: Icons.calendar_month_rounded,
                  color: AppColors.violet,
                  size: 45,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Next local visit',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        next?.reason ?? 'No future visit saved',
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (next != null)
                        Text(
                          dateLabel(next.date),
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.blue),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryTile(
                value: '${controller.selectedPlanned.length}',
                label: 'Planned entries',
                icon: Icons.vaccines_rounded,
                tint: const Color(0xffffebc9),
                color: const Color(0xfffb9633),
                onTap: () => onTab(1),
              ),
              const SizedBox(width: 7),
              _SummaryTile(
                value: '${controller.completedCount}',
                label: 'Completed',
                icon: Icons.verified_rounded,
                tint: const Color(0xffc3fff0),
                color: AppColors.mint,
                onTap: () => onTab(2),
              ),
              const SizedBox(width: 7),
              _SummaryTile(
                value: next == null
                    ? '—'
                    : dateLabel(next.date).split(' ').take(2).join(' '),
                label: 'Next visit',
                icon: Icons.calendar_month_rounded,
                tint: const Color(0xffe4d6ff),
                color: AppColors.violet,
                onTap: () =>
                    pushPage(context, AppointmentsPage(controller: controller)),
              ),
            ],
          ),
          SectionHeader(
            'Quick access',
            action: 'Doctors',
            onAction: () =>
                pushPage(context, DoctorDirectoryPage(controller: controller)),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns =
                  constraints.maxWidth >= 350 &&
                      MediaQuery.textScalerOf(context).scale(1) <= 1.2
                  ? 4
                  : 2;
              final width =
                  (constraints.maxWidth - (columns - 1) * 7) / columns;
              return Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _QuickAction(
                    width: width,
                    label: 'Vaccine schedule',
                    icon: Icons.vaccines_rounded,
                    color: AppColors.blue,
                    onTap: () => onTab(1),
                  ),
                  _QuickAction(
                    width: width,
                    label: 'Health records',
                    icon: Icons.assignment_rounded,
                    color: AppColors.mint,
                    onTap: () => onTab(2),
                  ),
                  _QuickAction(
                    width: width,
                    label: 'Find centers',
                    icon: Icons.location_on_rounded,
                    color: AppColors.pink,
                    onTap: () => pushPage(
                      context,
                      HospitalDirectoryPage(controller: controller),
                    ),
                  ),
                  _QuickAction(
                    width: width,
                    label: 'Helpful guides',
                    icon: Icons.menu_book_rounded,
                    color: AppColors.violet,
                    onTap: () => pushPage(
                      context,
                      HealthTipsPage(controller: controller),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          appNotice(
            'Sample dates and records are illustrative. Confirm vaccination timing with a qualified health worker.',
          ),
        ],
      ),
    );
  }
}

class _AddChildMini extends StatelessWidget {
  const _AddChildMini({required this.controller});
  final SmartVaxController controller;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => pushPage(context, ChildFormPage(controller: controller)),
    child: Container(
      width: 76,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline, color: AppColors.blue, size: 31),
          SizedBox(height: 4),
          Text(
            'Add',
            style: TextStyle(color: AppColors.secondary, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.tint,
    required this.color,
    required this.onTap,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color tint;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: LiquidGlassCard(
      radius: 24,
      padding: const EdgeInsets.all(10),
      onTap: onTap,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          tint,
          tint.withValues(alpha: .75),
          Colors.white.withValues(alpha: .9),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlossyIcon(icon: icon, color: color, size: 36),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.secondary, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.width,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final double width;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: LiquidGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      radius: 20,
      onTap: onTap,
      child: Column(
        children: [
          GlossyIcon(icon: icon, color: color, size: 38),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key, required this.controller});
  final SmartVaxController controller;
  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late DateTime _month = DateTime(
    widget.controller.now.year,
    widget.controller.now.month,
  );
  late DateTime _selected = DateTime(
    widget.controller.now.year,
    widget.controller.now.month,
    widget.controller.now.day,
  );
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final child = c.selectedChild;
    if (child == null) {
      return _pageScroll(
        const EmptyStateView(
          title: 'No child selected',
          message: 'Add a child profile to view a schedule.',
          icon: Icons.calendar_month_rounded,
        ),
      );
    }
    final events = c.selectedRecords
        .where((r) => r.plannedFor != null)
        .map(
          (r) => DateTime(
            r.plannedFor!.year,
            r.plannedFor!.month,
            r.plannedFor!.day,
          ),
        )
        .toSet();
    final appointments = c
        .appointmentsFor(child.id)
        .map((a) => DateTime(a.date.year, a.date.month, a.date.day))
        .toSet();
    final firstWeekday = DateTime(_month.year, _month.month).weekday % 7;
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final planned = c.selectedPlanned.toList()
      ..sort(
        (a, b) => (a.plannedFor ?? DateTime(3000)).compareTo(
          b.plannedFor ?? DateTime(3000),
        ),
      );
    final selectedPlans = planned
        .where(
          (record) =>
              record.plannedFor != null &&
              _sameDay(record.plannedFor!, _selected),
        )
        .toList();
    final selectedVisits = c
        .appointmentsFor(child.id)
        .where((appointment) => _sameDay(appointment.date, _selected))
        .toList();
    return _pageScroll(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _pageTitle(context, 'Vaccination schedule', child.name),
              ),
              TextButton.icon(
                onPressed: () => pushPage(context, ChildrenPage(controller: c)),
                icon: const Icon(Icons.swap_horiz_rounded),
                label: const Text('Change child'),
              ),
            ],
          ),
          LiquidGlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(
                        () => _month = DateTime(_month.year, _month.month - 1),
                      ),
                      icon: const Icon(
                        Icons.chevron_left,
                        color: AppColors.blue,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${_monthName(_month.month)} ${_month.year}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(
                        () => _month = DateTime(_month.year, _month.month + 1),
                      ),
                      icon: const Icon(
                        Icons.chevron_right,
                        color: AppColors.blue,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    for (final d in ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              d,
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ((firstWeekday + days + 6) ~/ 7) * 7,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisExtent:
                        (MediaQuery.textScalerOf(context).scale(18) + 24)
                            .clamp(48, 96)
                            .toDouble(),
                  ),
                  itemBuilder: (context, index) {
                    final number = index - firstWeekday + 1;
                    if (number < 1 || number > days) {
                      return const SizedBox.shrink();
                    }
                    final date = DateTime(_month.year, _month.month, number);
                    final selected =
                        date.year == _selected.year &&
                        date.month == _selected.month &&
                        date.day == _selected.day;
                    final hasEvent =
                        events.contains(date) || appointments.contains(date);
                    return GestureDetector(
                      onTap: () => setState(() => _selected = date),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.blue
                              : Colors.white.withValues(alpha: .5),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$number',
                              style: TextStyle(
                                color: selected ? Colors.white : AppColors.navy,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                            ),
                            if (hasEvent)
                              Container(
                                width: 5,
                                height: 5,
                                margin: const EdgeInsets.only(top: 3),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Colors.white
                                      : AppColors.pink,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          LiquidGlassCard(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                const Icon(
                  Icons.event_available_rounded,
                  color: AppColors.violet,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Entries for ${dateLabel(_selected)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                      Text(
                        '${events.where((d) => _sameDay(d, _selected)).length} planned vaccine entries · ${appointments.where((d) => _sameDay(d, _selected)).length} visits',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionHeader('Items on ${dateLabel(_selected)}'),
          if (selectedPlans.isEmpty && selectedVisits.isEmpty)
            const EmptyStateView(
              title: 'No saved items for this date',
              message: 'Choose a highlighted date or add a local visit plan.',
              icon: Icons.event_available_outlined,
            ),
          ...selectedPlans.map(
            (record) => _VaccineRecordTile(
              controller: c,
              record: record,
              onTap: () => pushPage(
                context,
                VaccineRecordPage(controller: c, recordId: record.id),
              ),
            ),
          ),
          ...selectedVisits.map(
            (appointment) =>
                _AppointmentTile(controller: c, appointment: appointment),
          ),
          const SizedBox(height: 4),
          SectionHeader(
            'Planned entries',
            action: 'Add',
            onAction: () => pushPage(context, RecordFormPage(controller: c)),
          ),
          if (planned.isEmpty)
            const EmptyStateView(
              title: 'Nothing planned yet',
              message: 'Add a local visit plan whenever you need one.',
              icon: Icons.event_note_rounded,
            )
          else
            ...planned.map(
              (record) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _VaccineRecordTile(
                    controller: c,
                    record: record,
                    onTap: () => pushPage(
                      context,
                      VaccineRecordPage(controller: c, recordId: record.id),
                    ),
                  ),
                  _ReminderControls(controller: c, record: record),
                ],
              ),
            ),
          const SizedBox(height: 8),
          LiquidGlassCard(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.blue,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'In-app reminders',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                    Switch(
                      value: c.settings.remindersEnabled,
                      onChanged: c.toggleAllReminders,
                    ),
                  ],
                ),
                const Text(
                  'Reminders are shown inside SmartVax while you use it. No device notification is scheduled.',
                  style: TextStyle(color: AppColors.secondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          appNotice(
            'This calendar displays saved sample and visit-plan dates. It is not a clinical due-date calculator. Confirm the schedule with a health worker.',
          ),
        ],
      ),
    );
  }
}

String _monthName(int month) => const [
  '',
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
][month];
bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key, required this.controller});
  final SmartVaxController controller;
  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  String _filter = 'All';
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final child = c.selectedChild;
    if (child == null) {
      return _pageScroll(
        const EmptyStateView(
          title: 'No child selected',
          message: 'Add a child profile to view records.',
          icon: Icons.assignment_rounded,
        ),
      );
    }
    final records = c.selectedRecords.where((r) {
      final statusMatches =
          _filter == 'All' ||
          (_filter == 'Completed'
              ? r.status == RecordStatus.completed
              : r.status != RecordStatus.completed);
      final vaccine = c.vaccineById(r.vaccineId)?.name.toLowerCase() ?? '';
      return statusMatches &&
          ('$vaccine ${r.dose}'.toLowerCase().contains(_query.toLowerCase()));
    }).toList();
    return _pageScroll(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _pageTitle(context, 'Vaccination records', child.name),
              ),
              IconButton(
                tooltip: 'Add record',
                onPressed: () =>
                    pushPage(context, RecordFormPage(controller: c)),
                icon: const Icon(
                  Icons.add_circle,
                  color: AppColors.blue,
                  size: 30,
                ),
              ),
            ],
          ),
          LiquidGlassCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ChildAvatar(child: child, size: 56, selected: true),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.name,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${ageLabel(child.dob, c.now)} · ${child.gender.name}',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      pushPage(context, ChildrenPage(controller: c)),
                  child: const Text('Change'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search vaccines or dose',
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            children: [
              for (final label in ['All', 'Completed', 'Pending'])
                ChoiceChip(
                  label: Text(label),
                  selected: _filter == label,
                  onSelected: (_) => setState(() => _filter = label),
                ),
            ],
          ),
          const SizedBox(height: 7),
          if (records.isEmpty)
            const EmptyStateView(
              title: 'No matching records',
              message: 'Try another filter or add a record.',
              icon: Icons.search_off_rounded,
            )
          else
            ...records.map(
              (record) => _VaccineRecordTile(
                controller: c,
                record: record,
                onTap: () => pushPage(
                  context,
                  VaccineRecordPage(controller: c, recordId: record.id),
                ),
              ),
            ),
          const SizedBox(height: 8),
          appNotice(
            'Records synchronize with your account. They are not an official immunization certificate.',
          ),
        ],
      ),
    );
  }
}

class _VaccineRecordTile extends StatelessWidget {
  const _VaccineRecordTile({
    required this.controller,
    required this.record,
    required this.onTap,
  });
  final SmartVaxController controller;
  final VaccinationRecord record;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final vaccine = controller.vaccineById(record.vaccineId);
    final completed = record.status == RecordStatus.completed;
    final today = DateTime(
      controller.now.year,
      controller.now.month,
      controller.now.day,
    );
    final planDay = record.plannedFor == null
        ? null
        : DateTime(
            record.plannedFor!.year,
            record.plannedFor!.month,
            record.plannedFor!.day,
          );
    final pastPlan = planDay != null && planDay.isBefore(today);
    final status = completed
        ? 'Completed'
        : pastPlan
        ? 'Past plan date'
        : record.status == RecordStatus.pending
        ? 'Needs confirmation'
        : 'Planned';
    return LiquidGlassCard(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      radius: 19,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (vaccine?.color ?? AppColors.blue).withValues(alpha: .14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              vaccine?.icon ?? Icons.vaccines,
              color: vaccine?.color ?? AppColors.blue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccine?.name ?? 'Vaccine',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                Text(
                  record.dose,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  completed && record.administeredAt != null
                      ? dateLabel(record.administeredAt!)
                      : record.plannedFor == null
                      ? 'No date saved'
                      : dateLabel(record.plannedFor!),
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          StatusPill(
            label: status,
            color: _statusColor(completed ? 'completed' : status),
          ),
          const Icon(Icons.chevron_right, color: AppColors.blue),
        ],
      ),
    );
  }
}

class _ReminderControls extends StatelessWidget {
  const _ReminderControls({required this.controller, required this.record});
  final SmartVaxController controller;
  final VaccinationRecord record;

  @override
  Widget build(BuildContext context) => LiquidGlassCard(
    margin: const EdgeInsets.only(bottom: 8),
    padding: EdgeInsets.zero,
    radius: 18,
    child: ExpansionTile(
      leading: const Icon(
        Icons.notifications_active_outlined,
        color: AppColors.blue,
      ),
      title: const Text(
        'Reminder checklist',
        style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w700),
      ),
      subtitle: const Text('Choose when to show an in-app reminder'),
      children: [
        for (final days in const [7, 3, 1, 0])
          SwitchListTile(
            dense: true,
            title: Text(
              days == 0
                  ? 'On the planned date'
                  : '$days ${days == 1 ? 'day' : 'days'} before',
            ),
            value: controller.reminders.any(
              (reminder) =>
                  reminder.recordId == record.id &&
                  reminder.daysBefore == days &&
                  reminder.enabled,
            ),
            onChanged: (enabled) =>
                controller.toggleReminder(record.id, days, enabled),
          ),
      ],
    ),
  );
}
