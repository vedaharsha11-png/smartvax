part of '../app_pages.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key, required this.controller});
  final SmartVaxController controller;
  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  String _filter = 'All';
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final items = c.notifications
        .where(
          (n) =>
              _filter == 'All' ||
              (_filter == 'Unread'
                  ? !n.read
                  : n.type.name == _filter.toLowerCase()),
        )
        .toList();
    return _pageScroll(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _pageTitle(
                  context,
                  'Alerts & tips',
                  'Helpful updates for your family',
                ),
              ),
              if (c.unreadCount > 0)
                TextButton(
                  onPressed: c.markAllRead,
                  child: const Text('Mark all read'),
                ),
            ],
          ),
          Wrap(
            spacing: 7,
            children: [
              for (final label in [
                'All',
                'Unread',
                'Vaccine',
                'Appointment',
                'Tip',
              ])
                ChoiceChip(
                  label: Text(label),
                  selected: _filter == label,
                  onSelected: (_) => setState(() => _filter = label),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const EmptyStateView(
              title: 'You’re all caught up',
              message: 'There are no alerts in this filter.',
              icon: Icons.notifications_none_rounded,
            ),
          ...items.map((item) => _NotificationTile(controller: c, item: item)),
          const SizedBox(height: 6),
          SectionHeader(
            'Parent health tips',
            action: 'View all',
            onAction: () => pushPage(context, HealthTipsPage(controller: c)),
          ),
          ...c.tips
              .take(3)
              .map(
                (tip) => LiquidGlassCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(13),
                  onTap: () => pushPage(context, HealthTipPage(tip: tip)),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.violet,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tip.title,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.blue),
                    ],
                  ),
                ),
              ),
          LiquidGlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Need support?',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _supportDialog(context),
                        icon: const Icon(Icons.support_agent),
                        label: const Text('Contact support'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            pushPage(context, HelpPage(controller: c)),
                        icon: const Icon(Icons.help_outline),
                        label: const Text('Help center'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _supportDialog(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Support'),
      content: const Text(
        'No support request is sent from this screen. Use the Help Center for app guidance.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.controller, required this.item});
  final SmartVaxController controller;
  final NotificationItem item;
  @override
  Widget build(BuildContext context) => LiquidGlassCard(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(13),
    opacity: item.read ? .48 : .75,
    onTap: () {
      controller.markRead(item.id);
      _openNotice(context, controller, item);
    },
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: .12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            item.type == NoticeType.tip
                ? Icons.favorite_rounded
                : item.type == NoticeType.appointment
                ? Icons.calendar_month_rounded
                : Icons.vaccines_rounded,
            color: AppColors.blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.message,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateLabel(item.createdAt),
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        if (!item.read)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, size: 9, color: AppColors.pink),
          ),
        IconButton(
          tooltip: 'Clear alert',
          onPressed: () => controller.removeNotification(item.id),
          icon: const Icon(Icons.close, size: 18, color: AppColors.secondary),
        ),
      ],
    ),
  );
}

