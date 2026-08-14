class ShapFactor {
  final String factorName; // e.g. "Attendance Deficit", "Failed Mathematics"
  final String impactLevel; // "high_negative", "moderate_negative", "slight_negative", "positive"
  final String plainTextDescription; // Plain language breakdown for Headmaster & Teacher
  final double weight; // Magnitude (0.0 to 1.0) for visual progress bar

  ShapFactor({
    required this.factorName,
    required this.impactLevel,
    required this.plainTextDescription,
    required this.weight,
  });

  factory ShapFactor.fromMap(Map<String, dynamic> map) {
    return ShapFactor(
      factorName: map['factorName']?.toString() ?? map['name']?.toString() ?? map['factor']?.toString() ?? 'Risk Factor',
      impactLevel: map['impactLevel']?.toString() ?? map['level']?.toString() ?? map['impact']?.toString() ?? 'moderate_negative',
      plainTextDescription: map['plainTextDescription']?.toString() ??
          map['desc']?.toString() ??
          map['description']?.toString() ??
          map['driver']?.toString() ??
          'Significant impact on student retention.',
      weight: (map['weight'] as num?)?.toDouble() ?? 0.5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'factorName': factorName,
      'name': factorName,
      'factor': factorName,
      'impactLevel': impactLevel,
      'level': impactLevel,
      'impact': impactLevel,
      'plainTextDescription': plainTextDescription,
      'desc': plainTextDescription,
      'description': plainTextDescription,
      'driver': plainTextDescription,
      'weight': weight,
    };
  }
}

class DropoutPrediction {
  final String studentId;
  final double riskScore; // 0.0 to 1.0
  final String riskLabel; // "low" | "medium" | "high"
  final List<ShapFactor> topFactors;
  final DateTime lastUpdated;
  final String modelVersion;
  final String? principalNotes;
  final String? interventionStatus; // "Pending Review", "Counseling Scheduled", "Action Taken", "Resolved"

  DropoutPrediction({
    required this.studentId,
    required this.riskScore,
    required this.riskLabel,
    required this.topFactors,
    required this.lastUpdated,
    required this.modelVersion,
    this.principalNotes,
    this.interventionStatus,
  });

  factory DropoutPrediction.fromMap(Map<String, dynamic> map, String id) {
    var rawFactors = map['topFactors'] ?? map['factors'] ?? map['riskDrivers'] ?? map['drivers'] ?? [];
    List<ShapFactor> factors = [];
    if (rawFactors is List) {
      for (var f in rawFactors) {
        if (f is Map) {
          factors.add(ShapFactor.fromMap(Map<String, dynamic>.from(f)));
        } else if (f is String) {
          factors.add(ShapFactor(
            factorName: 'Risk Driver',
            impactLevel: 'high_negative',
            plainTextDescription: f,
            weight: 0.75,
          ));
        }
      }
    }

    double score = (map['riskScore'] as num?)?.toDouble() ??
        (map['score'] as num?)?.toDouble() ??
        (map['riskPercentage'] as num?)?.toDouble() ?? 0.0;
    if (score > 1.0) score = score / 100.0; // handle percentage e.g. 90% -> 0.90

    String label = map['riskLabel']?.toString() ??
        map['label']?.toString() ??
        map['riskLevel']?.toString() ??
        (score >= 0.70 ? 'high' : (score >= 0.35 ? 'medium' : 'low'));

    return DropoutPrediction(
      studentId: id,
      riskScore: score,
      riskLabel: label,
      topFactors: factors,
      lastUpdated: map['lastUpdated'] != null
          ? (map['lastUpdated'] is DateTime
              ? map['lastUpdated']
              : DateTime.tryParse(map['lastUpdated'].toString()) ?? DateTime.now())
          : DateTime.now(),
      modelVersion: map['modelVersion']?.toString() ?? 'v2.1-XGBoost',
      principalNotes: map['principalNotes']?.toString() ?? map['notes']?.toString(),
      interventionStatus: map['interventionStatus']?.toString() ?? map['status']?.toString() ?? 'Pending Review',
    );
  }

  Map<String, dynamic> toMap() {
    String driversString = topFactors
        .map((f) => f.plainTextDescription)
        .where((d) => d.isNotEmpty)
        .join(', ');

    return {
      'studentId': studentId,
      'id': studentId,
      'riskScore': riskScore,
      'score': riskScore,
      'riskPercentage': (riskScore * 100).roundToDouble(),
      'riskLabel': riskLabel,
      'label': riskLabel,
      'riskLevel': riskLabel,
      'topFactors': topFactors.map((f) => f.toMap()).toList(),
      'factors': topFactors.map((f) => f.toMap()).toList(),
      'riskDrivers': driversString,
      'drivers': driversString,
      'risk_drivers': driversString,
      'lastUpdated': lastUpdated.toIso8601String(),
      'modelVersion': modelVersion,
      'principalNotes': principalNotes,
      'notes': principalNotes,
      'interventionStatus': interventionStatus,
      'status': interventionStatus,
    };
  }
}
