enum InterventionCategory {
  counseling,
  remedialSupport,
  parentContact,
  peerMentorship,
  attendanceContract,
  warningFlagged,
}

class InterventionRecord {
  final String id;
  final String studentId;
  final String studentName;
  final String title;
  final InterventionCategory category;
  final String description;
  final DateTime date;
  final String actionTaken;
  final List<String> attachmentUrls;

  InterventionRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.title,
    required this.category,
    required this.description,
    required this.date,
    required this.actionTaken,
    this.attachmentUrls = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'studentName': studentName,
    'title': title,
    'category': category.name,
    'description': description,
    'date': date.millisecondsSinceEpoch,
    'actionTaken': actionTaken,
    'attachmentUrls': attachmentUrls,
  };

  factory InterventionRecord.fromJson(Map<String, dynamic> json) => InterventionRecord(
    id: json['id'],
    studentId: json['studentId'],
    studentName: json['studentName'],
    title: json['title'],
    category: InterventionCategory.values.firstWhere(
      (e) => e.name == json['category'],
      orElse: () => InterventionCategory.warningFlagged,
    ),
    description: json['description'],
    date: DateTime.fromMillisecondsSinceEpoch(json['date']),
    actionTaken: json['actionTaken'],
    attachmentUrls: List<String>.from(json['attachmentUrls'] ?? []),
  );
}

class DropoutFactor {
  final String factorName;
  final String impactLevel; // "high_negative", "medium_negative"
  final String plainTextDescription;
  final double weight;

  DropoutFactor({
    required this.factorName,
    required this.impactLevel,
    required this.plainTextDescription,
    required this.weight,
  });

  Map<String, dynamic> toJson() => {
    'factorName': factorName,
    'impactLevel': impactLevel,
    'plainTextDescription': plainTextDescription,
    'weight': weight,
  };

  factory DropoutFactor.fromJson(Map<String, dynamic> json) => DropoutFactor(
    factorName: json['factorName'] ?? '',
    impactLevel: json['impactLevel'] ?? 'medium_negative',
    plainTextDescription: json['plainTextDescription'] ?? '',
    weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
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

class DropoutPrediction {
  final String studentId;
  final double riskScore; // 0.0 to 1.0
  final String riskLabel; // "high", "medium", "low"
  final String modelVersion;
  final List<DropoutFactor> topFactors;
  final String principalNotes;
  final String interventionStatus; // "Pending Review", "Counseling Scheduled", "Resolved"

  DropoutPrediction({
    required this.studentId,
    required this.riskScore,
    required this.riskLabel,
    this.modelVersion = 'v2.1-XGBoost',
    required this.topFactors,
    required this.principalNotes,
    required this.interventionStatus,
  });

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'riskScore': riskScore,
    'riskLabel': riskLabel.toLowerCase(),
    'modelVersion': modelVersion,
    'topFactors': topFactors.map((e) => e.toJson()).toList(),
    'principalNotes': principalNotes,
    'interventionStatus': interventionStatus,
  };

  factory DropoutPrediction.fromJson(Map<String, dynamic> json) => DropoutPrediction(
    studentId: json['studentId'] ?? '',
    riskScore: (json['riskScore'] as num?)?.toDouble() ?? 0.0,
    riskLabel: json['riskLabel'] ?? 'low',
    modelVersion: json['modelVersion'] ?? 'v2.1-XGBoost',
    topFactors: (json['topFactors'] as List? ?? []).map((e) => DropoutFactor.fromJson(Map<String, dynamic>.from(e))).toList(),
    principalNotes: json['principalNotes'] ?? '',
    interventionStatus: json['interventionStatus'] ?? 'Pending Review',
  );
}

class InterventionRecommendation {
  final String recommendationId;
  final String studentId;
  final String studentName;
  final String schoolId;
  final String schoolName;
  final String classId;
  final String teacherName;
  final String pillarType; // "scholarship", "hostel", "subject_coaching", or "extracurricular_talent"
  final String targetEntity; // e.g. Agaram Foundation, Govt BC Welfare Hostel
  final String reasonNotes;
  final String status; // "Pending Principal Review", "Approved by Principal (Sent to Municipality)", "Municipality Endorsed & Dispatched"
  final String principalNotes;
  final String municipalityNotes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    required this.principalNotes,
    required this.municipalityNotes,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'recommendationId': recommendationId,
    'studentId': studentId,
    'studentName': studentName,
    'schoolId': schoolId,
    'schoolName': schoolName,
    'classId': classId,
    'teacherName': teacherName,
    'pillarType': pillarType,
    'targetEntity': targetEntity,
    'reasonNotes': reasonNotes,
    'status': status,
    'principalNotes': principalNotes,
    'municipalityNotes': municipalityNotes,
    'createdAt': createdAt ?? DateTime.now(),
    'updatedAt': updatedAt ?? DateTime.now(),
  };

  factory InterventionRecommendation.fromJson(Map<String, dynamic> json) => InterventionRecommendation(
    recommendationId: json['recommendationId'] ?? '',
    studentId: json['studentId'] ?? '',
    studentName: json['studentName'] ?? '',
    schoolId: json['schoolId'] ?? '',
    schoolName: json['schoolName'] ?? '',
    classId: json['classId'] ?? '',
    teacherName: json['teacherName'] ?? '',
    pillarType: json['pillarType'] ?? 'scholarship',
    targetEntity: json['targetEntity'] ?? '',
    reasonNotes: json['reasonNotes'] ?? '',
    status: json['status'] ?? 'Pending Principal Review',
    principalNotes: json['principalNotes'] ?? '',
    municipalityNotes: json['municipalityNotes'] ?? '',
    createdAt: _parseDateTime(json['createdAt']),
    updatedAt: _parseDateTime(json['updatedAt']),
  );
}


