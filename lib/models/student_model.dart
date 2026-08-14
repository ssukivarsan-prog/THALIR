import 'activity_model.dart';
import 'meeting_brief_model.dart';

class SubjectMark {
  final String subject;
  final String assessmentName; // e.g. "Unit Test 1", "Quarterly Exam"
  final double marks;
  final double maxMarks;
  final DateTime date;

  SubjectMark({
    required this.subject,
    required this.assessmentName,
    required this.marks,
    required this.maxMarks,
    required this.date,
  });

  double get percentage => maxMarks > 0 ? (marks / maxMarks) * 100 : 0;

  Map<String, dynamic> toJson() => {
    'subject': subject,
    'assessmentName': assessmentName,
    'marks': marks,
    'maxMarks': maxMarks,
    'date': date.millisecondsSinceEpoch,
  };

  factory SubjectMark.fromJson(Map<String, dynamic> json) => SubjectMark(
    subject: json['subject'] ?? 'Mathematics',
    assessmentName: json['assessmentName'] ?? 'Class Test',
    marks: (json['marks'] as num?)?.toDouble() ?? 0.0,
    maxMarks: (json['maxMarks'] as num?)?.toDouble() ?? 100.0,
    date: DateTime.fromMillisecondsSinceEpoch(json['date'] ?? DateTime.now().millisecondsSinceEpoch),
  );
}

class TimelineEvent {
  final String id;
  final String title;
  final String description;
  final String category; // 'academic', 'attendance', 'intervention', 'observation'
  final DateTime date;
  final String? badgeIcon;

  TimelineEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    this.badgeIcon,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'date': date.millisecondsSinceEpoch,
    'badgeIcon': badgeIcon,
  };

  factory TimelineEvent.fromJson(Map<String, dynamic> json) => TimelineEvent(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    category: json['category'] ?? 'observation',
    date: DateTime.fromMillisecondsSinceEpoch(json['date'] ?? DateTime.now().millisecondsSinceEpoch),
    badgeIcon: json['badgeIcon'],
  );
}

class TeacherObservation {
  final String id;
  final String category; // 'Academic Struggle', 'Absenteeism Warning', 'Anxiety Trigger', 'Support Action'
  final String text;
  final DateTime date;
  final bool isVoiceDerived;
  final String? audioUrl;

  TeacherObservation({
    required this.id,
    required this.category,
    required this.text,
    required this.date,
    this.isVoiceDerived = false,
    this.audioUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'text': text,
    'date': date.millisecondsSinceEpoch,
    'isVoiceDerived': isVoiceDerived,
    'audioUrl': audioUrl,
  };

  factory TeacherObservation.fromJson(Map<String, dynamic> json) => TeacherObservation(
    id: json['id'] ?? '',
    category: json['category'] ?? 'Anxiety Trigger',
    text: json['text'] ?? '',
    date: DateTime.fromMillisecondsSinceEpoch(json['date'] ?? DateTime.now().millisecondsSinceEpoch),
    isVoiceDerived: json['isVoiceDerived'] ?? false,
    audioUrl: json['audioUrl'],
  );
}

class DropoutRiskProfile {
  final double riskScore; // Calculated 0 to 100%
  final String riskLevel; // 'Low', 'Medium', 'High'
  final List<String> primaryRiskFactors; // e.g. ['High Mathematics Anxiety', 'Chronic Absenteeism']
  final List<String> skippingAnxietySubjects; // e.g. ['Mathematics']
  final List<String> warningHistory; // Historical warning milestones

  DropoutRiskProfile({
    required this.riskScore,
    required this.riskLevel,
    required this.primaryRiskFactors,
    required this.skippingAnxietySubjects,
    required this.warningHistory,
  });

  Map<String, dynamic> toJson() => {
    'riskScore': riskScore,
    'riskLevel': riskLevel,
    'primaryRiskFactors': primaryRiskFactors,
    'skippingAnxietySubjects': skippingAnxietySubjects,
    'warningHistory': warningHistory,
  };

  factory DropoutRiskProfile.fromJson(Map<String, dynamic> json) => DropoutRiskProfile(
    riskScore: (json['riskScore'] as num?)?.toDouble() ?? 0.0,
    riskLevel: json['riskLevel'] ?? 'Low',
    primaryRiskFactors: List<String>.from(json['primaryRiskFactors'] ?? []),
    skippingAnxietySubjects: List<String>.from(json['skippingAnxietySubjects'] ?? []),
    warningHistory: List<String>.from(json['warningHistory'] ?? []),
  );
}

class Student {
  final String id; // Matches studentId
  final String schoolId; // Target school (e.g. "school-greenwood-01")
  final String classId; // Matches standard (e.g. "Grade 10-A", "VIII-A")
  final String name; // Student's full name
  final String rollNumber; // Roll number (e.g. "1001")
  final String gender; // "Male", "Female", or "Other"
  final String fatherName;
  final String motherName;
  final String guardianContact; // Phone number
  
