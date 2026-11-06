import 'package:flutter/material.dart';

import 'models.dart';

class SampleData {
  SampleData._();

  static const address =
      'Flat 204, Lotus Residency, Benz Circle, Vijayawada, Andhra Pradesh 520010';

  static List<Guardian> guardians() => const [
    Guardian(
      id: 'g_mother',
      name: 'Priya Sharma',
      relation: 'Mother',
      mobile: '9876543210',
      avatar: '👩🏻',
    ),
    Guardian(
      id: 'g_father',
      name: 'Rahul Sharma',
      relation: 'Father',
      mobile: '9876543211',
      avatar: '👨🏽',
    ),
  ];

  static List<VaccineCatalogEntry> vaccines() => const [
    VaccineCatalogEntry(
      id: 'bcg',
      name: 'BCG',
      expandedName: 'Bacillus Calmette–Guérin',
      description:
          'A vaccine included in India’s Universal Immunization Programme.',
      doses: ['Single dose'],
      reference:
          'Reference: at birth. Confirm individual timing with a health worker.',
      icon: Icons.vaccines_rounded,
      color: Color(0xff4c8ef7),
    ),
    VaccineCatalogEntry(
      id: 'opv',
      name: 'Oral Polio Vaccine (OPV)',
      expandedName: 'Bivalent oral polio vaccine',
      description:
          'An oral vaccine included in the routine immunization programme.',
      doses: ['Birth dose', 'Dose 1', 'Dose 2', 'Dose 3', 'Booster'],
      reference:
          'Multiple doses are included in the official schedule. Confirm timing locally.',
      icon: Icons.water_drop_rounded,
      color: Color(0xffed63a5),
    ),
    VaccineCatalogEntry(
      id: 'hepb',
      name: 'Hepatitis B',
      expandedName: 'Hepatitis B vaccine',
      description: 'Helps protect against hepatitis B infection.',
      doses: ['Birth dose'],
      reference:
          'Reference: birth dose. Confirm individual timing with a health worker.',
      icon: Icons.shield_rounded,
      color: Color(0xff35b997),
    ),
    VaccineCatalogEntry(
      id: 'pentavalent',
      name: 'Pentavalent',
      expandedName:
          'Diphtheria, pertussis, tetanus, hepatitis B and Hib vaccine',
      description:
          'A combination vaccine listed in the Universal Immunization Programme.',
      doses: ['Dose 1', 'Dose 2', 'Dose 3'],
      reference:
          'The national schedule includes three primary doses. Confirm timing locally.',
      icon: Icons.medical_services_rounded,
      color: Color(0xff8e62ed),
    ),
    VaccineCatalogEntry(
      id: 'rotavirus',
      name: 'Rotavirus vaccine',
      expandedName: 'Rotavirus vaccine',
      description:
          'A vaccine included in India’s routine programme; availability and schedule can vary.',
      doses: ['Dose 1', 'Dose 2', 'Dose 3'],
      reference:
          'Availability and timing may vary by programme. Ask a health worker.',
      icon: Icons.child_care_rounded,
      color: Color(0xff31b7d9),
    ),
    VaccineCatalogEntry(
      id: 'pcv',
      name: 'Pneumococcal conjugate (PCV)',
      expandedName: 'Pneumococcal conjugate vaccine',
      description:
          'A vaccine included in the national programme in applicable settings.',
      doses: ['Dose 1', 'Dose 2', 'Booster'],
      reference:
          'Programme availability and timing vary. Confirm with a health worker.',
      icon: Icons.health_and_safety_rounded,
      color: Color(0xfff4a348),
    ),
    VaccineCatalogEntry(
      id: 'mr',
      name: 'Measles-Rubella (MR)',
      expandedName: 'Measles and rubella vaccine',
      description:
          'MR protects against measles and rubella; it is distinct from MMR.',
      doses: ['Dose 1', 'Dose 2'],
      reference:
          'The national schedule lists two MR doses. Confirm timing with a health worker.',
      icon: Icons.favorite_rounded,
      color: Color(0xffe85e9c),
    ),
    VaccineCatalogEntry(
      id: 'dpt',
      name: 'DPT booster',
      expandedName: 'Diphtheria, pertussis and tetanus booster',
      description: 'A booster listed in the national immunization schedule.',
      doses: ['Booster 1', 'Booster 2'],
      reference:
          'The national schedule includes booster doses. Confirm timing locally.',
      icon: Icons.vaccines_rounded,
      color: Color(0xffe89342),
    ),
  ];