void _openNotice(
  BuildContext context,
  SmartVaxController c,
  NotificationItem item,
) {
  if (item.type == NoticeType.appointment) {
    pushPage(context, AppointmentsPage(controller: c));
  } else if (item.type == NoticeType.vaccine ||
      item.type == NoticeType.record) {
    if (item.referenceId != null && c.recordById(item.referenceId) != null) {
      pushPage(
        context,
        VaccineRecordPage(controller: c, recordId: item.referenceId!),
      );
    } else {
      pushPage(context, RecordsPage(controller: c));
    }
  } else if (item.type == NoticeType.tip) {
    pushPage(context, HealthTipsPage(controller: c));
  } else {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.title),
        content: Text(item.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.controller});
  final SmartVaxController controller;
  @override
  Widget build(BuildContext context) {
    final parent = controller.activeGuardian;
    if (parent == null) {
      return _pageScroll(
        const EmptyStateView(
          title: 'Profile unavailable',
          message: 'Sign in again to continue.',
          icon: Icons.person_outline,
        ),
      );
    }
    return _pageScroll(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _pageTitle(
            context,
            'Family profile',
            'Your local household overview',
          ),
          LiquidGlassCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                _avatar(parent.avatar, size: 66, tint: AppColors.pink),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parent.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${parent.relation} · +91 ${parent.mobile}',
                        style: const TextStyle(color: AppColors.secondary),
                      ),
                      const SizedBox(height: 4),
                      const StatusPill(
                        label: 'Preview profile',
                        color: AppColors.blue,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit profile',
                  onPressed: () => pushPage(
                    context,
                    GuardianFormPage(
                      controller: controller,
                      guardianId: parent.id,
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, color: AppColors.blue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SectionHeader(
            'Children',
            action: 'Manage',
            onAction: () =>
                pushPage(context, ChildrenPage(controller: controller)),
          ),
          ...controller.activeChildren.map(
            (child) => LiquidGlassCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              onTap: () => pushPage(
                context,
                ChildProfilePage(controller: controller, childId: child.id),
              ),
              child: Row(
                children: [
                  ChildAvatar(child: child, size: 48),
                  const SizedBox(width: 10),
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
                          ageLabel(child.dob, controller.now),
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.selectChild(child.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${child.name} selected')),
                      );
                    },
                    child: Text(
                      controller.selectedChildId == child.id
                          ? 'Selected'
                          : 'Switch',
                    ),
                  ),
                ],
              ),
            ),
          ),
          LiquidGlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Family address',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.selectedChild?.address ??
                      'Add a family address in a child profile.',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Emergency contact',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                Text(
                  controller.selectedChild?.emergencyContact ??
                      'Rahul Sharma • 9876543211',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SectionHeader('More'),
          _MenuLink(
            icon: Icons.calendar_month_rounded,
            label: 'Appointments',
            onTap: () =>
                pushPage(context, AppointmentsPage(controller: controller)),
          ),
          _MenuLink(
            icon: Icons.medical_services_rounded,
            label: 'Doctors',
            onTap: () =>
                pushPage(context, DoctorDirectoryPage(controller: controller)),
          ),
          _MenuLink(
            icon: Icons.local_hospital_rounded,
            label: 'Vaccination centers',
            onTap: () => pushPage(
              context,
              HospitalDirectoryPage(controller: controller),
            ),
          ),
          _MenuLink(
            icon: Icons.tune_rounded,
            label: 'Settings',
            onTap: () =>
                pushPage(context, SettingsPage(controller: controller)),
          ),
          _MenuLink(
            icon: Icons.help_outline_rounded,
            label: 'Help center',
            onTap: () => pushPage(context, HelpPage(controller: controller)),
          ),
          _MenuLink(
            icon: Icons.info_outline_rounded,
            label: 'About SmartVax',
            onTap: () => pushPage(context, AboutPage(controller: controller)),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              controller.switchParent();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Showing ${controller.activeGuardian?.name ?? 'parent'} profile',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Switch parent profile'),
          ),
          const SizedBox(height: 7),
          GradientButton(
            label: 'Log out',
            icon: Icons.logout_rounded,
            danger: true,
            onPressed: () async {
              if (await _confirm(
                context,
                'Log out?',
                'This signs out of your Firebase account. Wait for pending changes to synchronize before signing out.',
              )) {
                controller.logout();
              }
            },
          ),
          const SizedBox(height: 12),
          appNotice(
            'Account information synchronizes with Cloud Firestore. Cached information is available during this session; reconnect to confirm pending changes.',
          ),
        ],
      ),
    );
  }
}

class _MenuLink extends StatelessWidget {
  const _MenuLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => LiquidGlassCard(
    margin: const EdgeInsets.only(bottom: 7),
    padding: EdgeInsets.zero,
    radius: 17,
    onTap: onTap,
    child: ListTile(
      leading: Icon(icon, color: AppColors.blue),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.navy,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.secondary),
      minTileHeight: 52,
    ),
  );
}

