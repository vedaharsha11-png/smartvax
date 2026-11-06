part of '../app_pages.dart';

class DoctorDirectoryPage extends StatefulWidget {
  const DoctorDirectoryPage({super.key, required this.controller});
  final SmartVaxController controller;
  @override
  State<DoctorDirectoryPage> createState() => _DoctorDirectoryPageState();
}

class _DoctorDirectoryPageState extends State<DoctorDirectoryPage> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final doctors = widget.controller.doctors
        .where(
          (d) => '${d.name} ${d.specialty} ${d.area}'.toLowerCase().contains(
            _query.toLowerCase(),
          ),
        )
        .toList();
    return AppPage(
      title: 'Doctors',
      child: _pageScroll(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _pageTitle(
              context,
              'Pediatric care directory',
              'Fictional sample profiles',
            ),
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search doctors',
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 11),
            if (doctors.isEmpty)
              const EmptyStateView(
                title: 'No doctors found',
                message: 'Try another name or area.',
                icon: Icons.search_off_rounded,
              ),
            ...doctors.map((doctor) {
              final hospital = widget.controller.hospitalById(
                doctor.hospitalId,
              );
              final count = widget.controller.records
                  .where((r) => r.doctorId == doctor.id)
                  .length;
              return LiquidGlassCard(
                margin: const EdgeInsets.only(bottom: 11),
                padding: const EdgeInsets.all(15),
                onTap: () => pushPage(
                  context,
                  DoctorProfilePage(
                    controller: widget.controller,
                    doctorId: doctor.id,
                  ),
                ),
                child: Row(
                  children: [
                    _avatar(doctor.avatar, size: 63, tint: AppColors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            doctor.specialty,
                            style: const TextStyle(
                              color: AppColors.violet,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            hospital?.name ?? 'Center not listed',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${doctor.area} · $count linked sample records',
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.blue),
                  ],
                ),
              );
            }),
            appNotice(
              'Provider details, qualifications and linked records are fictional sample information. No verification or real reviews are represented.',
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorProfilePage extends StatelessWidget {
  const DoctorProfilePage({
    super.key,
    required this.controller,
    required this.doctorId,
  });
  final SmartVaxController controller;
  final String doctorId;
  @override
  Widget build(BuildContext context) {
    final doctor = controller.doctorById(doctorId);
    if (doctor == null) {
      return const AppPage(
        title: 'Doctor profile',
        child: EmptyStateView(
          title: 'Profile unavailable',
          message: 'This doctor is not listed.',
          icon: Icons.medical_services_outlined,
        ),
      );
    }
    final hospital = controller.hospitalById(doctor.hospitalId);
    final records = controller.records
        .where((r) => r.doctorId == doctor.id)
        .take(4);
    return AppPage(
      title: 'Doctor profile',
      child: _pageScroll(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LiquidGlassCard(
              padding: const EdgeInsets.all(17),
              child: Column(
                children: [
                  _avatar(doctor.avatar, size: 100, tint: AppColors.blue),
                  const SizedBox(height: 9),
                  Text(
                    doctor.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(fontSize: 23),
                  ),
                  Text(
                    doctor.specialty,
                    style: const TextStyle(
                      color: AppColors.violet,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    hospital?.name ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.secondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StatusPill(
                        label: '${doctor.experience} years · sample',
                        color: AppColors.blue,
                      ),
                      const SizedBox(width: 7),
                      const StatusPill(
                        label: 'Fictional profile',
                        color: AppColors.violet,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader('About'),
                  Text(
                    doctor.bio,
                    style: const TextStyle(color: AppColors.secondary),
                  ),
                  const SizedBox(height: 8),
                  _rowLabel('Qualification', doctor.qualification),
                  _rowLabel('Specialty', doctor.specialty),
                  _rowLabel('Area', doctor.area),
                ],
              ),
            ),
            const SizedBox(height: 11),
            if (hospital != null)
              LiquidGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader('Associated center'),
                    Text(
                      hospital.name,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${hospital.area}, ${hospital.city}',
                      style: const TextStyle(color: AppColors.secondary),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => pushPage(
                        context,
                        HospitalDetailPage(
                          controller: controller,
                          hospitalId: hospital.id,
                        ),
                      ),
                      icon: const Icon(Icons.local_hospital),
                      label: const Text('View center'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 11),
            SectionHeader('Linked sample records'),
            if (records.isEmpty)
              const EmptyStateView(
                title: 'No linked records',
                message:
                    'No records currently reference this fictional provider.',
                icon: Icons.assignment_outlined,
              )
            else
              ...records.map(
                (r) => _VaccineRecordTile(
                  controller: controller,
                  record: r,
                  onTap: () => pushPage(
                    context,
                    VaccineRecordPage(controller: controller, recordId: r.id),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Contact details'),
                        content: const Text(
                          'This profile is fictional. No phone call is available.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                    icon: const Icon(Icons.call_outlined),
                    label: const Text('Call information'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GradientButton(
                    label: 'Request visit',
                    icon: Icons.calendar_month,
                    onPressed: () => pushPage(
                      context,
                      AppointmentFormPage(
                        controller: controller,
                        doctorId: doctor.id,
                        hospitalId: doctor.hospitalId,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            appNotice(
              'Profile details are fictional examples. A saved visit request is local and does not contact a clinic.',
            ),
          ],
        ),
      ),
    );
  }
}

class HospitalDirectoryPage extends StatelessWidget {
  const HospitalDirectoryPage({super.key, required this.controller});
  final SmartVaxController controller;
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Vaccination centers',
    child: _pageScroll(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _pageTitle(
            context,
            'Care centers',
            'Illustrative locations in Vijayawada',
          ),
          ...controller.hospitals.map(
            (hospital) => LiquidGlassCard(
              margin: const EdgeInsets.only(bottom: 11),
              padding: const EdgeInsets.all(15),
              onTap: () => pushPage(
                context,
                HospitalDetailPage(
                  controller: controller,
                  hospitalId: hospital.id,
                ),
              ),
              child: Row(
                children: [
                  _avatar(
                    hospital.illustration,
                    size: 62,
                    tint: AppColors.violet,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hospital.name,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${hospital.area}, ${hospital.city}',
                          style: const TextStyle(color: AppColors.secondary),
                        ),
                        Text(
                          hospital.services.take(2).join(' · '),
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.blue),
                ],
              ),
            ),
          ),
          appNotice(
            'All centers, addresses and contact numbers are fictional examples. Live directions and hospital bookings are not available.',
          ),
        ],
      ),
    ),
  );
}

class HospitalDetailPage extends StatelessWidget {
  const HospitalDetailPage({
    super.key,
    required this.controller,
    required this.hospitalId,
  });
  final SmartVaxController controller;
  final String hospitalId;
  @override
  Widget build(BuildContext context) {
    final hospital = controller.hospitalById(hospitalId);
    if (hospital == null) {
      return const AppPage(
        title: 'Center details',
        child: EmptyStateView(
          title: 'Center unavailable',
          message: 'This center is not listed.',
          icon: Icons.local_hospital_outlined,
        ),
      );
    }
    final doctors = hospital.doctorIds
        .map(controller.doctorById)
        .whereType<DoctorProfile>()
        .toList();
    final appointments = controller.appointments
        .where((a) => a.hospitalId == hospital.id)
        .toList();
    return AppPage(
      title: 'Center details',
      child: _pageScroll(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LiquidGlassCard(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 138,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xffc9f5ff), Color(0xffe6dcff)],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        hospital.illustration,
                        style: const TextStyle(fontSize: 74),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hospital.name,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontSize: 21),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${hospital.area}, ${hospital.city}, ${hospital.state}',
                    style: const TextStyle(color: AppColors.secondary),
                  ),
                  const SizedBox(height: 8),
                  const StatusPill(
                    label: 'Fictional sample center',
                    color: AppColors.violet,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader('Center information'),
                  _rowLabel(
                    'Address',
                    hospital.address,
                    icon: Icons.location_on_outlined,
                  ),
                  _rowLabel('Hours', hospital.hours, icon: Icons.access_time),
                  _rowLabel(
                    'Contact',
                    hospital.phone,
                    icon: Icons.call_outlined,
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Example contact details only; no call will be placed.',
                    style: TextStyle(color: AppColors.secondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader('Services'),
                  ...hospital.services.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 17,
                            color: AppColors.mint,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              s,
                              style: const TextStyle(
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                  const SectionHeader('Illustrative location'),
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [Color(0xffe1f9ed), Color(0xffdceeff)],
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(double.infinity, 120),
                          painter: _MapLinesPainter(),
                        ),
                        const Icon(
                          Icons.location_on_rounded,
                          size: 40,
                          color: AppColors.pink,
                        ),
                        Positioned(
                          bottom: 7,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .86),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              hospital.area,
                              style: const TextStyle(
                                color: AppColors.navy,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  OutlinedButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Directions unavailable'),
                        content: const Text(
                          'This sample location is illustrative. SmartVax does not connect to maps or provide live directions.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                    icon: const Icon(Icons.near_me_outlined),
                    label: const Text('Get directions'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SectionHeader('Associated doctors'),
            ...doctors.map(
              (d) => LiquidGlassCard(
                margin: const EdgeInsets.only(bottom: 8),
                onTap: () => pushPage(
                  context,
                  DoctorProfilePage(controller: controller, doctorId: d.id),
                ),
                child: Row(
                  children: [
                    _avatar(d.avatar, size: 42),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        d.name,
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
            SectionHeader('Related local visit requests'),
            if (appointments.isEmpty)
              const Text(
                'No local visits are listed.',
                style: TextStyle(color: AppColors.secondary),
              )
            else
              ...appointments.map(
                (a) => _AppointmentTile(controller: controller, appointment: a),
              ),
            const SizedBox(height: 9),
            GradientButton(
              label: 'Request a visit',
              icon: Icons.calendar_month,
              onPressed: () => pushPage(
                context,
                AppointmentFormPage(
                  controller: controller,
                  hospitalId: hospital.id,
                ),
              ),
            ),
            const SizedBox(height: 9),
            appNotice(
              'Visit requests synchronize with your account. This center is fictional and no booking or confirmation is sent.',
            ),
          ],
        ),
      ),
    );
  }
}

class _MapLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white.withValues(alpha: .85)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;
    final thin = Paint()
      ..color = AppColors.blue.withValues(alpha: .12)
      ..strokeWidth = 1.5;
    for (var i = 0; i < 5; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + (i.isEven ? 14 : -12)),
        road,
      );
      final x = size.width * i / 4;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + (i.isEven ? 12 : -8), size.height),
        thin,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key, required this.controller});
  final SmartVaxController controller;
  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  bool _previous = false;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final controller = widget.controller;
      final all = [...controller.appointments]
        ..sort((a, b) => a.date.compareTo(b.date));
      bool previous(Appointment appointment) {
        final date = DateTime(
          appointment.date.year,
          appointment.date.month,
          appointment.date.day,
          appointment.time.hour,
          appointment.time.minute,
        );
        return appointment.status == AppointmentStatus.completed ||
            appointment.status == AppointmentStatus.cancelled ||
            date.isBefore(controller.now);
      }

      final upcoming = all.where((a) => !previous(a)).toList();
      final history = all.where(previous).toList().reversed.toList();
      final visible = _previous ? history : upcoming;
      return AppPage(
        title: 'Family visits',
        trailing: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GlassIconButton(
            label: 'Request visit',
            icon: Icons.add_rounded,
            onPressed: () =>
                pushPage(context, AppointmentFormPage(controller: controller)),
          ),
        ),
        bottomBar: _contextNavigation(context, [
          (
            Icons.home_rounded,
            'Home',
            () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
          (Icons.calendar_month_rounded, 'Visits', null),
          (
            Icons.assignment_rounded,
            'Records',
            () => pushPage(context, RecordsPage(controller: controller)),
          ),
          (
            Icons.notifications_rounded,
            'Alerts',
            () => pushPage(context, AlertsPage(controller: controller)),
          ),
          (
            Icons.person_rounded,
            'Profile',
            () => pushPage(context, ProfilePage(controller: controller)),
          ),
        ], selected: 'Visits'),
        child: _pageScroll(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: BrandMark(compact: true)),
              _pageTitle(
                context,
                'Family visits',
                'View and manage health visit plans for your children.',
              ),
              LiquidGlassCard(
                padding: const EdgeInsets.all(5),
                radius: 30,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final buttons = <Widget>[
                      _VisitSegment(
                        label: 'Upcoming visits (${upcoming.length})',
                        selected: !_previous,
                        icon: Icons.calendar_month_rounded,
                        onTap: () => setState(() => _previous = false),
                      ),
                      _VisitSegment(
                        label: 'Previous visits (${history.length})',
                        selected: _previous,
                        icon: Icons.history_rounded,
                        onTap: () => setState(() => _previous = true),
                      ),
                    ];
                    if (MediaQuery.textScalerOf(context).scale(1) > 1.3) {
                      return Column(children: buttons);
                    }
                    return Row(
                      children: buttons
                          .map((button) => Expanded(child: button))
                          .toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SectionHeader(_previous ? 'Previous visits' : 'Upcoming visits'),
              if (visible.isEmpty)
                EmptyStateView(
                  title: _previous
                      ? 'No previous visits'
                      : 'No upcoming visits',
                  message: 'Save a local visit request for your family.',
                  icon: Icons.calendar_month_rounded,
                  action: 'Request visit',
                  onPressed: () => pushPage(
                    context,
                    AppointmentFormPage(controller: controller),
                  ),
                )
              else
                ...visible.map(
                  (a) =>
                      _AppointmentTile(controller: controller, appointment: a),
                ),
              const SizedBox(height: 8),
              GradientButton(
                label: 'Request a visit',
                icon: Icons.add_rounded,
                onPressed: () => pushPage(
                  context,
                  AppointmentFormPage(controller: controller),
                ),
              ),
              const SizedBox(height: 10),
              appNotice(
                'A saved or planned request does not mean the center confirmed a visit. Marking a visit attended does not add a vaccine record.',
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _VisitSegment extends StatelessWidget {
  const _VisitSegment({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        constraints: const BoxConstraints(minHeight: 50),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: 1.5,
          ),
          gradient: selected
              ? const LinearGradient(
                  colors: [AppColors.cyan, AppColors.blue, Color(0xff1453ff)],
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? Colors.white : AppColors.secondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: selected ? Colors.white : AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({required this.controller, required this.appointment});
  final SmartVaxController controller;
  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final child = controller.childById(appointment.childId);
    final doctor = controller.doctorById(appointment.doctorId);
    final hospital = controller.hospitalById(appointment.hospitalId);
    final status = switch (appointment.status) {
      AppointmentStatus.requested => 'Request saved',
      AppointmentStatus.scheduled => 'Locally planned',
      AppointmentStatus.completed => 'Attended',
      AppointmentStatus.cancelled => 'Cancelled',
    };
    return LiquidGlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (child != null) ChildAvatar(child: child, size: 58),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child?.name ?? 'Child removed',
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w900,
                        fontSize: 19,
                      ),
                    ),
                    Text(
                      child == null
                          ? ''
                          : '${ageLabel(child.dob, controller.now)} · ${child.gender.name}',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    StatusPill(label: status, color: _statusColor(status)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LiquidGlassCard(
            radius: 22,
            padding: const EdgeInsets.all(11),
            onTap: () => pushPage(
              context,
              DoctorProfilePage(
                controller: controller,
                doctorId: appointment.doctorId,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const GlossyIcon(
                      icon: Icons.calendar_month_rounded,
                      color: AppColors.violet,
                      size: 34,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_fullDate(appointment.date)} · ${timeLabel(appointment.time)}',
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const GlossyIcon(
                      icon: Icons.medical_services_rounded,
                      size: 34,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor?.name ?? 'No doctor',
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            hospital?.name ?? 'No center',
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
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            appointment.reason,
            style: const TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (appointment.notes.isNotEmpty)
            Text(
              appointment.notes,
              style: const TextStyle(color: AppColors.secondary, fontSize: 11),
            ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text(
              'Visit preparation checklist',
              style: TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            children: [
              for (final item in SmartVaxController.visitChecklistItems)
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(item, style: const TextStyle(fontSize: 12)),
                  value: controller.isChecklistItemChecked(
                    appointment.id,
                    item,
                  ),
                  onChanged: (checked) => controller.setChecklistItem(
                    appointment.id,
                    item,
                    checked ?? false,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Wrap(
            spacing: 4,
            children: [
              TextButton(
                onPressed: () => pushPage(
                  context,
                  ChildProfilePage(
                    controller: controller,
                    childId: appointment.childId,
                  ),
                ),
                child: const Text('Child'),
              ),
              TextButton(
                onPressed: () => pushPage(
                  context,
                  DoctorProfilePage(
                    controller: controller,
                    doctorId: appointment.doctorId,
                  ),
                ),
                child: const Text('Doctor'),
              ),
              TextButton(
                onPressed: () => pushPage(
                  context,
                  HospitalDetailPage(
                    controller: controller,
                    hospitalId: appointment.hospitalId,
                  ),
                ),
                child: const Text('Center'),
              ),
              if (appointment.status != AppointmentStatus.completed &&
                  appointment.status != AppointmentStatus.cancelled)
                PopupMenuButton<String>(
                  tooltip: 'Appointment actions',
                  onSelected: (value) => _action(context, value),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(
                      value: 'complete',
                      child: Text('Mark attended'),
                    ),
                    PopupMenuItem(value: 'cancel', child: Text('Cancel visit')),
                  ],
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.more_horiz, color: AppColors.blue),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _action(BuildContext context, String action) {
    if (action == 'edit') {
      pushPage(
        context,
        AppointmentFormPage(controller: controller, appointment: appointment),
      );
    }
    if (action == 'complete') {
      controller.updateAppointmentStatus(
        appointment.id,
        AppointmentStatus.completed,
      );
    }
    if (action == 'cancel') {
      _confirm(
        context,
        'Cancel this visit?',
        'The local appointment entry will be marked cancelled.',
        action: 'Cancel visit',
      ).then((yes) {
        if (yes) {
          controller.updateAppointmentStatus(
            appointment.id,
            AppointmentStatus.cancelled,
          );
        }
      });
    }
  }
}

class AppointmentFormPage extends StatefulWidget {
  const AppointmentFormPage({
    super.key,
    required this.controller,
    this.appointment,
    this.doctorId,
    this.hospitalId,
  });
  final SmartVaxController controller;
  final Appointment? appointment;
  final String? doctorId;
  final String? hospitalId;
  @override
  State<AppointmentFormPage> createState() => _AppointmentFormPageState();
}

class _AppointmentFormPageState extends State<AppointmentFormPage> {
  late String _childId =
      widget.appointment?.childId ?? widget.controller.selectedChildId;
  late String _doctorId =
      widget.appointment?.doctorId ??
      widget.doctorId ??
      widget.controller.doctors.firstOrNull?.id ??
      '';
  late String _hospitalId =
      widget.appointment?.hospitalId ??
      widget.hospitalId ??
      widget.controller.doctorById(_doctorId)?.hospitalId ??
      '';
  late final _reason = TextEditingController(
    text: widget.appointment?.reason ?? 'Vaccination consultation',
  );
  late final _notes = TextEditingController(
    text: widget.appointment?.notes ?? '',
  );
  late DateTime _date =
      widget.appointment?.date ??
      widget.controller.now.add(const Duration(days: 7));
  late TimeOfDay _time =
      widget.appointment?.time ?? const TimeOfDay(hour: 10, minute: 0);
  bool _saving = false;
  @override
  void dispose() {
    _reason.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.children.isEmpty ||
        widget.controller.doctors.isEmpty ||
        widget.controller.hospitals.isEmpty) {
      return const AppPage(
        title: 'Request visit',
        child: EmptyStateView(
          title: 'Visit details unavailable',
          message:
              'A child and care provider must be available in your account before saving a visit request.',
          icon: Icons.calendar_month_rounded,
        ),
      );
    }
    return AppPage(
      title: widget.appointment == null ? 'Request visit' : 'Edit visit',
      child: _pageScroll(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _pageTitle(
              context,
              'Local visit request',
              'No center confirmation is sent',
            ),
            LiquidGlassCard(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _childId,
                    decoration: const InputDecoration(labelText: 'Child'),
                    items: widget.controller.children
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _childId = v ?? _childId),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _doctorId,
                    decoration: const InputDecoration(labelText: 'Doctor'),
                    items: widget.controller.doctors
                        .map(
                          (d) => DropdownMenuItem(
                            value: d.id,
                            child: Text(d.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() {
                      _doctorId = v ?? _doctorId;
                      _hospitalId = widget.controller
                          .doctorById(_doctorId)!
                          .hospitalId;
                    }),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _hospitalId,
                    decoration: const InputDecoration(labelText: 'Center'),
                    items: widget.controller.hospitals
                        .map(
                          (h) => DropdownMenuItem(
                            value: h.id,
                            child: Text(
                              h.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() {
                      _hospitalId = v ?? _hospitalId;
                      final associatedDoctors =
                          widget.controller
                              .hospitalById(_hospitalId)
                              ?.doctorIds ??
                          const <String>[];
                      if (!associatedDoctors.contains(_doctorId) &&
                          associatedDoctors.isNotEmpty) {
                        _doctorId = associatedDoctors.first;
                      }
                    }),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _reason,
                    decoration: const InputDecoration(
                      labelText: 'Reason for visit',
                    ),
                  ),
                  const SizedBox(height: 5),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.calendar_month,
                      color: AppColors.blue,
                    ),
                    title: const Text('Date'),
                    subtitle: Text(dateLabel(_date)),
                    onTap: _pickDate,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.access_time,
                      color: AppColors.blue,
                    ),
                    title: const Text('Time'),
                    subtitle: Text(timeLabel(_time)),
                    onTap: _pickTime,
                  ),
                  TextField(
                    controller: _notes,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GradientButton(
              label: _saving ? 'Saving…' : 'Save visit request',
              icon: Icons.calendar_month,
              onPressed: _saving ? null : _save,
            ),
            const SizedBox(height: 9),
            appNotice(
              'This creates a local request only. It does not book a real appointment, contact the doctor, or mark a vaccine as completed.',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final initial = _date.isBefore(widget.controller.now)
        ? widget.controller.now
        : _date;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(
        widget.controller.now.year,
        widget.controller.now.month,
        widget.controller.now.day,
      ),
      lastDate: DateTime(widget.controller.now.year + 5),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    setState(() => _saving = true);
    final old = widget.appointment;
    final item = Appointment(
      id: old?.id ?? 'appt_${DateTime.now().microsecondsSinceEpoch}',
      childId: _childId,
      doctorId: _doctorId,
      hospitalId: _hospitalId,
      reason: _reason.text,
      date: _date,
      time: _time,
      status: old?.status ?? AppointmentStatus.requested,
      notes: _notes.text,
    );
    final ok = widget.controller.saveAppointment(item, editingId: old?.id);
    setState(() => _saving = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a visit reason and choose a future date.'),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Visit request waiting for sync')),
    );
    Navigator.pop(context);
  }
}