  static List<DoctorProfile> doctors() => const [
    DoctorProfile(
      id: 'doctor_ananya',
      name: 'Dr. Ananya Rao',
      specialty: 'Pediatrician',
      qualification: 'MBBS, MD (Pediatrics)',
      experience: 8,
      hospitalId: 'hospital_sunrise',
      area: 'Benz Circle, Vijayawada',
      avatar: '👩🏻‍⚕️',
      bio:
          'Fictional sample profile focused on preventive child healthcare and immunization consultations.',
    ),
    DoctorProfile(
      id: 'doctor_kiran',
      name: 'Dr. Kiran Reddy',
      specialty: 'Pediatrician',
      qualification: 'MBBS, DCH',
      experience: 6,
      hospitalId: 'hospital_river',
      area: 'Patamata, Vijayawada',
      avatar: '👨🏽‍⚕️',
      bio:
          'Fictional sample profile for child wellness visits and family health discussions.',
    ),
    DoctorProfile(
      id: 'doctor_sneha',
      name: 'Dr. Sneha Iyer',
      specialty: 'Pediatrician',
      qualification: 'MBBS, MD (Pediatrics)',
      experience: 5,
      hospitalId: 'hospital_lotus',
      area: 'Governorpet, Vijayawada',
      avatar: '👩🏽‍⚕️',
      bio:
          'Fictional sample profile supporting child health follow-up and vaccination consultations.',
    ),
  ];

  static List<HospitalProfile> hospitals() => const [
    HospitalProfile(
      id: 'hospital_sunrise',
      name: 'Sunrise Children’s Clinic',
      area: 'Benz Circle',
      city: 'Vijayawada',
      state: 'Andhra Pradesh',
      address: 'Illustrative address near Benz Circle, Vijayawada',
      phone: '+91 80000 10001',
      hours: 'Example hours: Mon–Sat, 9:00 AM–5:00 PM',
      services: [
        'Pediatric consultation',
        'Vaccination consultation',
        'Child health follow-up',
      ],
      doctorIds: ['doctor_ananya'],
      illustration: '🏥',
    ),
    HospitalProfile(
      id: 'hospital_river',
      name: 'Riverbank Family Health Centre',
      area: 'Patamata',
      city: 'Vijayawada',
      state: 'Andhra Pradesh',
      address: 'Illustrative address in Patamata, Vijayawada',
      phone: '+91 80000 10002',
      hours: 'Example hours: Mon–Fri, 9:30 AM–4:30 PM',
      services: [
        'Family health consultation',
        'Pediatric follow-up',
        'Immunization discussion',
      ],
      doctorIds: ['doctor_kiran'],
      illustration: '🏨',
    ),
    HospitalProfile(
      id: 'hospital_lotus',
      name: 'Lotus Pediatric Care',
      area: 'Governorpet',
      city: 'Vijayawada',
      state: 'Andhra Pradesh',
      address: 'Illustrative address in Governorpet, Vijayawada',
      phone: '+91 80000 10003',
      hours: 'Example hours: Mon–Sat, 10:00 AM–6:00 PM',
      services: [
        'Pediatric consultation',
        'Growth follow-up',
        'Vaccination consultation',
      ],
      doctorIds: ['doctor_sneha'],
      illustration: '🏩',
    ),
  ];