class ChildrenPage extends StatelessWidget {
  const ChildrenPage({super.key, required this.controller});
  final SmartVaxController controller;
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'My children',
    trailing: IconButton(
      tooltip: 'Add child',
      onPressed: () => pushPage(context, ChildFormPage(controller: controller)),
      icon: const Icon(Icons.add, color: AppColors.blue),
    ),
    child: _pageScroll(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _pageTitle(
            context,
            'Family accounts',
            'Switch between your children’s profiles',
          ),
          ...controller.activeChildren.map((child) {
            final mother = controller.guardianById(child.motherId);
            final father = controller.guardianById(child.fatherId);
            final selected = controller.selectedChildId == child.id;
            return LiquidGlassCard(
              margin: const EdgeInsets.only(bottom: 12),
              borderColor: selected ? AppColors.cyan : null,
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ChildAvatar(child: child, size: 64, selected: selected),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              child.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              ageLabel(child.dob, controller.now),
                              style: const TextStyle(
                                color: AppColors.secondary,
                              ),
                            ),
                            Text(
                              child.gender.name,
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        const StatusPill(
                          label: 'Current child',
                          color: AppColors.mint,
                        ),
                    ],
                  ),
                  const Divider(height: 21, color: Color(0x3380a5da)),
                  Row(
                    children: [
                      Expanded(child: _parentMini(context, 'Mother', mother)),
                      const SizedBox(width: 5),
                      Expanded(child: _parentMini(context, 'Father', father)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => pushPage(
                            context,
                            ChildProfilePage(
                              controller: controller,
                              childId: child.id,
                            ),
                          ),
                          icon: const Icon(Icons.person_outline),
                          label: const Text('View profile'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GradientButton(
                          expanded: true,
                          label: selected ? 'Selected' : 'Switch child',
                          icon: Icons.swap_horiz_rounded,
                          onPressed: selected
                              ? null
                              : () {
                                  controller.selectChild(child.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${child.name} selected'),
                                    ),
                                  );
                                },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          LiquidGlassCard(
            onTap: () =>
                pushPage(context, ChildFormPage(controller: controller)),
            child: const Row(
              children: [
                Icon(Icons.add_circle_outline, color: AppColors.blue, size: 34),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add a child',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        'Create a new local child profile',
                        style: TextStyle(color: AppColors.secondary),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.blue),
              ],
            ),
          ),
          const SizedBox(height: 10),
          appNotice(
            'Changing parent profiles keeps the same shared household and children.',
          ),
        ],
      ),
    ),
  );
}

Widget _parentMini(
  BuildContext context,
  String relation,
  Guardian? guardian,
) => Row(
  children: [
    _avatar(
      guardian?.avatar ?? '🙂',
      size: 35,
      tint: relation == 'Mother' ? AppColors.pink : AppColors.blue,
    ),
    const SizedBox(width: 7),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            relation,
            style: const TextStyle(fontSize: 11, color: AppColors.secondary),
          ),
          Text(
            guardian?.name ?? 'Not set',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          Text(
            guardian?.mobile ?? '',
            style: const TextStyle(color: AppColors.secondary, fontSize: 10),
          ),
        ],
      ),
    ),
  ],
);

class ChildProfilePage extends StatelessWidget {
  const ChildProfilePage({
    super.key,
    required this.controller,
    required this.childId,
  });
  final SmartVaxController controller;
  final String childId;

  void _schedule(BuildContext context) {
    controller.selectChild(childId);
    pushPage(context, SchedulePage(controller: controller));
  }

