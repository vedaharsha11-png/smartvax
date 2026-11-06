import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/model_codec.dart';
import '../data/repositories/account_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/migration/sample_data_migration.dart';
import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/sample_data.dart';

class SmartVaxController extends ChangeNotifier {
  SmartVaxController({
    DateTime Function()? clock,
    required this.authRepository,
    required this.accountRepository,
  }) : _clock = clock ?? DateTime.now {
    if (authRepository == null || accountRepository == null) {
      throw ArgumentError('Firebase repositories are required');
    }
    _clearAccount();
    _authSubscription = authRepository!.changes.listen(
      _onAuth,
      onError: (Object e) {
        accountError = 'Unable to restore authentication.';
        _emit();
      },
    );
  }

  @visibleForTesting
  SmartVaxController.fixture({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      authRepository = null,
      accountRepository = null {
    _seed();
  }

  final DateTime Function() _clock;
  DateTime get now => _clock();
  DateTime get seededAt => _seededAt;
  late DateTime _seededAt;
  List<Guardian> guardians = [];
  List<ChildProfile> children = [];
  List<VaccineCatalogEntry> vaccines = [];
  List<VaccinationRecord> records = [];
  List<DoctorProfile> doctors = [];
  List<HospitalProfile> hospitals = [];
  List<Appointment> appointments = [];
  List<Reminder> reminders = [];
  final Map<String, Set<String>> visitChecklists = {};
  List<NotificationItem> notifications = [];
  List<HealthTip> tips = [];
  AppSettings settings = const AppSettings();
  String activeGuardianId = 'g_mother';
  String selectedChildId = 'child_aarav';
  bool isLoggedIn = false;
  String sessionMobile = '';
  int _sequence = 0;

  void _seed() {
    _seededAt = now;
    guardians = SampleData.guardians();
    children = SampleData.children(_seededAt);
    vaccines = SampleData.vaccines();
    doctors = SampleData.doctors();
    hospitals = SampleData.hospitals();
    records = SampleData.records(_seededAt, children);
    appointments = SampleData.appointments(_seededAt);
    notifications = SampleData.notifications(_seededAt);
    tips = SampleData.tips();
    reminders = [
      for (final record in records.where(
        (r) => r.status == RecordStatus.planned,
      ))
        for (final days in const [7, 3, 1, 0])
          Reminder(
            id: 'rem_${record.id}_$days',
            childId: record.childId,
            recordId: record.id,
            daysBefore: days,
            enabled: true,
          ),
    ];
    visitChecklists.clear();
    settings = const AppSettings();
    activeGuardianId = 'g_mother';
    selectedChildId = 'child_aarav';
    isLoggedIn = false;
    sessionMobile = '';
    _sequence = 0;
  }

  Guardian? get activeGuardian => activeGuardianId == 'g_preview'
      ? Guardian(
          id: 'g_preview',
          name: 'Preview Parent',
          relation: 'Parent',
          mobile: sessionMobile,
          avatar: '🙂',
        )
      : guardianById(activeGuardianId);
  ChildProfile? get selectedChild => childById(selectedChildId);
  List<ChildProfile> get activeChildren => activeGuardianId == 'g_preview'
      ? List.unmodifiable(children)
      : children
            .where(
              (child) =>
                  child.motherId == activeGuardianId ||
                  child.fatherId == activeGuardianId,
            )
            .toList(growable: false);
  int get unreadCount => notifications.where((item) => !item.read).length;
  Guardian? guardianById(String? id) =>
      id == null ? null : _firstOrNull(guardians.where((g) => g.id == id));
  ChildProfile? childById(String? id) =>
      id == null ? null : _firstOrNull(children.where((c) => c.id == id));
  DoctorProfile? doctorById(String? id) =>
      id == null ? null : _firstOrNull(doctors.where((d) => d.id == id));
  HospitalProfile? hospitalById(String? id) =>
      id == null ? null : _firstOrNull(hospitals.where((h) => h.id == id));
  VaccineCatalogEntry? vaccineById(String? id) =>
      id == null ? null : _firstOrNull(vaccines.where((v) => v.id == id));
  VaccinationRecord? recordById(String? id) =>
      id == null ? null : _firstOrNull(records.where((r) => r.id == id));
  Appointment? appointmentById(String? id) =>
      id == null ? null : _firstOrNull(appointments.where((a) => a.id == id));

  List<VaccinationRecord> recordsFor(String childId) =>
      records.where((record) => record.childId == childId).toList()
        ..sort((a, b) {
          final aDate = a.administeredAt ?? a.plannedFor ?? DateTime(3000);
          final bDate = b.administeredAt ?? b.plannedFor ?? DateTime(3000);
          return bDate.compareTo(aDate);
        });

  List<VaccinationRecord> get selectedRecords =>
      selectedChild == null ? [] : recordsFor(selectedChildId);
  List<VaccinationRecord> get selectedCompleted =>
      selectedRecords.where((r) => r.status == RecordStatus.completed).toList();
  List<VaccinationRecord> get selectedPlanned =>
      selectedRecords.where((r) => r.status != RecordStatus.completed).toList();
  int get completedCount => selectedCompleted.map(_doseKey).toSet().length;
  int get trackedCount => selectedRecords.map(_doseKey).toSet().length;
  double get progress => trackedCount == 0 ? 0 : completedCount / trackedCount;
  List<Appointment> appointmentsFor(String childId) =>
      appointments
          .where(
            (a) =>
                a.childId == childId && a.status != AppointmentStatus.cancelled,
          )
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
  Appointment? nextAppointmentFor(String childId) {
    final today = DateTime(now.year, now.month, now.day);
    final future = appointmentsFor(childId).where(
      (a) =>
          a.status != AppointmentStatus.completed &&
          !DateTime(a.date.year, a.date.month, a.date.day).isBefore(today),
    );
    return future.isEmpty ? null : future.first;
  }

  String _doseKey(VaccinationRecord r) =>
      '${r.childId}|${r.vaccineId}|${r.dose}';
  String _id(String prefix) =>
      '${prefix}_${now.microsecondsSinceEpoch}_${_sequence++}';

  /// Model fixture login is unavailable in the Firebase application.
  @visibleForTesting
  bool signInFixture(String mobile) {
    if (accountRepository != null) return false;
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) return false;
    sessionMobile = mobile;
    activeGuardianId =
        guardians.where((g) => g.mobile == mobile).firstOrNull?.id ??
        'g_preview';
    isLoggedIn = true;
    notifyListeners();
    return true;
  }

  void logout() {
    _generation++;
    _dataSubscription?.cancel();
    _dataSubscription = null;
    _clearAccount();
    _emit();
    if (authRepository != null) {
      unawaited(
        authRepository!.signOut().catchError((Object e) {
          accountError = 'Unable to sign out. Try again.';
          _emit();
        }),
      );
    }
  }

  void switchParent() {
    activeGuardianId = activeGuardianId == 'g_mother' ? 'g_father' : 'g_mother';
    notifyListeners();
  }

  bool updateGuardian(
    String id, {
    required String name,
    required String mobile,
  }) {
    if (name.trim().isEmpty || !RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
      return false;
    }
    if (guardians.any((g) => g.id != id && g.mobile == mobile)) return false;
    guardians = guardians
        .map(
          (g) => g.id == id ? g.copyWith(name: name.trim(), mobile: mobile) : g,
        )
        .toList();
    if (id == 'g_father') {
      children = children
          .map((c) => c.copyWith(emergencyContact: '$name • $mobile'))
          .toList();
    }
    notifyListeners();
    return true;
  }

  void selectChild(String id) {
    if (childById(id) == null) return;
    selectedChildId = id;
    notifyListeners();
  }

  bool saveChild(ChildProfile child, {bool isNew = false}) {
    if (child.name.trim().isEmpty ||
        child.dob.isAfter(now) ||
        guardianById(child.motherId) == null ||
        guardianById(child.fatherId) == null) {
      return false;
    }
    if (isNew) {
      final normalized = ChildProfile(
        id: child.id.isEmpty ? _id('child') : child.id,
        name: child.name.trim(),
        dob: child.dob,
        gender: child.gender,
        bloodGroup: child.bloodGroup,
        cardId: child.cardId,
        avatar: child.avatar,
        motherId: child.motherId,
        fatherId: child.fatherId,
        address: child.address,
        emergencyContact: child.emergencyContact,
        notes: child.notes,
      );
      children = [...children, normalized];
      selectedChildId = normalized.id;
    } else {
      if (childById(child.id) == null) return false;
      final completedDates = records
          .where(
            (record) =>
                record.childId == child.id &&
                record.status == RecordStatus.completed &&
                record.administeredAt != null,
          )
          .map((record) => record.administeredAt!);
      if (completedDates.any(
        (date) => date.isBefore(child.dob) || date.isAfter(now),
      )) {
        return false;
      }
      children = children
          .map(
            (c) =>
                c.id == child.id ? child.copyWith(name: child.name.trim()) : c,
          )
          .toList();
    }
    notifyListeners();
    return true;
  }

  bool removeChild(String id) {
    if (childById(id) == null) return false;
    children = children.where((c) => c.id != id).toList();
    records = records.where((r) => r.childId != id).toList();
    appointments = appointments.where((a) => a.childId != id).toList();
    final remainingAppointmentIds = appointments.map((a) => a.id).toSet();
    visitChecklists.removeWhere(
      (appointmentId, _) => !remainingAppointmentIds.contains(appointmentId),
    );
    reminders = reminders.where((r) => r.childId != id).toList();
    notifications = notifications.where((n) => n.childId != id).toList();
    if (selectedChildId == id) selectedChildId = children.firstOrNull?.id ?? '';
    notifyListeners();
    return true;
  }

  bool saveRecord(VaccinationRecord record, {String? editingId}) {
    final child = childById(record.childId);
    if (child == null ||
        vaccineById(record.vaccineId) == null ||
        record.dose.trim().isEmpty) {
      return false;
    }
    if (record.status == RecordStatus.completed) {
      final date = record.administeredAt;
      if (date == null || date.isAfter(now) || date.isBefore(child.dob)) {
        return false;
      }
    }
    if (record.status != RecordStatus.completed &&
        record.administeredAt != null) {
      return false;
    }
    final toSave = VaccinationRecord(
      id: editingId ?? record.id,
      childId: record.childId,
      vaccineId: record.vaccineId,
      dose: record.dose,
      status: record.status,
      administeredAt: record.administeredAt,
      plannedFor: record.plannedFor,
      doctorId: doctorById(record.doctorId) == null ? null : record.doctorId,
      hospitalId: hospitalById(record.hospitalId) == null
          ? null
          : record.hospitalId,
      batchNumber: record.batchNumber.trim(),
      notes: record.notes.trim(),
      seeded: false,
    );
    if (toSave.status == RecordStatus.completed &&
        records.any(
          (existing) =>
              existing.id != editingId &&
              existing.id != toSave.id &&
              existing.childId == toSave.childId &&
              existing.vaccineId == toSave.vaccineId &&
              existing.dose == toSave.dose &&
              existing.status == RecordStatus.completed,
        )) {
      return false;
    }
    records = records.where((r) {
      if (r.id == editingId || r.id == record.id) return false;
      return !(toSave.status == RecordStatus.completed &&
          r.childId == toSave.childId &&
          r.vaccineId == toSave.vaccineId &&
          r.dose == toSave.dose &&
          r.status != RecordStatus.completed);
    }).toList();
    records = [...records, toSave];
    final remainingRecordIds = records.map((r) => r.id).toSet();
    reminders = reminders
        .where((r) => remainingRecordIds.contains(r.recordId))
        .toList();
    if (toSave.status == RecordStatus.planned) {
      reminders = reminders.where((r) => r.recordId != toSave.id).toList();
      for (final days in settings.reminderDays) {
        reminders.add(
          Reminder(
            id: _id('rem'),
            childId: toSave.childId,
            recordId: toSave.id,
            daysBefore: days,
            enabled: settings.remindersEnabled,
          ),
        );
      }
    } else {
      reminders = reminders.where((r) => r.recordId != toSave.id).toList();
    }
    notifications = [
      NotificationItem(
        id: _id('notice'),
        title: toSave.status == RecordStatus.completed
            ? 'Vaccination record updated'
            : 'Visit plan saved',
        message: 'A record for ${child.name} is waiting for synchronization.',
        createdAt: now,
        type: NoticeType.record,
        read: false,
        childId: child.id,
        referenceId: toSave.id,
      ),
      ...notifications,
    ];
    notifyListeners();
    return true;
  }

  bool deleteRecord(String id) {
    if (recordById(id) == null) return false;
    records = records.where((r) => r.id != id).toList();
    reminders = reminders.where((r) => r.recordId != id).toList();
    notifyListeners();
    return true;
  }

  bool saveAppointment(Appointment appointment, {String? editingId}) {
    final doctor = doctorById(appointment.doctorId);
    if (childById(appointment.childId) == null ||
        doctor == null ||
        hospitalById(appointment.hospitalId) == null ||
        doctor.hospitalId != appointment.hospitalId ||
        appointment.reason.trim().isEmpty) {
      return false;
    }
    final day = DateTime(
      appointment.date.year,
      appointment.date.month,
      appointment.date.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    if (appointment.status != AppointmentStatus.completed &&
        day.isBefore(today)) {
      return false;
    }
    final item = Appointment(
      id: editingId ?? appointment.id,
      childId: appointment.childId,
      doctorId: appointment.doctorId,
      hospitalId: appointment.hospitalId,
      reason: appointment.reason.trim(),
      date: day,
      time: appointment.time,
      status: editingId == null
          ? AppointmentStatus.requested
          : appointment.status,
      notes: appointment.notes.trim(),
    );
    appointments =
        appointments
            .where((a) => a.id != editingId && a.id != appointment.id)
            .toList()
          ..add(item);
    notifications = [
      NotificationItem(
        id: _id('notice'),
        title: 'Visit request updated',
        message:
            'Your request for ${childById(item.childId)?.name ?? 'your child'} has been updated. The center has not confirmed this request.',
        createdAt: now,
        type: NoticeType.appointment,
        read: false,
        childId: item.childId,
        referenceId: item.id,
      ),
      ...notifications,
    ];
    notifyListeners();
    return true;
  }

  void updateAppointmentStatus(String id, AppointmentStatus status) {
    appointments = appointments
        .map((a) => a.id == id ? a.copyWith(status: status) : a)
        .toList();
    notifyListeners();
  }

  void toggleReminder(String recordId, int days, bool enabled) {
    if (enabled && !settings.remindersEnabled) {
      settings = settings.copyWith(remindersEnabled: true);
    }
    final match = reminders
        .where((r) => r.recordId == recordId && r.daysBefore == days)
        .firstOrNull;
    if (match == null) {
      final record = recordById(recordId);
      if (record == null) return;
      reminders = [
        ...reminders,
        Reminder(
          id: _id('rem'),
          childId: record.childId,
          recordId: recordId,
          daysBefore: days,
          enabled: enabled,
        ),
      ];
    } else {
      reminders = reminders
          .map(
            (r) => r.id == match.id
                ? Reminder(
                    id: r.id,
                    childId: r.childId,
                    recordId: r.recordId,
                    daysBefore: days,
                    enabled: enabled,
                  )
                : r,
          )
          .toList();
    }
    notifyListeners();
  }

  void toggleAllReminders(bool enabled) {
    settings = settings.copyWith(remindersEnabled: enabled);
    reminders = reminders
        .map(
          (r) => Reminder(
            id: r.id,
            childId: r.childId,
            recordId: r.recordId,
            daysBefore: r.daysBefore,
            enabled: enabled,
          ),
        )
        .toList();
    notifyListeners();
  }

  void markRead(String id) {
    notifications = notifications
        .map((n) => n.id == id ? n.copyWith(read: true) : n)
        .toList();
    notifyListeners();
  }

  void markAllRead() {
    notifications = notifications.map((n) => n.copyWith(read: true)).toList();
    notifyListeners();
  }

  void removeNotification(String id) {
    notifications = notifications.where((n) => n.id != id).toList();
    notifyListeners();
  }

  static const visitChecklistItems = [
    'Take the vaccination card',
    'Confirm the center and doctor',
    'Confirm the visit date before travelling',
    'Ask the clinician about the next visit',
  ];

  bool isChecklistItemChecked(String appointmentId, String item) =>
      visitChecklists[appointmentId]?.contains(item) ?? false;

  void setChecklistItem(String appointmentId, String item, bool checked) {
    final current = {...?visitChecklists[appointmentId]};
    if (checked) {
      current.add(item);
    } else {
      current.remove(item);
    }
    visitChecklists[appointmentId] = current;
    notifyListeners();
  }

  void reset() {
    if (accountRepository != null) {
      accountError = "Cloud records cannot be reset to sample information.";
      _emit();
      return;
    }
    final wasLoggedIn = isLoggedIn;
    final previousGuardian = activeGuardianId;
    final previousMobile = sessionMobile;
    _seed();
    isLoggedIn = wasLoggedIn;
    activeGuardianId = previousGuardian;
    sessionMobile = previousMobile;
    notifyListeners();
  }

  final AuthRepository? authRepository;
  final AccountRepository? accountRepository;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<AccountSnapshot>? _dataSubscription;
  String? currentUid;
  String? accountError;
  bool accountLoading = false;
  String migrationStatus = 'not-started';
  bool fromCache = false;
  bool pendingWrites = false;
  int _generation = 0;
  int _pendingCount = 0;
  Future<void> _writeTail = Future<void>.value();
  bool _disposed = false;
  AccountDocuments _persisted = {};
  AccountSnapshot? _latestSnapshot;
  final List<({String uid, AccountDocuments before, AccountDocuments after})>
  _failedWrites = [];
  String get syncMessage =>
      accountError ??
      (accountLoading
          ? 'Loading account…'
          : pendingWrites
          ? 'Changes waiting for sync'
          : fromCache
          ? 'Offline — cached information'
          : 'Saved');

  void _emit() {
    if (!_disposed) super.notifyListeners();
  }

  void _clearAccount() {
    guardians = [];
    children = [];
    records = [];
    doctors = [];
    hospitals = [];
    appointments = [];
    reminders = [];
    notifications = [];
    tips = [];
    vaccines = SampleData.vaccines();
    visitChecklists.clear();
    settings = const AppSettings();
    selectedChildId = '';
    activeGuardianId = '';
    sessionMobile = '';
    currentUid = null;
    isLoggedIn = false;
    accountLoading = false;
    pendingWrites = false;
    fromCache = false;
    _pendingCount = 0;
    _writeTail = Future<void>.value();
    migrationStatus = 'not-started';
    _persisted = {};
    _latestSnapshot = null;
    _failedWrites.clear();
    accountError = null;
    _seededAt = DateTime(2026, 10, 11, 12);
  }

  Future<void> _onAuth(User? user) async {
    final generation = ++_generation;
    await _dataSubscription?.cancel();
    if (_disposed || generation != _generation) return;
    _dataSubscription = null;
    _clearAccount();
    if (user == null) {
      _emit();
      return;
    }
    currentUid = user.uid;
    sessionMobile = user.phoneNumber ?? '';
    accountLoading = true;
    _emit();
    try {
      migrationStatus = await SampleDataMigration(
        accountRepository!,
      ).prepare(user.uid, user.phoneNumber);
      if (_disposed || generation != _generation) return;
      _dataSubscription = accountRepository!
          .watch(user.uid)
          .listen(
            (snapshot) {
              if (_disposed || generation != _generation) return;
              _latestSnapshot = snapshot;
              fromCache = snapshot.fromCache;
              if (_pendingCount == 0 && _failedWrites.isEmpty) {
                try {
                  _loadDocuments(snapshot.documents);
                  accountError = null;
                } catch (e) {
                  accountError =
                      'Unable to read account data. Retry or contact support.';
                  accountLoading = false;
                  isLoggedIn = false;
                  _emit();
                  return;
                }
              }
              pendingWrites =
                  snapshot.pending ||
                  _pendingCount > 0 ||
                  _failedWrites.isNotEmpty;
              accountLoading = false;
              isLoggedIn = true;
              _emit();
            },
            onError: (Object e) {
              if (_disposed || generation != _generation) return;
              accountLoading = false;
              accountError =
                  'Unable to load account data. Check connection and permissions.';
              _emit();
            },
          );
    } catch (e) {
      if (_disposed || generation != _generation) return;
      accountLoading = false;
      accountError = e is MigrationConflict
          ? e.message
          : 'Unable to load account data. Check connection and permissions.';
      _emit();
    }
  }

  Future<void> retryAccount() async {
    if (_failedWrites.isNotEmpty) {
      if (_pendingCount > 0) return;
      final baseline = _failedWrites.first;
      final desired = exportDocuments();
      _failedWrites.clear();
      accountError = null;
      _queueWrite(baseline.uid, baseline.before, desired);
    } else if (authRepository?.auth.currentUser != null && !isLoggedIn) {
      await _onAuth(authRepository!.auth.currentUser);
    } else {
      accountError = null;
      _emit();
    }
  }

  @override
  void notifyListeners() {
    if (accountRepository != null && currentUid != null && isLoggedIn) {
      final after = exportDocuments();
      final before = _persisted;
      _persisted = after;
      if (!const DeepCollectionEqualityCompat().equals(before, after)) {
        _queueWrite(currentUid!, before, after);
      }
    }
    _emit();
  }

  void _queueWrite(
    String uid,
    AccountDocuments before,
    AccountDocuments after,
  ) {
    final generation = _generation;
    _pendingCount++;
    pendingWrites = true;
    unawaited(
      _writeTail = _writeTail
          .then((_) async {
            if (_disposed || generation != _generation) return;
            if (_failedWrites.isNotEmpty) {
              throw StateError('Earlier save requires retry');
            }
            await accountRepository!.applyChanges(uid, before, after);
          })
          .then(
            (_) {
              if (_disposed || generation != _generation) return;
              _pendingCount--;
              pendingWrites = _pendingCount > 0 || _failedWrites.isNotEmpty;
              if (_pendingCount == 0 &&
                  _failedWrites.isEmpty &&
                  _latestSnapshot != null) {
                try {
                  _loadDocuments(_latestSnapshot!.documents);
                } catch (e) {
                  accountError = 'Unable to read account data.';
                }
              }
              _emit();
            },
            onError: (Object e) {
              if (_disposed || generation != _generation) return;
              _pendingCount--;
              _failedWrites.add((uid: uid, before: before, after: after));
              pendingWrites = true;
              accountError = 'Unable to save changes. Retry synchronization.';
              _emit();
            },
          ),
    );
  }

  AccountDocuments exportDocuments() => {
    'guardians': {
      for (final item in guardians) item.id: ModelCodec.encodeGuardian(item),
    },
    'children': {
      for (final item in children) item.id: ModelCodec.encodeChildProfile(item),
    },
    'vaccinationRecords': {
      for (final item in records)
        item.id: ModelCodec.encodeVaccinationRecord(item),
    },
    'doctors': {
      for (final item in doctors) item.id: ModelCodec.encodeDoctorProfile(item),
    },
    'hospitals': {
      for (final item in hospitals)
        item.id: ModelCodec.encodeHospitalProfile(item),
    },
    'appointments': {
      for (final item in appointments)
        item.id: ModelCodec.encodeAppointment(item),
    },
    'reminders': {
      for (final item in reminders)
        item.id: ModelCodec.encodeReminder(
          item,
          targetDate: recordById(
            item.recordId,
          )?.plannedFor?.subtract(Duration(days: item.daysBefore)),
        ),
    },
    'notifications': {
      for (final item in notifications)
        item.id: ModelCodec.encodeNotificationItem(item),
    },
    'healthTips': {
      for (final item in tips) item.id: ModelCodec.encodeHealthTip(item),
    },
    'settings': {
      'main': {
        ...ModelCodec.encodeAppSettings(settings),
        'selectedChildId': selectedChildId,
        'activeGuardianId': activeGuardianId,
        'visitChecklists': {
          for (final item in visitChecklists.entries)
            item.key: item.value.toList()..sort(),
        },
      },
    },
  };

  void _loadDocuments(AccountDocuments data) {
    guardians = (data['guardians'] ?? {}).values
        .map(ModelCodec.decodeGuardian)
        .toList();
    children = (data['children'] ?? {}).values
        .map(ModelCodec.decodeChildProfile)
        .toList();
    records = (data['vaccinationRecords'] ?? {}).values
        .map(ModelCodec.decodeVaccinationRecord)
        .toList();
    doctors = (data['doctors'] ?? {}).values
        .map(ModelCodec.decodeDoctorProfile)
        .toList();
    hospitals = (data['hospitals'] ?? {}).values
        .map(ModelCodec.decodeHospitalProfile)
        .toList();
    appointments = (data['appointments'] ?? {}).values
        .map(ModelCodec.decodeAppointment)
        .toList();
    reminders = (data['reminders'] ?? {}).values
        .map(ModelCodec.decodeReminder)
        .toList();
    notifications = (data['notifications'] ?? {}).values
        .map(ModelCodec.decodeNotificationItem)
        .toList();
    tips = (data['healthTips'] ?? {}).values
        .map(ModelCodec.decodeHealthTip)
        .toList();
    final preferences = data['settings']?['main'] ?? {};
    settings = ModelCodec.decodeAppSettings(preferences);
    selectedChildId = preferences['selectedChildId'] as String? ?? '';
    if (childById(selectedChildId) == null) {
      selectedChildId = children.firstOrNull?.id ?? '';
    }
    activeGuardianId = preferences['activeGuardianId'] as String? ?? '';
    if (guardianById(activeGuardianId) == null) {
      activeGuardianId = guardians.firstOrNull?.id ?? '';
    }
    visitChecklists.clear();
    final checklists = preferences['visitChecklists'];
    if (checklists is Map) {
      for (final item in checklists.entries) {
        if (item.key is String && item.value is List) {
          visitChecklists[item.key as String] = (item.value as List)
              .whereType<String>()
              .toSet();
        }
      }
    }
    _persisted = exportDocuments();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _authSubscription?.cancel();
    _dataSubscription?.cancel();
    super.dispose();
  }
}

T? _firstOrNull<T>(Iterable<T> items) {
  final iterator = items.iterator;
  return iterator.moveNext() ? iterator.current : null;
}
