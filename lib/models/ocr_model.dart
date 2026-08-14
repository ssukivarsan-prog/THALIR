enum OcrDocumentType {
  attendance,
  classTestMarks,
  examMarks,
}

enum OcrAnomalyType {
  missingValue,
  duplicateId,
  unknownStudent,
  marksExceedMax,
  invalidAttendance,
  lowConfidence,
}

class OcrExtractionRow {
  final String id;
  final String rollNumber;
  final String studentName;
  final String subject;
  final String assessmentType;
  final double? marks;
  final double? maxMarks;
  final String attendanceStatus; // 'Present', 'Absent'
  final DateTime date;
  final double confidenceScore; // 0.0 to 1.0 (e.g. 0.98 = 98%, 0.52 = 52%)
  final List<OcrAnomalyType> anomalies;
  bool isEdited;
  bool isConfirmed;

  OcrExtractionRow({
    required this.id,
    required this.rollNumber,
    required this.studentName,
    required this.subject,
    required this.assessmentType,
    this.marks,
    this.maxMarks,
    required this.attendanceStatus,
    required this.date,
    required this.confidenceScore,
    required this.anomalies,
    this.isEdited = false,
    this.isConfirmed = false,
  });

  OcrExtractionRow copyWith({
    String? rollNumber,
    String? studentName,
    String? subject,
    String? assessmentType,
    double? marks,
    double? maxMarks,
    String? attendanceStatus,
    double? confidenceScore,
    List<OcrAnomalyType>? anomalies,
    bool? isEdited,
    bool? isConfirmed,
  }) {
    return OcrExtractionRow(
      id: id,
      rollNumber: rollNumber ?? this.rollNumber,
      studentName: studentName ?? this.studentName,
      subject: subject ?? this.subject,
      assessmentType: assessmentType ?? this.assessmentType,
      marks: marks ?? this.marks,
      maxMarks: maxMarks ?? this.maxMarks,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      date: date,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      anomalies: anomalies ?? this.anomalies,
      isEdited: isEdited ?? this.isEdited,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'rollNumber': rollNumber,
    'studentName': studentName,
    'subject': subject,
    'assessmentType': assessmentType,
    'marks': marks,
    'maxMarks': maxMarks,
    'attendanceStatus': attendanceStatus,
    'date': date.millisecondsSinceEpoch,
    'confidenceScore': confidenceScore,
    'anomalies': anomalies.map((e) => e.name).toList(),
    'isEdited': isEdited,
    'isConfirmed': isConfirmed,
  };

  factory OcrExtractionRow.fromJson(Map<String, dynamic> json) => OcrExtractionRow(
    id: json['id'],
    rollNumber: json['rollNumber'],
    studentName: json['studentName'],
    subject: json['subject'],
    assessmentType: json['assessmentType'],
    marks: json['marks'] != null ? (json['marks'] as num).toDouble() : null,
    maxMarks: json['maxMarks'] != null ? (json['maxMarks'] as num).toDouble() : null,
    attendanceStatus: json['attendanceStatus'] ?? 'Present',
    date: DateTime.fromMillisecondsSinceEpoch(json['date']),
    confidenceScore: (json['confidenceScore'] as num).toDouble(),
    anomalies: (json['anomalies'] as List? ?? [])
        .map((e) => OcrAnomalyType.values.firstWhere((at) => at.name == e.toString(), orElse: () => OcrAnomalyType.lowConfidence))
        .toList(),
    isEdited: json['isEdited'] ?? false,
    isConfirmed: json['isConfirmed'] ?? false,
  );
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

class OcrScanRecord {
  final String id;
  final String title;
  final OcrDocumentType documentType;
  final String className;
  final DateTime scanDate;
  final int recordCount;
  final String verificationStatus; // 'Processing', 'Verification Required', 'Verified', 'Sync Pending'
  final bool isSynced;
  final List<OcrExtractionRow> rows;
  final String? previewImageUrl;
  final String teacherName;
  final String rawText;

  OcrScanRecord({
    required this.id,
    required this.title,
    required this.documentType,
    required this.className,
    required this.scanDate,
    required this.recordCount,
    required this.verificationStatus,
    required this.isSynced,
    required this.rows,
    this.previewImageUrl,
    this.teacherName = 'Ananya Sharma',
    this.rawText = '',
  });

  Map<String, dynamic> toJson() => {
    'ocrId': id,
    'id': id,
    'title': title,
    'documentType': documentType.name,
    'className': className,
    'scannedDate': scanDate, // Firestore automatic Timestamp conversion
    'scanDate': scanDate.millisecondsSinceEpoch,
    'recordCount': recordCount,
    'verificationStatus': verificationStatus,
    'isSynced': isSynced,
    'rows': rows.map((e) => e.toJson()).toList(),
    'previewImageUrl': previewImageUrl,
    'teacherName': teacherName,
    'rawText': rawText,
  };

  factory OcrScanRecord.fromJson(Map<String, dynamic> json) => OcrScanRecord(
    id: json['ocrId'] ?? json['id'] ?? '',
    title: json['title'] ?? '',
    documentType: OcrDocumentType.values.firstWhere((e) => e.name == json['documentType'], orElse: () => OcrDocumentType.attendance),
    className: json['className'] ?? '',
    scanDate: _parseDateTime(json['scannedDate'] ?? json['scanDate']) ?? DateTime.now(),
    recordCount: json['recordCount'] ?? 0,
    verificationStatus: json['verificationStatus'] ?? 'Verified',
    isSynced: json['isSynced'] ?? true,
    rows: (json['rows'] as List? ?? []).map((e) => OcrExtractionRow.fromJson(Map<String, dynamic>.from(e))).toList(),
    previewImageUrl: json['previewImageUrl'],
    teacherName: json['teacherName'] ?? 'Ananya Sharma',
    rawText: json['rawText'] ?? '',
  );
}