  void _records(BuildContext context) {
    controller.selectChild(childId);
    pushPage(context, RecordsPage(controller: controller));
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final child = controller.childById(childId);
      if (child == null) {
        return const AppPage(
          title: 'Child profile',
          child: EmptyStateView(
            title: 'Profile unavailable',
            message: 'This child profile is no longer available.',
            icon: Icons.child_care,
          ),
        );
      }
      final records = controller.recordsFor(child.id);
      final completed = records
          .where((r) => r.status == RecordStatus.completed)
          .length;
      final tracked = records.length;
      final progress = tracked == 0 ? 0.0 : completed / tracked;
      final next = controller.nextAppointmentFor(child.id);
      return AppPage(
        title: 'Child profile',
        trailing: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GlassIconButton(
            label: 'Edit profile',
            icon: Icons.edit_rounded,
            onPressed: () => pushPage(
              context,
              ChildFormPage(controller: controller, child: child),
            ),
          ),
        ),
        bottomBar: _contextNavigation(context, [
          (
            Icons.home_rounded,
            'Home',
            () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
          (Icons.child_care_rounded, 'Child profile', null),
          (Icons.calendar_month_rounded, 'Schedule', () => _schedule(context)),
          (Icons.assignment_rounded, 'Records', () => _records(context)),
        ], selected: 'Child profile'),
        child: _pageScroll(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LiquidGlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ChildAvatar(child: child, size: 83, selected: true),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            child.name,
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(fontSize: 23),
                          ),
                          Text(
                            ageLabel(child.dob, controller.now),
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: [
                              StatusPill(
                                label: child.gender.name,
                                color: AppColors.blue,
                              ),
                              StatusPill(
                                label: child.bloodGroup.isEmpty
                                    ? 'Not recorded'
                                    : child.bloodGroup,
                                color: AppColors.pink,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              LiquidGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const GlossyIcon(
                          icon: Icons.vaccines_rounded,
                          size: 43,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Vaccination progress',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GlossyProgress(value: progress),
                    const SizedBox(height: 6),
                    Text(
                      '$completed of $tracked tracked dose entries marked complete',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      next == null
                          ? 'No upcoming local visit'
                          : 'Next visit: ${dateLabel(next.date)} · ${next.reason}',
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    OutlinedButton.icon(
                      onPressed: () => _schedule(context),
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('View full schedule'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              LiquidGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      'Personal information',
                      icon: Icons.person_rounded,
                    ),
                    _rowLabel(
                      'Date of birth',
                      dateLabel(child.dob),
                      icon: Icons.calendar_month_rounded,
                    ),
                    _rowLabel(
                      'Gender',
                      child.gender.name,
                      icon: Icons.person_outline_rounded,
                    ),
                    _rowLabel(
                      'Blood group',
                      child.bloodGroup.isEmpty
                          ? 'Not recorded'
                          : child.bloodGroup,
                      icon: Icons.water_drop_rounded,
                    ),
                    _rowLabel(
                      'Child ID',
                      child.cardId,
                      icon: Icons.badge_rounded,
                    ),
                    _rowLabel(
                      'Notes',
                      child.notes,
                      icon: Icons.description_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              LiquidGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      'Linked parents',
                      icon: Icons.people_rounded,
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final mother = _parentMini(
                          context,
                          'Mother',
                          controller.guardianById(child.motherId),
                        );
                        final father = _parentMini(
                          context,
                          'Father',
                          controller.guardianById(child.fatherId),
                        );
                        if (constraints.maxWidth < 325 ||
                            MediaQuery.textScalerOf(context).scale(1) > 1.2) {
                          return Column(
                            children: [
                              mother,
                              const SizedBox(height: 10),
                              father,
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: mother),
                            const SizedBox(width: 8),
                            Expanded(child: father),
                          ],
                        );
                      },
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed: () => pushPage(
                            context,
                            GuardianFormPage(
                              controller: controller,
                              guardianId: child.motherId,
                            ),
                          ),
                          child: const Text('Edit mother'),
                        ),
                        TextButton(
                          onPressed: () => pushPage(
                            context,
                            GuardianFormPage(
                              controller: controller,
                              guardianId: child.fatherId,
                            ),
                          ),
                          child: const Text('Edit father'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              LiquidGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      'Address & emergency contact',
                      icon: Icons.location_on_rounded,
                    ),
                    Text(
                      child.address,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      child.emergencyContact,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              LiquidGlassCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      'Recent vaccine status',
                      action: 'View records',
                      icon: Icons.verified_rounded,
                      onAction: () => _records(context),
                    ),
                    if (records.isEmpty)
                      const Text(
                        'No tracked records yet.',
                        style: TextStyle(color: AppColors.secondary),
                      )
                    else
                      SizedBox(
                        height: 155 * MediaQuery.textScalerOf(context).scale(1),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: records.length.clamp(0, 4),
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final record = records[index];
                            final vaccine = controller.vaccineById(
                              record.vaccineId,
                            );
                            final status = _recordStatus(
                              record,
                              controller.now,
                            );
                            return SizedBox(
                              width:
                                  160 *
                                  MediaQuery.textScalerOf(
                                    context,
                                  ).scale(1).clamp(1, 1.5),
                              child: LiquidGlassCard(
                                radius: 20,
                                padding: const EdgeInsets.all(10),
                                onTap: () => pushPage(
                                  context,
                                  VaccineRecordPage(
                                    controller: controller,
                                    recordId: record.id,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        GlossyIcon(
                                          icon:
                                              vaccine?.icon ??
                                              Icons.vaccines_rounded,
                                          color:
                                              vaccine?.color ?? AppColors.blue,
                                          size: 32,
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            vaccine?.name ?? 'Vaccine',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: AppColors.navy,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      record.dose,
                                      style: const TextStyle(
                                        color: AppColors.secondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      record.administeredAt == null
                                          ? record.plannedFor == null
                                                ? 'Confirm timing'
                                                : dateLabel(record.plannedFor!)
                                          : dateLabel(record.administeredAt!),
                                      style: const TextStyle(
                                        color: AppColors.secondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const Spacer(),
                                    StatusPill(
                                      label: status,
                                      color: _statusColor(status),
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
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () =>
                    pushPage(context, ChildrenPage(controller: controller)),
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Switch child'),
              ),
              const SizedBox(height: 7),
              GradientButton(
                label: 'Vaccination history',
                icon: Icons.assignment,
                onPressed: () => _records(context),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () async {
                  final confirmed = await _confirm(
                    context,
                    'Remove ${child.name}?',
                    'This archives this child and their linked vaccination records, visits, reminders and alerts. They will be hidden from active screens; medical history remains in your private account.',
                    action: 'Remove child',
                  );
                  if (confirmed) {
                    controller.removeChild(child.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.delete_outline, color: AppColors.pink),
                label: const Text(
                  'Remove child',
                  style: TextStyle(color: AppColors.pink),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class ChildFormPage extends StatefulWidget {
  const ChildFormPage({super.key, required this.controller, this.child});
  final SmartVaxController controller;
  final ChildProfile? child;
  @override
  State<ChildFormPage> createState() => _ChildFormPageState();
}

class _ChildFormPageState extends State<ChildFormPage> {
  late final _name = TextEditingController(text: widget.child?.name ?? '');
  late final _blood = TextEditingController(
    text: widget.child?.bloodGroup ?? '',
  );
  late final _notes = TextEditingController(text: widget.child?.notes ?? '');
  late final _address = TextEditingController(
    text:
        widget.child?.address ??
        widget.controller.children.firstOrNull?.address ??
        '',
  );
  late final _emergency = TextEditingController(
    text:
        widget.child?.emergencyContact ??
        '${widget.controller.guardianById('g_father')?.name ?? 'Parent'} • ${widget.controller.guardianById('g_father')?.mobile ?? ''}',
  );
  late DateTime _dob =
      widget.child?.dob ??
      DateTime(
        widget.controller.now.year,
        widget.controller.now.month,
        widget.controller.now.day,
      );
  late ChildGender _gender = widget.child?.gender ?? ChildGender.other;
  late String _motherId = widget.child?.motherId ?? 'g_mother';
  late String _fatherId = widget.child?.fatherId ?? 'g_father';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose();
    _blood.dispose();
    _notes.dispose();
    _address.dispose();
    _emergency.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppPage(
    title: widget.child == null ? 'Add child' : 'Edit child',
    child: _pageScroll(
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _pageTitle(
              context,
              widget.child == null
                  ? 'New child profile'
                  : 'Update child profile',
              'Information synchronizes with your account',
            ),
            LiquidGlassCard(
              child: Column(
                children: [
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'Child’s name',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Enter a name.' : null,
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.calendar_month,
                      color: AppColors.blue,
                    ),
                    title: const Text('Date of birth'),
                    subtitle: Text(dateLabel(_dob)),
                    trailing: const Icon(
                      Icons.edit_calendar,
                      color: AppColors.blue,
                    ),
                    onTap: _pickDate,
                  ),
                  DropdownButtonFormField<ChildGender>(
                    initialValue: _gender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: ChildGender.values
                        .map(
                          (g) =>
                              DropdownMenuItem(value: g, child: Text(g.name)),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _gender = v ?? ChildGender.other),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _blood,
                    decoration: const InputDecoration(
                      labelText: 'Blood group (optional)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _motherId,
                    decoration: const InputDecoration(labelText: 'Mother'),
                    items: widget.controller.guardians
                        .map(
                          (g) => DropdownMenuItem(
                            value: g.id,
                            child: Text(g.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _motherId = v ?? _motherId),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _fatherId,
                    decoration: const InputDecoration(labelText: 'Father'),
                    items: widget.controller.guardians
                        .map(
                          (g) => DropdownMenuItem(
                            value: g.id,
                            child: Text(g.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _fatherId = v ?? _fatherId),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _notes,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Health notes (optional)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _address,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Family address',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emergency,
                    decoration: const InputDecoration(
                      labelText: 'Emergency contact',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GradientButton(
              label: widget.child == null
                  ? 'Save child profile'
                  : 'Save changes',
              icon: Icons.check_rounded,
              onPressed: _save,
            ),
            const SizedBox(height: 10),
            appNotice(
              'Contact details are informational. This app does not place calls or verify addresses.',
            ),
          ],
        ),
      ),
    ),
  );
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(1900),
      lastDate: widget.controller.now,
      helpText: 'Choose date of birth',
    );
    if (picked != null) setState(() => _dob = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final old = widget.child;
    final usedCardIds = widget.controller.children
        .map((child) => child.cardId)
        .toSet();
    var cardNumber = 1001;
    while (usedCardIds.contains('SV-CH-$cardNumber')) {
      cardNumber++;
    }
    final item = old == null
        ? ChildProfile(
            id: '',
            name: _name.text.trim(),
            dob: _dob,
            gender: _gender,
            bloodGroup: _blood.text.trim(),
            cardId: 'SV-CH-$cardNumber',
            avatar: _gender == ChildGender.female ? '👧🏻' : '👦🏻',
            motherId: _motherId,
            fatherId: _fatherId,
            address: _address.text.trim(),
            emergencyContact: _emergency.text.trim(),
            notes: _notes.text.trim(),
          )
        : old.copyWith(
            name: _name.text,
            dob: _dob,
            gender: _gender,
            bloodGroup: _blood.text.trim(),
            notes: _notes.text.trim(),
            address: _address.text.trim(),
            emergencyContact: _emergency.text.trim(),
          );
    if (widget.controller.saveChild(item, isNew: old == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child profile changes waiting for sync')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Check the date of birth. It cannot conflict with completed records.',
          ),
        ),
      );
    }
  }
}

class GuardianFormPage extends StatefulWidget {
  const GuardianFormPage({
    super.key,
    required this.controller,
    required this.guardianId,
  });
  final SmartVaxController controller;
  final String guardianId;
  @override
  State<GuardianFormPage> createState() => _GuardianFormPageState();
}

class _GuardianFormPageState extends State<GuardianFormPage> {
  late final guardian = widget.controller.guardianById(widget.guardianId)!;
  late final name = TextEditingController(text: guardian.name);
  late final mobile = TextEditingController(text: guardian.mobile);
  @override
  void dispose() {
    name.dispose();
    mobile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Edit parent',
    child: _pageScroll(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _pageTitle(context, 'Parent details', guardian.relation),
          LiquidGlassCard(
            child: Column(
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: mobile,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Mobile number',
                    prefixText: '+91  ',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GradientButton(
            label: 'Save parent details',
            icon: Icons.check,
            onPressed: () {
              final ok = widget.controller.updateGuardian(
                widget.guardianId,
                name: name.text,
                mobile: mobile.text,
              );
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Enter a name and a unique 10-digit number.'),
                  ),
                );
                return;
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.action,
    this.onPressed,
  });
  final String title;
  final String message;
  final IconData icon;
  final String? action;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => LiquidGlassCard(
    padding: const EdgeInsets.all(22),
    child: Column(
      children: [
        Icon(icon, size: 42, color: AppColors.blue),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.secondary),
        ),
        if (action != null) ...[
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onPressed, child: Text(action!)),
        ],
      ],
    ),
  );
}