  static List<HealthTip> tips() => const [
    HealthTip(
      id: 'tip_card',
      title: 'Keep the vaccination card handy',
      body:
          'Bring your child’s vaccination card to every health visit so entries can be checked and recorded.',
    ),
    HealthTip(
      id: 'tip_date',
      title: 'Confirm visit dates',
      body:
          'Confirm the date and availability with your health worker or care center before travelling.',
    ),
    HealthTip(
      id: 'tip_record',
      title: 'Record each dose',
      body:
          'After a visit, ask the care team to record the vaccine name, dose and date in the official card.',
    ),
    HealthTip(
      id: 'tip_questions',
      title: 'Ask about after-care',
      body:
          'Ask a qualified clinician what to expect after vaccination and which warning signs need attention.',
    ),
    HealthTip(
      id: 'tip_missed',
      title: 'Discuss missed visits',
      body:
          'If a visit was missed, ask a health worker to review the record and explain appropriate next steps.',
    ),
    HealthTip(
      id: 'tip_documents',
      title: 'Organize health documents',
      body:
          'Keep health cards and visit notes together in a place that is easy to find.',
    ),
    HealthTip(
      id: 'tip_food',
      title: 'Ask about age-appropriate food',
      body:
          'A clinician can offer guidance suited to your child’s age and health needs.',
    ),
    HealthTip(
      id: 'tip_help',
      title: 'Get help when concerned',
      body:
          'Contact a qualified healthcare professional if you have concerns about your child’s health.',
    ),
  ];

  static List<ChildProfile> children(DateTime now) => [
    ChildProfile(
      id: 'child_aarav',
      name: 'Aarav Sharma',
      dob: subtractMonths(now, 20),
      gender: ChildGender.male,
      bloodGroup: 'B+',
      cardId: 'SV-CH-1001',
      avatar: '👦🏻',
      motherId: 'g_mother',
      fatherId: 'g_father',
      address: address,
      emergencyContact: 'Rahul Sharma • 9876543211',
      notes: 'No allergies recorded in this illustrative profile.',
    ),
    ChildProfile(
      id: 'child_diya',
      name: 'Diya Sharma',
      dob: subtractMonths(now, 17),
      gender: ChildGender.female,
      bloodGroup: 'O+',
      cardId: 'SV-CH-1002',
      avatar: '👧🏻',
      motherId: 'g_mother',
      fatherId: 'g_father',
      address: address,
      emergencyContact: 'Rahul Sharma • 9876543211',
      notes: 'No medical conditions recorded in this illustrative profile.',
    ),
    ChildProfile(
      id: 'child_vihaan',
      name: 'Vihaan Sharma',
      dob: subtractMonths(now, 2),
      gender: ChildGender.male,
      bloodGroup: 'A+',
      cardId: 'SV-CH-1003',
      avatar: '👶🏽',
      motherId: 'g_mother',
      fatherId: 'g_father',
      address: address,
      emergencyContact: 'Rahul Sharma • 9876543211',
      notes: 'Routine follow-up information is illustrative.',
    ),
  ];

