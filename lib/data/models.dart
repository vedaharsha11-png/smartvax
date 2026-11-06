import 'package:flutter/material.dart';

enum ChildGender { male, female, other }

enum RecordStatus { completed, pending, planned }

enum AppointmentStatus { requested, scheduled, completed, cancelled }

enum NoticeType { vaccine, appointment, record, tip, general }

class Guardian {
  const Guardian({
    required this.id,
    required this.name,
    required this.relation,
    required this.mobile,
    required this.avatar,
  });

  final String id;
  final String name;
  final String relation;
  final String mobile;
  final String avatar;

  Guardian copyWith({String? name, String? mobile}) => Guardian(
    id: id,
    name: name ?? this.name,
    relation: relation,
    mobile: mobile ?? this.mobile,
    avatar: avatar,
  );
}

class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.name,
    required this.dob,
    required this.gender,
    required this.bloodGroup,
    required this.cardId,
    required this.avatar,
    required this.motherId,
    required this.fatherId,
    required this.address,
    required this.emergencyContact,
    required this.notes,
  });

  final String id;
  final String name;
  final DateTime dob;
  final ChildGender gender;
  final String bloodGroup;
  final String cardId;
  final String avatar;
  final String motherId;
  final String fatherId;
  final String address;
  final String emergencyContact;
  final String notes;

  ChildProfile copyWith({
    String? name,
    DateTime? dob,
    ChildGender? gender,
    String? bloodGroup,
    String? notes,
    String? avatar,
    String? address,
    String? emergencyContact,
  }) => ChildProfile(
    id: id,
    name: name ?? this.name,
    dob: dob ?? this.dob,
    gender: gender ?? this.gender,
    bloodGroup: bloodGroup ?? this.bloodGroup,
    cardId: cardId,
    avatar: avatar ?? this.avatar,
    motherId: motherId,
    fatherId: fatherId,
    address: address ?? this.address,
    emergencyContact: emergencyContact ?? this.emergencyContact,
    notes: notes ?? this.notes,
  );
}

