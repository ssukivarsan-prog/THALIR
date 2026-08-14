class AcademicRecord {
  final String recordId;
  final String studentId;
  final String term; // e.g. "Term 1", "Term 2", "Midterm 2026"
  final String subject;
  final double marks; // 0 - 100
  final double gpa; // 0.0 - 4.0 or 0.0 - 10.0
  final int backlogs;
  final double assignmentCompletionRate; // 0.0 - 1.0 (e.g. 0.85 = 85%)
  final double studyHoursReported; // per week

  AcademicRecord({
    required this.recordId,
    required this.studentId,
    required this.term,
    required this.subject,
    required this.marks,
    required this.gpa,
    required this.backlogs,
    required this.assignmentCompletionRate,
    required this.studyHoursReported,
  });

  factory AcademicRecord.fromMap(Map<String, dynamic> map, String id) {
    return AcademicRecord(
      recordId: id,
      studentId: map['studentId'] ?? '',
      term: map['term'] ?? '',
      subject: map['subject'] ?? 'Overall',
      marks: (map['marks'] as num?)?.toDouble() ?? 0.0,
      gpa: (map['gpa'] as num?)?.toDouble() ?? 0.0,
      backlogs: (map['backlogs'] as num?)?.toInt() ?? 0,
      assignmentCompletionRate:
          (map['assignmentCompletionRate'] as num?)?.toDouble() ?? 0.0,
      studyHoursReported:
          (map['studyHoursReported'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'term': term,
      'subject': subject,
      'marks': marks,
      'gpa': gpa,
      'backlogs': backlogs,
      'assignmentCompletionRate': assignmentCompletionRate,
      'studyHoursReported': studyHoursReported,
    };
  }
}