  static List<VaccinationRecord> records(
    DateTime now,
    List<ChildProfile> children,
  ) {
    final result = <VaccinationRecord>[];
    void add(
      ChildProfile child,
      String vaccineId,
      String dose,
      int monthsAfterBirth, {
      String doctor = 'doctor_ananya',
      String hospital = 'hospital_sunrise',
    }) {
      final date = DateTime(
        child.dob.year,
        child.dob.month + monthsAfterBirth,
        child.dob.day,
      );
      if (!date.isAfter(now)) {
        result.add(
          VaccinationRecord(
            id: 'seed_${child.id}_${vaccineId}_$dose',
            childId: child.id,
            vaccineId: vaccineId,
            dose: dose,
            status: RecordStatus.completed,
            administeredAt: date,
            doctorId: doctor,
            hospitalId: hospital,
            batchNumber:
                'SV-${child.cardId.substring(child.cardId.length - 4)}',
            notes: 'Illustrative sample record. Not independently verified.',
            seeded: true,
          ),
        );
      }
    }

    final aarav = children[0];
    add(aarav, 'bcg', 'Single dose', 0);
    add(aarav, 'opv', 'Birth dose', 0);
    add(aarav, 'hepb', 'Birth dose', 0);
    add(aarav, 'pentavalent', 'Dose 1', 2);
    add(aarav, 'opv', 'Dose 1', 2);
    add(aarav, 'rotavirus', 'Dose 1', 2);
    add(aarav, 'pentavalent', 'Dose 2', 3);
    add(aarav, 'opv', 'Dose 2', 3);
    add(aarav, 'rotavirus', 'Dose 2', 3);
    add(aarav, 'pentavalent', 'Dose 3', 4);
    add(aarav, 'opv', 'Dose 3', 4);
    add(aarav, 'rotavirus', 'Dose 3', 4);
    add(aarav, 'pcv', 'Dose 1', 2);
    add(aarav, 'pcv', 'Dose 2', 4);
    add(aarav, 'mr', 'Dose 1', 12);

    final diya = children[1];
    add(
      diya,
      'bcg',
      'Single dose',
      0,
      doctor: 'doctor_sneha',
      hospital: 'hospital_lotus',
    );
    add(
      diya,
      'hepb',
      'Birth dose',
      0,
      doctor: 'doctor_sneha',
      hospital: 'hospital_lotus',
    );
    add(
      diya,
      'opv',
      'Birth dose',
      0,
      doctor: 'doctor_sneha',
      hospital: 'hospital_lotus',
    );
    add(
      diya,
      'pentavalent',
      'Dose 1',
      2,
      doctor: 'doctor_sneha',
      hospital: 'hospital_lotus',
    );
    add(
      diya,
      'pentavalent',
      'Dose 2',
      3,
      doctor: 'doctor_sneha',
      hospital: 'hospital_lotus',
    );
    add(
      diya,
      'pentavalent',
      'Dose 3',
      4,
      doctor: 'doctor_sneha',
      hospital: 'hospital_lotus',
    );
    add(
      diya,
      'rotavirus',
      'Dose 1',
      2,
      doctor: 'doctor_sneha',
      hospital: 'hospital_lotus',
    );
    add(
      diya,
      'rotavirus',
      'Dose 2',
      3,
      doctor: 'doctor_sneha',
      hospital: 'hospital_lotus',
    );
    add(
      diya,
      'opv',
      'Dose 1',
      2,
      doctor: 'doctor_sneha',
      hospital: 'hospital_lotus',
    );

    final vihaan = children[2];
    add(
      vihaan,
      'bcg',
      'Single dose',
      0,
      doctor: 'doctor_kiran',
      hospital: 'hospital_river',
    );
    add(
      vihaan,
      'hepb',
      'Birth dose',
      0,
      doctor: 'doctor_kiran',
      hospital: 'hospital_river',
    );
    add(
      vihaan,
      'opv',
      'Birth dose',
      0,
      doctor: 'doctor_kiran',
      hospital: 'hospital_river',
    );

    // A planned item with a past local target date is deliberately worded as a
    // missed planned visit in the UI, never as a medically overdue dose.
    result.add(
      VaccinationRecord(
        id: 'seed_diya_mr_review',
        childId: diya.id,
        vaccineId: 'mr',
        dose: 'Dose 1',
        status: RecordStatus.planned,
        plannedFor: DateTime(now.year, now.month, now.day - 2),
        doctorId: null,
        hospitalId: null,
        notes: 'Illustrative plan date for review with a health worker.',
        seeded: true,
      ),
    );
    for (final tuple in [
      (aarav, 'dpt', 'Booster 1', 30),
      (diya, 'dpt', 'Booster 1', 22),
      (vihaan, 'pentavalent', 'Dose 1', 3),
      (vihaan, 'opv', 'Dose 1', 3),
    ]) {
      final child = tuple.$1;
      final planned = DateTime(
        now.year,
        now.month,
        now.day + (child.id == 'child_vihaan' ? 7 : 12),
      );
      result.add(
        VaccinationRecord(
          id: 'plan_${child.id}_${tuple.$2}_${tuple.$3.replaceAll(' ', '_')}',
          childId: child.id,
          vaccineId: tuple.$2,
          dose: tuple.$3,
          status: RecordStatus.planned,
          plannedFor: planned,
          doctorId: child.id == 'child_vihaan'
              ? 'doctor_kiran'
              : 'doctor_ananya',
          hospitalId: child.id == 'child_vihaan'
              ? 'hospital_river'
              : 'hospital_sunrise',
          notes: 'Illustrative visit date only. Confirm with a health worker.',
          seeded: true,
        ),
      );
    }
    return result;
  }

