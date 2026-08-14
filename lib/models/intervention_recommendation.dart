import 'package:cloud_firestore/cloud_firestore.dart';

class InterventionRecommendation {
  final String recommendationId;
  final String studentId;
  final String studentName;
  final String schoolId;
  final String schoolName;
  final String classId;
  final String teacherName;
  final String pillarType; // 'scholarship', 'hostel', 'subject_coaching', 'extracurricular_talent'
  final String targetEntity; // e.g. 'Agaram Foundation', 'Govt BC Welfare Hostel', 'Remedial Math Coaching', 'SDAT Sports Quota'
  final String reasonNotes;
  final String status; // 'Pending Principal Review', 'Approved by Principal (Sent to Municipality)', 'Municipality Endorsed & Dispatched', 'Rejected'
  final String? principalNotes;
  final String? municipalityNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  InterventionRecommendation({
    required this.recommendationId,
    required this.studentId,
    required this.studentName,
    required this.schoolId,
    required this.schoolName,
    required this.classId,
    required this.teacherName,
    required this.pillarType,
    required this.targetEntity,
    required this.reasonNotes,
    required this.status,
    this.principalNotes,
    this.municipalityNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'recommendationId': recommendationId,
      'id': recommendationId,
      'studentId': studentId,
      'studentName': studentName,
      'name': studentName,
      'schoolId': schoolId,
      'schoolName': schoolName,
      'classId': classId,
      'class': classId,
      'teacherName': teacherName,
      'pillarType': pillarType,
      'targetEntity': targetEntity,
      'reasonNotes': reasonNotes,
      'status': status,
      'principalNotes': principalNotes,
      'municipalityNotes': municipalityNotes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory InterventionRecommendation.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val != null) return DateTime.tryParse(val.toString()) ?? DateTime.now();
      return DateTime.now();
    }

    return InterventionRecommendation(
      recommendationId: docId,
      studentId: map['studentId']?.toString() ?? '',
      studentName: map['studentName']?.toString() ?? map['name']?.toString() ?? '',
      schoolId: map['schoolId']?.toString() ?? '',
      schoolName: map['schoolName']?.toString() ?? '',
      classId: map['classId']?.toString() ?? map['class']?.toString() ?? '',
      teacherName: map['teacherName']?.toString() ?? 'Class Teacher',
      pillarType: map['pillarType']?.toString() ?? 'scholarship',
      targetEntity: map['targetEntity']?.toString() ?? 'Agaram Foundation',
      reasonNotes: map['reasonNotes']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Pending Principal Review',
      principalNotes: map['principalNotes']?.toString(),
      municipalityNotes: map['municipalityNotes']?.toString(),
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }
}
