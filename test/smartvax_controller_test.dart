import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartvax/data/models.dart';
import 'package:smartvax/state/smartvax_controller.dart';

void main() {
  final fixedNow = DateTime(2026, 10, 11, 12);
  late SmartVaxController controller;

  setUp(() => controller = SmartVaxController.fixture(clock: () => fixedNow));
  tearDown(() => controller.dispose());

  test('local login validates number and selects the matching parent', () {
    expect(controller.signInFixture('123'), isFalse);
    expect(controller.signInFixture('9876543210'), isTrue);
    expect(controller.activeGuardian?.name, 'Priya Sharma');
    expect(controller.activeChildren, hasLength(3));

    expect(controller.signInFixture('9876543211'), isTrue);
    expect(controller.activeGuardian?.name, 'Rahul Sharma');
    expect(controller.activeChildren, hasLength(3));

    expect(controller.signInFixture('9123456789'), isTrue);
    expect(controller.activeGuardian?.name, 'Preview Parent');
    expect(controller.activeChildren, hasLength(3));
  });

  test('selected child and calculated age use shared state', () {
    expect(controller.selectedChild?.name, 'Aarav Sharma');
    expect(ageLabel(controller.children[0].dob, fixedNow), '1 year 8 months');
    controller.selectChild('child_diya');
    expect(controller.selectedChild?.name, 'Diya Sharma');
    expect(
      controller.selectedRecords.every((r) => r.childId == 'child_diya'),
      isTrue,
    );
  });

  test('child can be added and removed with linked data cleaned up', () {
    final child = ChildProfile(
      id: 'child_new',
      name: 'Mira Sharma',
      dob: subtractMonths(fixedNow, 4),
      gender: ChildGender.female,
      bloodGroup: '',
      cardId: 'SV-CH-1004',
      avatar: '👧🏻',
      motherId: 'g_mother',
      fatherId: 'g_father',
      address: 'Illustrative family address',
      emergencyContact: 'Rahul Sharma • 9876543211',
      notes: '',
    );
    expect(controller.saveChild(child, isNew: true), isTrue);
    expect(controller.children, hasLength(4));
    expect(controller.selectedChildId, 'child_new');
    expect(controller.removeChild('child_new'), isTrue);
    expect(controller.children, hasLength(3));
    expect(controller.selectedChildId, 'child_aarav');
    expect(controller.removeChild('child_diya'), isTrue);
    expect(controller.records.any((r) => r.childId == 'child_diya'), isFalse);
  });

  test('record completion updates progress and rejects future dates', () {
    final before = controller.completedCount;
    final planned = controller.records.firstWhere(
      (r) => r.childId == 'child_aarav' && r.vaccineId == 'dpt',
    );
    final completion = planned.copyWith(
      status: RecordStatus.completed,
      administeredAt: fixedNow,
      clearPlannedFor: true,
    );
    expect(controller.saveRecord(completion), isTrue);
    expect(controller.completedCount, before + 1);
    expect(controller.recordById(planned.id)?.status, RecordStatus.completed);

    final duplicate = VaccinationRecord(
      id: 'duplicate',
      childId: planned.childId,
      vaccineId: planned.vaccineId,
      dose: planned.dose,
      status: RecordStatus.completed,
      administeredAt: fixedNow,
      doctorId: planned.doctorId,
      hospitalId: planned.hospitalId,
    );
    expect(controller.saveRecord(duplicate), isFalse);

    final future = VaccinationRecord(
      id: 'future',
      childId: 'child_aarav',
      vaccineId: 'bcg',
      dose: 'Single dose',
      status: RecordStatus.completed,
      administeredAt: fixedNow.add(const Duration(days: 1)),
      doctorId: null,
      hospitalId: null,
    );
    expect(controller.saveRecord(future), isFalse);
  });

  test('appointment state does not complete a vaccine record', () {
    final before = controller
        .recordsFor('child_vihaan')
        .where((r) => r.status == RecordStatus.completed)
        .length;
    final appointment = Appointment(
      id: 'local_request',
      childId: 'child_vihaan',
      doctorId: 'doctor_kiran',
      hospitalId: 'hospital_river',
      reason: 'Follow-up',
      date: fixedNow.add(const Duration(days: 4)),
      time: const TimeOfDay(hour: 10, minute: 0),
      status: AppointmentStatus.requested,
    );
    expect(controller.saveAppointment(appointment), isTrue);
    controller.setChecklistItem(
      appointment.id,
      SmartVaxController.visitChecklistItems.first,
      true,
    );
    expect(
      controller.isChecklistItemChecked(
        appointment.id,
        SmartVaxController.visitChecklistItems.first,
      ),
      isTrue,
    );
    expect(
      controller.saveAppointment(
        appointment.copyWith(hospitalId: 'hospital_lotus'),
      ),
      isFalse,
    );
    controller.updateAppointmentStatus(
      'local_request',
      AppointmentStatus.completed,
    );
    final after = controller
        .recordsFor('child_vihaan')
        .where((r) => r.status == RecordStatus.completed)
        .length;
    expect(after, before);
    expect(
      controller.appointmentById('local_request')?.status,
      AppointmentStatus.completed,
    );
  });

  test('notification read state and reset preserve active preview session', () {
    controller.signInFixture('9876543210');
    final before = controller.unreadCount;
    controller.markRead(controller.notifications.firstWhere((n) => !n.read).id);
    expect(controller.unreadCount, before - 1);
    controller.reset();
    expect(controller.isLoggedIn, isTrue);
    expect(controller.activeGuardian?.name, 'Priya Sharma');
    expect(controller.children, hasLength(3));
    expect(controller.selectedChildId, 'child_aarav');
  });
}
