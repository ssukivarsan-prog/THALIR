class ClassStat {
  final String classId;
  final int totalStudents;
  final int atRiskCount;
  final int highRiskCount;
  final int mediumRiskCount;
  final int lowRiskCount;
  final double avgRiskScore;
  final double avgAttendanceRate;
  final double avgGpa;

  ClassStat({
    required this.classId,
    required this.totalStudents,
    required this.atRiskCount,
    required this.highRiskCount,
    required this.mediumRiskCount,
    required this.lowRiskCount,
    required this.avgRiskScore,
    required this.avgAttendanceRate,
    required this.avgGpa,
  });

  factory ClassStat.fromMap(Map<String, dynamic> map, String id) {
    return ClassStat(
      classId: id,
      totalStudents: (map['totalStudents'] as num?)?.toInt() ?? 0,
      atRiskCount: (map['atRiskCount'] as num?)?.toInt() ?? 0,
      highRiskCount: (map['highRiskCount'] as num?)?.toInt() ?? 0,
      mediumRiskCount: (map['mediumRiskCount'] as num?)?.toInt() ?? 0,
      lowRiskCount: (map['lowRiskCount'] as num?)?.toInt() ?? 0,
      avgRiskScore: (map['avgRiskScore'] as num?)?.toDouble() ?? 0.0,
      avgAttendanceRate: (map['avgAttendanceRate'] as num?)?.toDouble() ?? 0.0,
      avgGpa: (map['avgGpa'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'totalStudents': totalStudents,
      'atRiskCount': atRiskCount,
      'highRiskCount': highRiskCount,
      'mediumRiskCount': mediumRiskCount,
      'lowRiskCount': lowRiskCount,
      'avgRiskScore': avgRiskScore,
      'avgAttendanceRate': avgAttendanceRate,
      'avgGpa': avgGpa,
    };
  }
}

class SchoolStats {
  final String schoolId;
  final int totalStudents;
  final int highRiskCount;
  final int mediumRiskCount;
  final int lowRiskCount;
  final double averageRiskScore;
  final double averageAttendanceRate;
  final double averageGpa;
  final Map<String, ClassStat> classStats;
  final DateTime lastCalculated;

  SchoolStats({
    required this.schoolId,
    required this.totalStudents,
    required this.highRiskCount,
    required this.mediumRiskCount,
    required this.lowRiskCount,
    required this.averageRiskScore,
    required this.averageAttendanceRate,
    required this.averageGpa,
    required this.classStats,
    required this.lastCalculated,
  });

  int get totalAtRisk => highRiskCount + mediumRiskCount;
  double get percentageAtRisk =>
      totalStudents > 0 ? (totalAtRisk / totalStudents) * 100 : 0.0;

  factory SchoolStats.fromMap(Map<String, dynamic> map, String id) {
    var rawClassStats = map['classStats'] as Map<String, dynamic>? ?? {};
    Map<String, ClassStat> classes = {};
    rawClassStats.forEach((key, val) {
      classes[key] = ClassStat.fromMap(Map<String, dynamic>.from(val), key);
    });

    return SchoolStats(
      schoolId: id,
      totalStudents: (map['totalStudents'] as num?)?.toInt() ?? 0,
      highRiskCount: (map['highRiskCount'] as num?)?.toInt() ?? 0,
      mediumRiskCount: (map['mediumRiskCount'] as num?)?.toInt() ?? 0,
      lowRiskCount: (map['lowRiskCount'] as num?)?.toInt() ?? 0,
      averageRiskScore: (map['averageRiskScore'] as num?)?.toDouble() ?? 0.0,
      averageAttendanceRate:
          (map['averageAttendanceRate'] as num?)?.toDouble() ?? 0.0,
      averageGpa: (map['averageGpa'] as num?)?.toDouble() ?? 0.0,
      classStats: classes,
      lastCalculated: map['lastCalculated'] != null
          ? (map['lastCalculated'] is DateTime
              ? map['lastCalculated']
              : DateTime.tryParse(map['lastCalculated'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalStudents': totalStudents,
      'highRiskCount': highRiskCount,
      'mediumRiskCount': mediumRiskCount,
      'lowRiskCount': lowRiskCount,
      'averageRiskScore': averageRiskScore,
      'averageAttendanceRate': averageAttendanceRate,
      'averageGpa': averageGpa,
      'classStats': classStats.map((k, v) => MapEntry(k, v.toMap())),
      'lastCalculated': lastCalculated.toIso8601String(),
    };
  }
}