class VaccineCatalogEntry {
  const VaccineCatalogEntry({
    required this.id,
    required this.name,
    required this.expandedName,
    required this.description,
    required this.doses,
    required this.reference,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final String expandedName;
  final String description;
  final List<String> doses;
  final String reference;
  final IconData icon;
  final Color color;
}

class VaccinationRecord {
  const VaccinationRecord({
    required this.id,
    required this.childId,
    required this.vaccineId,
    required this.dose,
    required this.status,
    required this.doctorId,
    required this.hospitalId,
    this.administeredAt,
    this.plannedFor,
    this.batchNumber = '',
    this.notes = '',
    this.seeded = false,
  });

  final String id;
  final String childId;
  final String vaccineId;
  final String dose;
  final RecordStatus status;
  final DateTime? administeredAt;
  final DateTime? plannedFor;
  final String? doctorId;
  final String? hospitalId;
  final String batchNumber;
  final String notes;
  final bool seeded;

  VaccinationRecord copyWith({
    String? childId,
    String? vaccineId,
    String? dose,
    RecordStatus? status,
    DateTime? administeredAt,
    DateTime? plannedFor,
    String? doctorId,
    String? hospitalId,
    String? batchNumber,
    String? notes,
    bool clearAdministeredAt = false,
    bool clearPlannedFor = false,
  }) => VaccinationRecord(
    id: id,
    childId: childId ?? this.childId,
    vaccineId: vaccineId ?? this.vaccineId,
    dose: dose ?? this.dose,
    status: status ?? this.status,
    administeredAt: clearAdministeredAt
        ? null
        : administeredAt ?? this.administeredAt,
    plannedFor: clearPlannedFor ? null : plannedFor ?? this.plannedFor,
    doctorId: doctorId ?? this.doctorId,
    hospitalId: hospitalId ?? this.hospitalId,
    batchNumber: batchNumber ?? this.batchNumber,
    notes: notes ?? this.notes,
    seeded: seeded,
  );
}

class DoctorProfile {
  const DoctorProfile({
    required this.id,
    required this.name,
    required this.specialty,
    required this.qualification,
    required this.experience,
    required this.hospitalId,
    required this.area,
    required this.avatar,
    required this.bio,
  });

  final String id;
  final String name;
  final String specialty;
  final String qualification;
  final int experience;
  final String hospitalId;
  final String area;
  final String avatar;
  final String bio;
}

class HospitalProfile {
  const HospitalProfile({
    required this.id,
    required this.name,
    required this.area,
    required this.city,
    required this.state,
    required this.address,
    required this.phone,
    required this.hours,
    required this.services,
    required this.doctorIds,
    required this.illustration,
  });

  final String id;
  final String name;
  final String area;
  final String city;
  final String state;
  final String address;
  final String phone;
  final String hours;
  final List<String> services;
  final List<String> doctorIds;
  final String illustration;
}

class Appointment {
  const Appointment({
    required this.id,
    required this.childId,
    required this.doctorId,
    required this.hospitalId,
    required this.reason,
    required this.date,
    required this.time,
    required this.status,
    this.notes = '',
  });

  final String id;
  final String childId;
  final String doctorId;
  final String hospitalId;
  final String reason;
  final DateTime date;
  final TimeOfDay time;
  final AppointmentStatus status;
  final String notes;

  Appointment copyWith({
    String? childId,
    String? doctorId,
    String? hospitalId,
    String? reason,
    DateTime? date,
    TimeOfDay? time,
    AppointmentStatus? status,
    String? notes,
  }) => Appointment(
    id: id,
    childId: childId ?? this.childId,
    doctorId: doctorId ?? this.doctorId,
    hospitalId: hospitalId ?? this.hospitalId,
    reason: reason ?? this.reason,
    date: date ?? this.date,
    time: time ?? this.time,
    status: status ?? this.status,
    notes: notes ?? this.notes,
  );
}

class Reminder {
  const Reminder({
    required this.id,
    required this.childId,
    required this.recordId,
    required this.daysBefore,
    required this.enabled,
  });

  final String id;
  final String childId;
  final String recordId;
  final int daysBefore;
  final bool enabled;
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.type,
    required this.read,
    this.childId,
    this.referenceId,
  });

  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final NoticeType type;
  final bool read;
  final String? childId;
  final String? referenceId;

  NotificationItem copyWith({bool? read}) => NotificationItem(
    id: id,
    title: title,
    message: message,
    createdAt: createdAt,
    type: type,
    read: read ?? this.read,
    childId: childId,
    referenceId: referenceId,
  );
}

class HealthTip {
  const HealthTip({required this.id, required this.title, required this.body});
  final String id;
  final String title;
  final String body;
}

class AppSettings {
  const AppSettings({
    this.remindersEnabled = true,
    this.reminderDays = const [7, 3, 1, 0],
  });
  final bool remindersEnabled;
  final List<int> reminderDays;

  AppSettings copyWith({bool? remindersEnabled, List<int>? reminderDays}) =>
      AppSettings(
        remindersEnabled: remindersEnabled ?? this.remindersEnabled,
        reminderDays: reminderDays ?? this.reminderDays,
      );
}

String ageLabel(DateTime dob, DateTime now) {
  var years = now.year - dob.year;
  var months = now.month - dob.month;
  if (now.day < dob.day) months--;
  if (months < 0) {
    years--;
    months += 12;
  }
  if (years < 0) return 'Age not available';
  if (years == 0 && months == 0) return 'Under 1 month';
  if (years == 0) return '$months ${months == 1 ? 'month' : 'months'}';
  if (months == 0) return '$years ${years == 1 ? 'year' : 'years'}';
  return '$years ${years == 1 ? 'year' : 'years'} $months ${months == 1 ? 'month' : 'months'}';
}

DateTime subtractMonths(DateTime from, int months) {
  final monthIndex = from.month - 1 - months;
  final year = from.year + (monthIndex / 12).floor();
  final month = monthIndex % 12 + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, from.day.clamp(1, lastDay));
}
