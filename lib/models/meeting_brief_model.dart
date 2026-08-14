class MeetingBrief {
  final String studentId;
  final String studentName;
  final String className;
  final double attendancePercentage;
  final double academicAverage;
  final double dropoutRiskScore;
  final String dropoutRiskLevel;
  final List<String> primaryRiskFactors;
  final List<String> skippingTriggers;
  final List<String> protectiveFactors;
  final List<String> suggestedInterventions;
  final List<String> actionPlan;
  final String conciseText;

  MeetingBrief({
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.attendancePercentage,
    required this.academicAverage,
    required this.dropoutRiskScore,
    required this.dropoutRiskLevel,
    required this.primaryRiskFactors,
    required this.skippingTriggers,
    required this.protectiveFactors,
    required this.suggestedInterventions,
    required this.actionPlan,
    required this.conciseText,
  });
}

DateTime? _parseDateTime(dynamic val) {
  if (val == null) return null;
  if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
  if (val is String) return DateTime.tryParse(val);
  try {
    return val.toDate() as DateTime;
  } catch (_) {}
  return null;
}

class MeetingRecord {
  final String id;
  final String studentId;
  final String studentName;
  final DateTime date;
  final String topic; // E.g., "Dropout Risk Counseling", "Math Anxiety Intervention"
  final String outcome;
  final Map<String, String> structuredOutcome; // E.g., {'Risk Factor': 'Math Anxiety', 'Action': 'Assign Peer Support'}
  final String teacherNotes;
  final DateTime? followUpDate;
  final String status; // 'Scheduled', 'Completed'

  MeetingRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.topic,
    required this.outcome,
    required this.structuredOutcome,
    required this.teacherNotes,
    this.followUpDate,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'meetingId': id,
    'id': id,
    'studentId': studentId,
    'studentName': studentName,
    'scheduledDate': date, // Firestore automatic Timestamp conversion
    'date': date.millisecondsSinceEpoch,
    'title': topic,
    'topic': topic,
    'outcome': outcome,
    'structuredOutcome': structuredOutcome,
    'notes': teacherNotes,
    'teacherNotes': teacherNotes,
    'followUpDate': followUpDate?.millisecondsSinceEpoch,
    'status': status,
  };

  factory MeetingRecord.fromJson(Map<String, dynamic> json) => MeetingRecord(
    id: json['meetingId'] ?? json['id'] ?? '',
    studentId: json['studentId'] ?? '',
    studentName: json['studentName'] ?? '',
    date: _parseDateTime(json['scheduledDate'] ?? json['date']) ?? DateTime.now(),
    topic: json['title'] ?? json['topic'] ?? '',
    outcome: json['outcome'] ?? '',
    structuredOutcome: Map<String, String>.from(json['structuredOutcome'] ?? {}),
    teacherNotes: json['notes'] ?? json['teacherNotes'] ?? '',
    followUpDate: json['followUpDate'] != null ? _parseDateTime(json['followUpDate']) : null,
    status: json['status'] ?? 'Scheduled',
  );
}
