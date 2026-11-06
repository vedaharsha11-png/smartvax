import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'models.dart';

DateTime dateValue(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw const FormatException('Invalid date');
}

T enumValue<T extends Enum>(List<T> values, dynamic value, {T? fallback}) =>
    values.firstWhere(
      (e) => e.name == value,
      orElse: () => fallback ?? values.first,
    );

class ModelCodec {
  static Map<String, dynamic> encodeGuardian(Guardian value) => {
    'id': value.id,
    'name': value.name,
    'relation': value.relation,
    'mobile': value.mobile,
    'avatar': value.avatar,
  };
  static Guardian decodeGuardian(Map<String, dynamic> data) => Guardian(
    id: data['id'] is String ? data['id'] as String : '',
    name: data['name'] is String ? data['name'] as String : '',
    relation: data['relation'] is String ? data['relation'] as String : '',
    mobile: data['mobile'] is String ? data['mobile'] as String : '',
    avatar: data['avatar'] is String ? data['avatar'] as String : '',
  );
  static Map<String, dynamic> encodeChildProfile(ChildProfile value) => {
    'id': value.id,
    'name': value.name,
    'dob': Timestamp.fromDate(value.dob),
    'gender': value.gender.name,
    'bloodGroup': value.bloodGroup,
    'cardId': value.cardId,
    'avatar': value.avatar,
    'motherId': value.motherId,
    'fatherId': value.fatherId,
    'address': value.address,
    'emergencyContact': value.emergencyContact,
    'notes': value.notes,
  };
  static ChildProfile decodeChildProfile(Map<String, dynamic> data) =>
      ChildProfile(
        id: data['id'] is String ? data['id'] as String : '',
        name: data['name'] is String ? data['name'] as String : '',
        dob: dateValue(data['dob']),
        gender: enumValue(
          ChildGender.values,
          data['gender'],
          fallback: ChildGender.other,
        ),
        bloodGroup: data['bloodGroup'] is String
            ? data['bloodGroup'] as String
            : '',
        cardId: data['cardId'] is String ? data['cardId'] as String : '',
        avatar: data['avatar'] is String ? data['avatar'] as String : '',
        motherId: data['motherId'] is String ? data['motherId'] as String : '',
        fatherId: data['fatherId'] is String ? data['fatherId'] as String : '',
        address: data['address'] is String ? data['address'] as String : '',
        emergencyContact: data['emergencyContact'] is String
            ? data['emergencyContact'] as String
            : '',
        notes: data['notes'] is String ? data['notes'] as String : '',
      );
  static Map<String, dynamic> encodeVaccinationRecord(
    VaccinationRecord value,
  ) => {
    'id': value.id,
    'childId': value.childId,
    'vaccineId': value.vaccineId,
    'dose': value.dose,
    'status': value.status.name,
    'administeredAt': value.administeredAt == null
        ? null
        : Timestamp.fromDate(value.administeredAt!),
    'plannedFor': value.plannedFor == null
        ? null
        : Timestamp.fromDate(value.plannedFor!),
    'doctorId': value.doctorId,
    'hospitalId': value.hospitalId,
    'batchNumber': value.batchNumber,
    'notes': value.notes,
    'seeded': value.seeded,
  };
  static VaccinationRecord decodeVaccinationRecord(
    Map<String, dynamic> data,
  ) => VaccinationRecord(
    id: data['id'] is String ? data['id'] as String : '',
    childId: data['childId'] is String ? data['childId'] as String : '',
    vaccineId: data['vaccineId'] is String ? data['vaccineId'] as String : '',
    dose: data['dose'] is String ? data['dose'] as String : '',
    status: data['status'] == 'completed' && data['administeredAt'] == null
        ? throw const FormatException('Completed record is missing its date')
        : enumValue(
            RecordStatus.values,
            data['status'],
            fallback: RecordStatus.pending,
          ),
    administeredAt: data['administeredAt'] == null
        ? null
        : dateValue(data['administeredAt']),
    plannedFor: data['plannedFor'] == null
        ? null
        : dateValue(data['plannedFor']),
    doctorId: data['doctorId'] is String ? data['doctorId'] as String : null,
    hospitalId: data['hospitalId'] is String
        ? data['hospitalId'] as String
        : null,
    batchNumber: data['batchNumber'] is String
        ? data['batchNumber'] as String
        : '',
    notes: data['notes'] is String ? data['notes'] as String : '',
    seeded: data['seeded'] is bool ? data['seeded'] as bool : false,
  );
  static Map<String, dynamic> encodeDoctorProfile(DoctorProfile value) => {
    'id': value.id,
    'name': value.name,
    'specialty': value.specialty,
    'qualification': value.qualification,
    'experience': value.experience,
    'hospitalId': value.hospitalId,
    'area': value.area,
    'avatar': value.avatar,
    'bio': value.bio,
  };
  static DoctorProfile decodeDoctorProfile(Map<String, dynamic> data) =>
      DoctorProfile(
        id: data['id'] is String ? data['id'] as String : '',
        name: data['name'] is String ? data['name'] as String : '',
        specialty: data['specialty'] is String
            ? data['specialty'] as String
            : '',
        qualification: data['qualification'] is String
            ? data['qualification'] as String
            : '',
        experience: (data['experience'] as num?)?.toInt() ?? 0,
        hospitalId: data['hospitalId'] is String
            ? data['hospitalId'] as String
            : '',
        area: data['area'] is String ? data['area'] as String : '',
        avatar: data['avatar'] is String ? data['avatar'] as String : '',
        bio: data['bio'] is String ? data['bio'] as String : '',
      );
  static Map<String, dynamic> encodeHospitalProfile(HospitalProfile value) => {
    'id': value.id,
    'name': value.name,
    'area': value.area,
    'city': value.city,
    'state': value.state,
    'address': value.address,
    'phone': value.phone,
    'hours': value.hours,
    'services': value.services,
    'doctorIds': value.doctorIds,
    'illustration': value.illustration,
  };
  static HospitalProfile decodeHospitalProfile(Map<String, dynamic> data) =>
      HospitalProfile(
        id: data['id'] is String ? data['id'] as String : '',
        name: data['name'] is String ? data['name'] as String : '',
        area: data['area'] is String ? data['area'] as String : '',
        city: data['city'] is String ? data['city'] as String : '',
        state: data['state'] is String ? data['state'] as String : '',
        address: data['address'] is String ? data['address'] as String : '',
        phone: data['phone'] is String ? data['phone'] as String : '',
        hours: data['hours'] is String ? data['hours'] as String : '',
        services:
            (data['services'] as List?)?.whereType<String>().toList() ??
            <String>[],
        doctorIds:
            (data['doctorIds'] as List?)?.whereType<String>().toList() ??
            <String>[],
        illustration: data['illustration'] is String
            ? data['illustration'] as String
            : '',
      );
  static Map<String, dynamic> encodeAppointment(Appointment value) => {
    'id': value.id,
    'childId': value.childId,
    'doctorId': value.doctorId,
    'hospitalId': value.hospitalId,
    'reason': value.reason,
    'date': Timestamp.fromDate(value.date),
    'time': {'hour': value.time.hour, 'minute': value.time.minute},
    'status': value.status.name,
    'notes': value.notes,
  };
  static Appointment decodeAppointment(Map<String, dynamic> data) =>
      Appointment(
        id: data['id'] is String ? data['id'] as String : '',
        childId: data['childId'] is String ? data['childId'] as String : '',
        doctorId: data['doctorId'] is String ? data['doctorId'] as String : '',
        hospitalId: data['hospitalId'] is String
            ? data['hospitalId'] as String
            : '',
        reason: data['reason'] is String ? data['reason'] as String : '',
        date: dateValue(data['date']),
        time: TimeOfDay(
          hour: (data['time']?['hour'] as num?)?.toInt() ?? 0,
          minute: (data['time']?['minute'] as num?)?.toInt() ?? 0,
        ),
        status: enumValue(AppointmentStatus.values, data['status']),
        notes: data['notes'] is String ? data['notes'] as String : '',
      );
  static Map<String, dynamic> encodeReminder(
    Reminder value, {
    DateTime? targetDate,
  }) => {
    'id': value.id,
    'childId': value.childId,
    'recordId': value.recordId,
    'targetDate': targetDate == null ? null : Timestamp.fromDate(targetDate),
    'daysBefore': value.daysBefore,
    'enabled': value.enabled,
  };
  static Reminder decodeReminder(Map<String, dynamic> data) => Reminder(
    id: data['id'] is String ? data['id'] as String : '',
    childId: data['childId'] is String ? data['childId'] as String : '',
    recordId: data['recordId'] is String ? data['recordId'] as String : '',
    daysBefore: (data['daysBefore'] as num?)?.toInt() ?? 0,
    enabled: data['enabled'] is bool ? data['enabled'] as bool : true,
  );
  static Map<String, dynamic> encodeNotificationItem(NotificationItem value) =>
      {
        'id': value.id,
        'title': value.title,
        'message': value.message,
        'createdAt': Timestamp.fromDate(value.createdAt),
        'type': value.type.name,
        'read': value.read,
        'childId': value.childId,
        'referenceId': value.referenceId,
      };
  static NotificationItem decodeNotificationItem(Map<String, dynamic> data) =>
      NotificationItem(
        id: data['id'] is String ? data['id'] as String : '',
        title: data['title'] is String ? data['title'] as String : '',
        message: data['message'] is String ? data['message'] as String : '',
        createdAt: dateValue(data['createdAt']),
        type: enumValue(NoticeType.values, data['type']),
        read: data['read'] is bool ? data['read'] as bool : false,
        childId: data['childId'] is String ? data['childId'] as String : null,
        referenceId: data['referenceId'] is String
            ? data['referenceId'] as String
            : null,
      );
  static Map<String, dynamic> encodeHealthTip(HealthTip value) => {
    'id': value.id,
    'title': value.title,
    'body': value.body,
  };
  static HealthTip decodeHealthTip(Map<String, dynamic> data) => HealthTip(
    id: data['id'] is String ? data['id'] as String : '',
    title: data['title'] is String ? data['title'] as String : '',
    body: data['body'] is String ? data['body'] as String : '',
  );
  static Map<String, dynamic> encodeAppSettings(AppSettings value) => {
    'remindersEnabled': value.remindersEnabled,
    'reminderDays': value.reminderDays,
  };
  static AppSettings decodeAppSettings(Map<String, dynamic> data) =>
      AppSettings(
        remindersEnabled: data['remindersEnabled'] is bool
            ? data['remindersEnabled'] as bool
            : true,
        reminderDays:
            (data['reminderDays'] as List?)?.whereType<int>().toList() ??
            <int>[],
      );
}
