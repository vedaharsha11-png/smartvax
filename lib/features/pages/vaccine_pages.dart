part of '../app_pages.dart';

class VaccineRecordPage extends StatelessWidget {
  const VaccineRecordPage({
    super.key,
    required this.controller,
    required this.recordId,
  });
  final SmartVaxController controller;
  final String recordId;
  @override
  Widget build(BuildContext context) {
    final record = controller.recordById(recordId);
    if (record == null) {
      return const AppPage(
        title: 'Vaccination record',
        child: EmptyStateView(
          title: 'Record unavailable',
          message: 'This record may have been removed.',
          icon: Icons.assignment_outlined,
        ),
      );
    }
    final child = controller.childById(record.childId);
    final vaccine = controller.vaccineById(record.vaccineId);
    final doctor = controller.doctorById(record.doctorId);
    final hospital = controller.hospitalById(record.hospitalId);
    final completed = record.status == RecordStatus.completed;
    final summary =
        '''SmartVax — Sample information\nNot an official immunization certificate\nChild: ${child?.name ?? 'Child'}\nVaccine: ${vaccine?.name ?? 'Vaccine'}\nDose: ${record.dose}\nStatus: ${completed ? 'Completed' : 'Planned / pending'}\nDate: ${completed
            ? dateLabel(record.administeredAt!)
            : record.plannedFor == null
            ? 'Not set'
            : dateLabel(record.plannedFor!)}\nCenter: ${hospital?.name ?? 'Not recorded'}\nDoctor: ${doctor?.name ?? 'Not recorded'}\nBatch: ${record.batchNumber.isEmpty ? 'Not recorded' : record.batchNumber}\nNotes: ${record.notes.isEmpty ? 'None' : record.notes}''';
    return AppPage(
      title: 'Vaccination record',
      child: _pageScroll(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LiquidGlassCard(
              child: Row(
                children: [
                  if (child != null) ChildAvatar(child: child, size: 62),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child?.name ?? 'Child',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          child == null
                              ? ''
                              : ageLabel(child.dob, controller.now),
                          style: const TextStyle(color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        pushPage(context, ChildrenPage(controller: controller)),
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            LiquidGlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: (vaccine?.color ?? AppColors.blue).withValues(
                            alpha: .14,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          vaccine?.icon ?? Icons.vaccines,
                          color: vaccine?.color ?? AppColors.blue,
                          size: 27,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vaccine?.name ?? 'Vaccine',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              record.dose,
                              style: const TextStyle(
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusPill(
                        label: completed
                            ? 'Completed'
                            : record.status == RecordStatus.pending
                            ? 'Needs confirmation'
                            : 'Planned',
                        color: completed ? AppColors.mint : AppColors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Text(
                    vaccine?.expandedName ?? '',
                    style: const TextStyle(color: AppColors.secondary),
                  ),
                  const SizedBox(height: 10),
                  _rowLabel(
                    completed ? 'Recorded date' : 'Planned date',
                    completed
                        ? dateLabel(record.administeredAt!)
                        : record.plannedFor == null
                        ? 'Not set'
                        : dateLabel(record.plannedFor!),
                  ),
                  _rowLabel('Dose label', record.dose),
                  _rowLabel(
                    'Batch number',
                    record.batchNumber.isEmpty
                        ? 'Not recorded'
                        : record.batchNumber,
                  ),
                  if (vaccine != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 9),
                      child: Text(
                        vaccine.reference,
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader('Hospital or center'),
                  if (hospital == null)
                    const Text(
                      'No center recorded',
                      style: TextStyle(color: AppColors.secondary),
                    )
                  else
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: _avatar(hospital.illustration, size: 46),
                      title: Text(
                        hospital.name,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        '${hospital.area}, ${hospital.city}',
                        style: const TextStyle(color: AppColors.secondary),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColors.blue,
                      ),
                      onTap: () => pushPage(
                        context,
                        HospitalDetailPage(
                          controller: controller,
                          hospitalId: hospital.id,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader('Vaccinating doctor'),
                  if (doctor == null)
                    const Text(
                      'No doctor recorded',
                      style: TextStyle(color: AppColors.secondary),
                    )
                  else
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: _avatar(
                        doctor.avatar,
                        size: 48,
                        tint: AppColors.blue,
                      ),
                      title: Text(
                        doctor.name,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        '${doctor.specialty} · Fictional sample profile',
                        style: const TextStyle(color: AppColors.secondary),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColors.blue,
                      ),
                      onTap: () => pushPage(
                        context,
                        DoctorProfilePage(
                          controller: controller,
                          doctorId: doctor.id,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader('Notes'),
                  Text(
                    record.notes.isEmpty ? 'No notes saved.' : record.notes,
                    style: const TextStyle(color: AppColors.secondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Record ID: ${record.id}',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    record.seeded
                        ? 'Source: illustrative bundled sample'
                        : 'Source: entered in this account',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: summary));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Record summary copied'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Copy summary'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: summary));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Share summary copied. Paste it into a message when ready.',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GradientButton(
              label: 'Edit record',
              icon: Icons.edit_rounded,
              onPressed: () => pushPage(
                context,
                RecordFormPage(controller: controller, record: record),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                if (await _confirm(
                  context,
                  'Delete record?',
                  'This removes the local record and its reminders.',
                )) {
                  controller.deleteRecord(record.id);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.delete_outline, color: AppColors.pink),
              label: const Text(
                'Delete record',
                style: TextStyle(color: AppColors.pink),
              ),
            ),
            appNotice(
              'Sample information — not an official immunization certificate. Confirm entries with the health worker who provided care.',
            ),
          ],
        ),
      ),
    );
  }
}

class RecordFormPage extends StatefulWidget {
  const RecordFormPage({super.key, required this.controller, this.record});
  final SmartVaxController controller;
  final VaccinationRecord? record;
  @override
  State<RecordFormPage> createState() => _RecordFormPageState();
}

class _RecordFormPageState extends State<RecordFormPage> {
  late String _childId =
      widget.record?.childId ?? widget.controller.selectedChildId;
  late String _vaccineId =
      widget.record?.vaccineId ?? widget.controller.vaccines.first.id;
  late String _dose =
      widget.record?.dose ?? widget.controller.vaccines.first.doses.first;
  late RecordStatus _status = widget.record?.status ?? RecordStatus.completed;
  late DateTime _date =
      widget.record?.administeredAt ??
      DateTime(
        widget.controller.now.year,
        widget.controller.now.month,
        widget.controller.now.day,
      );
  late DateTime _planned =
      widget.record?.plannedFor ??
      widget.controller.now.add(const Duration(days: 7));
  late String? _doctorId = widget.record?.doctorId ?? 'doctor_ananya';
  late String? _hospitalId = widget.record?.hospitalId ?? 'hospital_sunrise';
  late final _batch = TextEditingController(
    text: widget.record?.batchNumber ?? '',
  );
  late final _notes = TextEditingController(text: widget.record?.notes ?? '');
  bool _saving = false;
  @override
  void dispose() {
    _batch.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vaccine = widget.controller.vaccineById(_vaccineId)!;
    final compatibleDoctors = widget.controller.doctors
        .where((d) => _hospitalId == null || d.hospitalId == _hospitalId)
        .toList();
    return AppPage(
      title: widget.record == null ? 'Add record' : 'Edit record',
      child: _pageScroll(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _pageTitle(
              context,
              widget.record == null
                  ? 'Vaccination entry'
                  : 'Update vaccination',
              'Use information from the official card',
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
                    initialValue: _vaccineId,
                    decoration: const InputDecoration(labelText: 'Vaccine'),
                    items: widget.controller.vaccines
                        .map(
                          (v) => DropdownMenuItem(
                            value: v.id,
                            child: Text(
                              v.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() {
                      _vaccineId = v ?? _vaccineId;
                      _dose = widget.controller
                          .vaccineById(_vaccineId)!
                          .doses
                          .first;
                    }),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: vaccine.doses.contains(_dose)
                        ? _dose
                        : vaccine.doses.first,
                    decoration: const InputDecoration(labelText: 'Dose'),
                    items: vaccine.doses
                        .map(
                          (dose) =>
                              DropdownMenuItem(value: dose, child: Text(dose)),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _dose = v ?? _dose),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<RecordStatus>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Entry status',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: RecordStatus.completed,
                        child: Text('Completed'),
                      ),
                      DropdownMenuItem(
                        value: RecordStatus.planned,
                        child: Text('Planned visit'),
                      ),
                      DropdownMenuItem(
                        value: RecordStatus.pending,
                        child: Text('Needs confirmation'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _status = v ?? _status),
                  ),
                  const SizedBox(height: 5),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      _status == RecordStatus.completed
                          ? Icons.event_available
                          : Icons.event_note,
                      color: AppColors.blue,
                    ),
                    title: Text(
                      _status == RecordStatus.completed
                          ? 'Date administered'
                          : 'Illustrative planned date',
                    ),
                    subtitle: Text(
                      dateLabel(
                        _status == RecordStatus.completed ? _date : _planned,
                      ),
                    ),
                    onTap: _pickDate,
                  ),
                  DropdownButtonFormField<String?>(
                    initialValue: _doctorId,
                    decoration: const InputDecoration(
                      labelText: 'Doctor (optional)',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Unknown / not recorded'),
                      ),
                      ...compatibleDoctors.map(
                        (d) => DropdownMenuItem<String?>(
                          value: d.id,
                          child: Text(d.name),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() {
                      _doctorId = v;
                      if (v != null) {
                        _hospitalId = widget.controller
                            .doctorById(v)!
                            .hospitalId;
                      }
                    }),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String?>(
                    initialValue: _hospitalId,
                    decoration: const InputDecoration(
                      labelText: 'Center (optional)',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Unknown / not recorded'),
                      ),
                      ...widget.controller.hospitals.map(
                        (h) => DropdownMenuItem<String?>(
                          value: h.id,
                          child: Text(h.name, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() {
                      _hospitalId = v;
                      if (_doctorId != null &&
                          widget.controller.doctorById(_doctorId)?.hospitalId !=
                              v) {
                        _doctorId = null;
                      }
                    }),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _batch,
                    decoration: const InputDecoration(
                      labelText: 'Batch number (optional)',
                    ),
                  ),
                  const SizedBox(height: 10),
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
              label: _saving ? 'Saving…' : 'Save record',
              icon: Icons.check_rounded,
              onPressed: _saving ? null : _save,
            ),
            const SizedBox(height: 9),
            appNotice(
              _status == RecordStatus.completed
                  ? 'A completed date must be on or after the child’s birth and cannot be in the future.'
                  : 'Planned dates are personal reminders only. They do not indicate medical eligibility or a due date.',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final child = widget.controller.childById(_childId);
    final first = _status == RecordStatus.completed
        ? (child?.dob ?? DateTime(2000))
        : DateTime(
            widget.controller.now.year,
            widget.controller.now.month,
            widget.controller.now.day,
          );
    final last = _status == RecordStatus.completed
        ? widget.controller.now
        : DateTime(widget.controller.now.year + 5);
    final current = _status == RecordStatus.completed ? _date : _planned;
    final picked = await showDatePicker(
      context: context,
      initialDate: current.isBefore(first)
          ? first
          : current.isAfter(last)
          ? last
          : current,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) {
      setState(() {
        if (_status == RecordStatus.completed) {
          _date = picked;
        } else {
          _planned = picked;
        }
      });
    }
  }

  void _save() {
    setState(() => _saving = true);
    final old = widget.record;
    final item = VaccinationRecord(
      id: old?.id ?? 'record_${DateTime.now().microsecondsSinceEpoch}',
      childId: _childId,
      vaccineId: _vaccineId,
      dose: _dose,
      status: _status,
      administeredAt: _status == RecordStatus.completed ? _date : null,
      plannedFor: _status == RecordStatus.completed ? null : _planned,
      doctorId: _doctorId,
      hospitalId: _hospitalId,
      batchNumber: _batch.text,
      notes: _notes.text,
    );
    final ok = widget.controller.saveRecord(item, editingId: old?.id);
    setState(() => _saving = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review the child, vaccine, and date fields.'),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Record changes waiting for sync')),
    );
    Navigator.pop(context);
  }
}