  final double attendancePercentage;
  final double academicAverage;
  final String attendanceTrend; // 'improving', 'declining', 'stable'
  final String academicTrend;   // 'improving', 'declining', 'stable'
  final List<String> weakSubjects;
  final List<String> skippingAnxietySubjects; // Subjects causing skipping anxiety
  final List<SubjectMark> recentMarks;
  final DropoutRiskProfile dropoutRiskProfile;
  final Map<String, double> positiveDimensions; // Academic Growth, Attendance Cohesion, Engagement, Peer Support
  final List<TimelineEvent> timeline;
  final List<String> schoolSkippingReasons; // E.g., ['Difficult math homework', 'Test anxiety']
  final List<InterventionRecord> interventions;
  final List<TeacherObservation> observations;
  final List<MeetingRecord> previousMeetings;

  String get className => classId; // Getter to avoid breaking view files

  Student({
    required this.id,
    required this.schoolId,
    required this.classId,
    required this.name,
    required this.rollNumber,
    required this.gender,
    required this.guardianContact,
    required this.attendancePercentage,
    required this.academicAverage,
    required this.attendanceTrend,
    required this.academicTrend,
    required this.weakSubjects,
    required this.skippingAnxietySubjects,
    required this.recentMarks,
    required this.dropoutRiskProfile,
    required this.positiveDimensions,
    required this.timeline,
    required this.schoolSkippingReasons,
    required this.interventions,
    required this.observations,
    required this.previousMeetings,
    this.fatherName = '',
    this.motherName = '',
  });

  // Dynamic Dropout Risk Score (0 - 100%)
  double get calculatedDropoutRiskScore {
    double score = 0.0;
    
    // 1. Attendance Risk Factor (Max 50 points)
    if (attendancePercentage < 70) {
      score += 50;
    } else if (attendancePercentage < 80) {
      score += 35;
    } else if (attendancePercentage < 90) {
      score += 15;
    }

    // 2. Academic Risk Factor (Max 30 points)
    if (academicAverage < 50) {
      score += 30;
    } else if (academicAverage < 65) {
      score += 20;
    } else if (academicAverage < 75) {
      score += 10;
    }

    // 3. Trend Penalties (Max 20 points)
    if (attendanceTrend == 'declining') score += 10;
    if (academicTrend == 'declining') score += 10;

    return score.clamp(0.0, 100.0);
  }

  String get calculatedDropoutRiskLevel {
    final score = calculatedDropoutRiskScore;
    if (score >= 60) return 'High';
    if (score >= 30) return 'Medium';
    return 'Low';
  }

  Student copyWith({
    double? attendancePercentage,
    double? academicAverage,
    String? attendanceTrend,
    String? academicTrend,
    List<String>? weakSubjects,
    List<String>? skippingAnxietySubjects,
    List<SubjectMark>? recentMarks,
    DropoutRiskProfile? dropoutRiskProfile,
    Map<String, double>? positiveDimensions,
    List<TimelineEvent>? timeline,
    List<String>? schoolSkippingReasons,
    List<InterventionRecord>? interventions,
    List<TeacherObservation>? observations,
    List<MeetingRecord>? previousMeetings,
    String? fatherName,
    String? motherName,
  }) {
    return Student(
      id: id,
      schoolId: schoolId,
      classId: classId,
      name: name,
      rollNumber: rollNumber,
      gender: gender,
      guardianContact: guardianContact,
      attendancePercentage: attendancePercentage ?? this.attendancePercentage,
      academicAverage: academicAverage ?? this.academicAverage,
      attendanceTrend: attendanceTrend ?? this.attendanceTrend,
      academicTrend: academicTrend ?? this.academicTrend,
      weakSubjects: weakSubjects ?? this.weakSubjects,
      skippingAnxietySubjects: skippingAnxietySubjects ?? this.skippingAnxietySubjects,
      recentMarks: recentMarks ?? this.recentMarks,
      dropoutRiskProfile: dropoutRiskProfile ?? this.dropoutRiskProfile,
      positiveDimensions: positiveDimensions ?? this.positiveDimensions,
      timeline: timeline ?? this.timeline,
      schoolSkippingReasons: schoolSkippingReasons ?? this.schoolSkippingReasons,
      interventions: interventions ?? this.interventions,
      observations: observations ?? this.observations,
      previousMeetings: previousMeetings ?? this.previousMeetings,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
    );
  }