  static List<Appointment> appointments(DateTime now) => [
    Appointment(
      id: 'appt_aarav',
      childId: 'child_aarav',
      doctorId: 'doctor_ananya',
      hospitalId: 'hospital_sunrise',
      reason: 'Vaccination record review',
      date: now.add(const Duration(days: 10)),
      time: const TimeOfDay(hour: 10, minute: 30),
      status: AppointmentStatus.requested,
      notes: 'Illustrative local visit request.',
    ),
    Appointment(
      id: 'appt_diya',
      childId: 'child_diya',
      doctorId: 'doctor_sneha',
      hospitalId: 'hospital_lotus',
      reason: 'Child health follow-up',
      date: now.add(const Duration(days: 14)),
      time: const TimeOfDay(hour: 11, minute: 0),
      status: AppointmentStatus.scheduled,
      notes: 'Locally saved example; center confirmation is not available.',
    ),
    Appointment(
      id: 'appt_vihaan',
      childId: 'child_vihaan',
      doctorId: 'doctor_kiran',
      hospitalId: 'hospital_river',
      reason: 'Routine follow-up',
      date: now.add(const Duration(days: 7)),
      time: const TimeOfDay(hour: 9, minute: 45),
      status: AppointmentStatus.requested,
      notes: 'Illustrative local visit request.',
    ),
    Appointment(
      id: 'appt_past',
      childId: 'child_aarav',
      doctorId: 'doctor_ananya',
      hospitalId: 'hospital_sunrise',
      reason: 'Previous child health visit',
      date: now.subtract(const Duration(days: 30)),
      time: const TimeOfDay(hour: 10, minute: 0),
      status: AppointmentStatus.completed,
      notes: 'Illustrative sample appointment.',
    ),
  ];

  static List<NotificationItem> notifications(DateTime now) => [
    NotificationItem(
      id: 'notice_1',
      title: 'Upcoming visit request',
      message: 'Aarav has a locally saved visit request coming up.',
      createdAt: now.subtract(const Duration(hours: 2)),
      type: NoticeType.appointment,
      read: false,
      childId: 'child_aarav',
      referenceId: 'appt_aarav',
    ),
    NotificationItem(
      id: 'notice_2',
      title: 'Keep the card handy',
      message: 'Bring Diya’s vaccination card to the next health visit.',
      createdAt: now.subtract(const Duration(hours: 8)),
      type: NoticeType.tip,
      read: false,
      childId: 'child_diya',
    ),
    NotificationItem(
      id: 'notice_3',
      title: 'Visit date to review',
      message:
          'Vihaan has an illustrative visit date saved. Confirm timing with a health worker.',
      createdAt: now.subtract(const Duration(days: 1)),
      type: NoticeType.vaccine,
      read: false,
      childId: 'child_vihaan',
    ),
    NotificationItem(
      id: 'notice_4',
      title: 'Sample records are ready',
      message: 'Explore the family’s locally bundled sample information.',
      createdAt: now.subtract(const Duration(days: 1)),
      type: NoticeType.general,
      read: true,
    ),
    NotificationItem(
      id: 'notice_5',
      title: 'Visit request saved',
      message:
          'Diya’s illustrative visit request is available in this account.',
      createdAt: now.subtract(const Duration(days: 2)),
      type: NoticeType.appointment,
      read: false,
      childId: 'child_diya',
      referenceId: 'appt_diya',
    ),
    NotificationItem(
      id: 'notice_6',
      title: 'Health tip',
      message: 'Ask a clinician what to expect after a vaccination.',
      createdAt: now.subtract(const Duration(days: 2)),
      type: NoticeType.tip,
      read: true,
    ),
    NotificationItem(
      id: 'notice_7',
      title: 'Record added',
      message: 'An illustrative record is available in Aarav’s history.',
      createdAt: now.subtract(const Duration(days: 3)),
      type: NoticeType.record,
      read: false,
      childId: 'child_aarav',
    ),
    NotificationItem(
      id: 'notice_8',
      title: 'Confirm with your care team',
      message:
          'Sample dates are for interface exploration and may not fit your child.',
      createdAt: now.subtract(const Duration(days: 4)),
      type: NoticeType.general,
      read: true,
    ),
  ];
}
