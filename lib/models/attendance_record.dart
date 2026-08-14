class AttendanceRecord {
  final String recordId;
  final String studentId;
  final DateTime date;
  final bool present;
  final String enteredBy;

  AttendanceRecord({
    required this.recordId,
    required this.studentId,
    required this.date,
    required this.present,
    required this.enteredBy,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceRecord(
      recordId: id,
      studentId: map['studentId'] ?? '',
      date: map['date'] != null
          ? (map['date'] is DateTime
              ? map['date']
              : DateTime.tryParse(map['date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      present: map['present'] ?? true,
      enteredBy: map['enteredBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'date': date.toIso8601String(),
      'present': present,
      'enteredBy': enteredBy,
    };
  }
}