  Map<String, dynamic> toJson() => {
    'studentId': id,
    'id': id,
    'schoolId': schoolId,
    'school': schoolId,
    'classId': classId,
    'class': classId,
    'grade': classId,
    'standard': classId,
    'name': name,
    'studentName': name,
    'fullName': name,
    'rollNumber': rollNumber,
    'rollNo': rollNumber,
    'roll_no': rollNumber,
    'gender': gender,
    'fatherName': fatherName,
    'father': fatherName,
    'father_name': fatherName,
    'motherName': motherName,
    'mother': motherName,
    'mother_name': motherName,
    'guardianContact': guardianContact,
    'phone': guardianContact,
    'parentContact': guardianContact,
    
    'attendancePercentage': attendancePercentage,
    'academicAverage': academicAverage,
    'attendanceTrend': attendanceTrend,
    'academicTrend': academicTrend,
    'weakSubjects': weakSubjects,
    'skippingAnxietySubjects': skippingAnxietySubjects,
    'recentMarks': recentMarks.map((m) => m.toJson()).toList(),
    'dropoutRiskProfile': dropoutRiskProfile.toJson(),
    'positiveDimensions': positiveDimensions,
    'timeline': timeline.map((t) => t.toJson()).toList(),
    'schoolSkippingReasons': schoolSkippingReasons,
    'interventions': interventions.map((i) => i.toJson()).toList(),
    'observations': observations.map((o) => o.toJson()).toList(),
    'previousMeetings': previousMeetings.map((m) => m.toJson()).toList(),
  };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['studentId'] ?? json['id'] ?? '',
    schoolId: json['schoolId'] ?? json['school'] ?? 'school-greenwood-01',
    classId: json['classId'] ?? json['class'] ?? json['className'] ?? json['grade'] ?? json['standard'] ?? 'VIII-A',
    name: json['name'] ?? json['studentName'] ?? json['fullName'] ?? '',
    rollNumber: json['rollNumber'] ?? json['rollNo'] ?? json['roll_no'] ?? '',
    gender: json['gender'] ?? 'Male',
    fatherName: json['fatherName'] ?? json['father'] ?? json['father_name'] ?? '',
    motherName: json['motherName'] ?? json['mother'] ?? json['mother_name'] ?? '',
    guardianContact: json['guardianContact'] ?? json['phone'] ?? json['parentContact'] ?? '+91 98765 43210',
    
    attendancePercentage: (json['attendancePercentage'] as num?)?.toDouble() ?? 80.0,
    academicAverage: (json['academicAverage'] as num?)?.toDouble() ?? 70.0,
    attendanceTrend: json['attendanceTrend'] ?? 'stable',
    academicTrend: json['academicTrend'] ?? 'stable',
    weakSubjects: List<String>.from(json['weakSubjects'] ?? []),
    skippingAnxietySubjects: List<String>.from(json['skippingAnxietySubjects'] ?? []),
    recentMarks: (json['recentMarks'] as List? ?? []).map((m) => SubjectMark.fromJson(Map<String, dynamic>.from(m))).toList(),
    dropoutRiskProfile: json['dropoutRiskProfile'] != null 
        ? DropoutRiskProfile.fromJson(Map<String, dynamic>.from(json['dropoutRiskProfile']))
        : DropoutRiskProfile(riskScore: 10.0, riskLevel: 'Low', primaryRiskFactors: [], skippingAnxietySubjects: [], warningHistory: []),
    positiveDimensions: Map<String, double>.from((json['positiveDimensions'] as Map? ?? {}).map((k, v) => MapEntry(k.toString(), (v as num).toDouble()))),
    timeline: (json['timeline'] as List? ?? []).map((t) => TimelineEvent.fromJson(Map<String, dynamic>.from(t))).toList(),
    schoolSkippingReasons: List<String>.from(json['schoolSkippingReasons'] ?? []),
    interventions: (json['interventions'] as List? ?? []).map((i) => InterventionRecord.fromJson(Map<String, dynamic>.from(i))).toList(),
    observations: (json['observations'] as List? ?? []).map((o) => TeacherObservation.fromJson(Map<String, dynamic>.from(o))).toList(),
    previousMeetings: (json['previousMeetings'] as List? ?? []).map((m) => MeetingRecord.fromJson(Map<String, dynamic>.from(m))).toList(),
  );
}
