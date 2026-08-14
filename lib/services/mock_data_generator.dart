import 'dart:math';
import '../models/school.dart';
import '../models/app_user.dart';
import '../models/student.dart';
import '../models/attendance_record.dart';
import '../models/academic_record.dart';
import '../models/dropout_prediction.dart';
import '../models/school_stats.dart';
import '../models/intervention_recommendation.dart';

class MockDataGenerator {
  static const String demoSchoolId = "school-greenwood-01";
  static const String demoHeadmasterId = "user-hm-01";
  static const String demoMunicipalityId = "muni-chennai-corp";

  static List<School> getDemoMunicipalitySchools() {
    return [
      School(
        schoolId: demoSchoolId,
        name: "St. Xavier Model Higher Secondary School",
        municipalityId: demoMunicipalityId,
        municipalityName: "Chennai Municipal Corporation",
        address: "104 Cathedral Road, Zone 5, Chennai",
        contactInfo: "+91 44 2827 0011 | office@stxavier.edu.in",
      ),
      School(
        schoolId: "school-tnagar-02",
        name: "Govt Model Higher Secondary School, T. Nagar",
        municipalityId: demoMunicipalityId,
        municipalityName: "Chennai Municipal Corporation",
        address: "45 Venkatanarayana Road, T. Nagar, Zone 8, Chennai",
        contactInfo: "+91 44 2434 5588 | hm.tnagargovt@tn.gov.in",
      ),
      School(
        schoolId: "school-girls-03",
        name: "Chennai Corporation Girls High School, Royapettah",
        municipalityId: demoMunicipalityId,
        municipalityName: "Chennai Municipal Corporation",
        address: "12 Westcott Road, Royapettah, Zone 9, Chennai",
        contactInfo: "+91 44 2848 1122 | hm.royapettahgirls@chennaicorp.gov.in",
      ),
      School(
        schoolId: "school-joseph-04",
        name: "St. Joseph Municipal Higher Secondary School",
        municipalityId: demoMunicipalityId,
        municipalityName: "Chennai Municipal Corporation",
        address: "88 Paper Mills Road, Perambur, Zone 3, Chennai",
        contactInfo: "+91 44 2551 9900 | stjoseph.perambur@school.edu.in",
      ),
    ];
  }

  static School getDemoSchool() {
    return getDemoMunicipalitySchools().first;
  }

  static AppUser getDemoHeadmaster() {
    return AppUser(
      userId: demoHeadmasterId,
      role: "principal",
      schoolId: demoSchoolId,
      municipalityId: demoMunicipalityId,
      name: "Dr. Eleanor Vance",
      email: "principal@stxavier.edu.in",
    );
  }

  static AppUser getDemoMunicipalityHead() {
    return AppUser(
      userId: "user-muni-head-01",
      role: "municipality_head",
      schoolId: "",
      municipalityId: demoMunicipalityId,
      name: "Thiru M. K. Selvam, IAS",
      email: "ceo.education@chennaicorp.gov.in",
    );
  }

  static List<Student> getDemoStudents() {
    final List<Map<String, dynamic>> rawStudents = [
      // Class VIII-A (8 A) Teacher App Roster
      {
        'id': '23VIII001',
        'class': 'Class VIII-A',
        'name': 'Arun Kumar',
        'roll': '23VIII001',
        'gender': 'Male',
        'father': 'Suresh Kumar',
        'mother': 'Meenakshi Kumar',
        'contact': '+91 98401 11001'
      },
      {
        'id': '23VIII002',
        'class': 'Class VIII-A',
        'name': 'Priya Sharma',
        'roll': '23VIII002',
        'gender': 'Female',
        'father': 'Rajesh Sharma',
        'mother': 'Sunita Sharma',
        'contact': '+91 98401 11002'
      },
      {
        'id': '23VIII003',
        'class': 'Class VIII-A',
        'name': 'Kumar Swamy',
        'roll': '23VIII003',
        'gender': 'Male',
        'father': 'Raman Swamy',
        'mother': 'Lakshmi Swamy',
        'contact': '+91 98401 11003'
      },

      // High Risk Students
      {
        'id': 'std-101',
        'class': 'Class X-A',
        'name': 'Rahul Sharma',
        'roll': '10A-04',
        'gender': 'Male',
        'father': 'Anand Sharma',
        'mother': 'Sunita Sharma',
        'contact': '+91 98401 23456'
      },
      {
        'id': 'std-102',
        'class': 'Class IX-B',
        'name': 'Priya Patel',
        'roll': '9B-12',
        'gender': 'Female',
        'father': 'Suresh Patel',
        'mother': 'Kavita Patel',
        'contact': '+91 98402 34567'
      },
      {
        'id': 'std-103',
        'class': 'Class X-B',
        'name': 'Karthik Raja',
        'roll': '10B-08',
        'gender': 'Male',
        'father': 'Raman Raja',
        'mother': 'Saradha Raja',
        'contact': '+91 98403 45678'
      },
      {
        'id': 'std-104',
        'class': 'Class VIII-A',
        'name': 'Ananya Sundaram',
        'roll': '8A-19',
        'gender': 'Female',
        'father': 'Sundaram Pillai',
        'mother': 'Meena Sundaram',
        'contact': '+91 98404 56789'
      },
      {
        'id': 'std-105',
        'class': 'Class XI-A',
        'name': 'Vijay Kumar',
        'roll': '11A-02',
        'gender': 'Male',
        'father': 'Selvam Kumar',
        'mother': 'Parvathi Kumar',
        'contact': '+91 98405 67890'
      },
      // Medium Risk
      {
        'id': 'std-106',
        'class': 'Class X-A',
        'name': 'Deepa Lakshmanan',
        'roll': '10A-15',
        'gender': 'Female',
        'father': 'Lakshmanan Pillai',
        'mother': 'Radhika Lakshmanan',
        'contact': '+91 98406 78901'
      },
      {
        'id': 'std-107',
        'class': 'Class IX-A',
        'name': 'Sanjay Srinivasan',
        'roll': '9A-22',
        'gender': 'Male',
        'father': 'Kamesh Srinivasan',
        'mother': 'Vidyalakshmi Srinivasan',
        'contact': '+91 98407 89012'
      },
      {
        'id': 'std-108',
        'class': 'Class X-B',
        'name': 'Lavanya Venkatesh',
        'roll': '10B-30',
        'gender': 'Female',
        'father': 'Venkatesh Rao',
        'mother': 'Uma Venkatesh',
        'contact': '+91 98408 90123'
      },
      {
        'id': 'std-109',
        'class': 'Class VIII-B',
        'name': 'Ganesh Natarajan',
        'roll': '8B-07',
        'gender': 'Male',
        'father': 'Natarajan Chettiar',
        'mother': 'Saraswathi Natarajan',
        'contact': '+91 98409 01234'
      },
      {
        'id': 'std-110',
        'class': 'Class XI-B',
        'name': 'Bhavani Chandran',
        'roll': '11B-14',
        'gender': 'Female',
        'father': 'Chandran Pillai',
        'mother': 'Valli Chandran',
        'contact': '+91 98410 12345'
      },
      // Low Risk
      {
        'id': 'std-111',
        'class': 'Class X-A',
        'name': 'Arun Prakash',
        'roll': '10A-01',
        'gender': 'Male',
        'father': 'Prakash Raj',
        'mother': 'Shanthi Prakash',
        'contact': '+91 98411 23456'
      },
      {
        'id': 'std-112',
        'class': 'Class IX-A',
        'name': 'Kavya Nair',
        'roll': '9A-03',
        'gender': 'Female',
        'father': 'Raman Nair',
        'mother': 'Geetha Nair',
        'contact': '+91 98412 34567'
      },
      {
        'id': 'std-113',
        'class': 'Class VIII-A',
        'name': 'Manoj Prabhakar',
        'roll': '8A-10',
        'gender': 'Male',
        'father': 'Prabhakar Rao',
        'mother': 'Kalyani Prabhakar',
        'contact': '+91 98413 45678'
      },
      {
        'id': 'std-114',
        'class': 'Class XII-A',
        'name': 'Swetha Ramakrishnan',
        'roll': '12A-05',
        'gender': 'Female',
        'father': 'Ramakrishnan Iyer',
        'mother': 'Sita Ramakrishnan',
        'contact': '+91 98414 56789'
      },
      {
        'id': 'std-115',
        'class': 'Class XI-A',
        'name': 'Naveen Balaji',
        'roll': '11A-18',
        'gender': 'Male',
        'father': 'Balaji Naidu',
        'mother': 'Revathi Balaji',
        'contact': '+91 98415 67890'
      },
      {
        'id': 'std-116',
        'class': 'Class XII-B',
        'name': 'Aarav Subash',
        'roll': '12B-02',
        'gender': 'Male',
        'father': 'Subash Chandra',
        'mother': 'Janaki Subash',
        'contact': '+91 98416 78901'
      },
    ];

    return rawStudents.map((data) {
      return Student(
        studentId: data['id'],
        schoolId: demoSchoolId,
        classId: data['class'],
        name: data['name'],
        rollNumber: data['roll'],
        gender: data['gender'],
        fatherName: data['father'] ?? 'Suresh Sharma',
        motherName: data['mother'] ?? 'Sunita Sharma',
        guardianContact: data['contact'],
      );
    }).toList();
  }

  static List<InterventionRecommendation> getDemoRecommendations() {
    return [
      InterventionRecommendation(
        recommendationId: "rec-01",
        studentId: "23VIII001",
        studentName: "Arun Kumar",
        schoolId: demoSchoolId,
        schoolName: "St. Xavier Model Higher Secondary School",
        classId: "Class VIII-A",
        teacherName: "Thiru R. Sundaram (Class Teacher)",
        pillarType: "scholarship",
        targetEntity: "Agaram Foundation Educational Scholarship",
        reasonNotes: "Attendance dropped to 64.0%. Failed Mathematics (52.0% avg). Single mother household requiring financial & academic support.",
        status: "Approved by Principal (Sent to Municipality)",
        principalNotes: "Verified background. Strongly recommended for Agaram Vidhai Scholarship.",
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      InterventionRecommendation(
        recommendationId: "rec-02",
        studentId: "std-102",
        studentName: "Priya Patel",
        schoolId: demoSchoolId,
        schoolName: "St. Xavier Model Higher Secondary School",
        classId: "Class IX-B",
        teacherName: "Tmt. K. Lakshmi (Class Teacher)",
        pillarType: "hostel",
        targetEntity: "Tamil Nadu Govt Welfare Hostel",
        reasonNotes: "Domestic conflicts and unsafe home environment leading to chronic absenteeism (62%). Govt hostel placement required.",
        status: "Pending Principal Review",
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  static Map<String, DropoutPrediction> getDemoDropoutPredictions() {
    return getDemoPredictions();
  }

  static Map<String, DropoutPrediction> getDemoPredictions() {
    final predictionsData = [
      {
        'id': '23VIII001',
        'score': 0.90,
        'label': 'high',
        'status': 'Pending Review',
        'notes': 'High dropout risk (90%). Attendance 64.0%, failed Mathematics.',
        'factors': [
          {'name': 'Attendance Deficit', 'level': 'high_negative', 'desc': 'Attendance rate dropped to 64.0%.', 'weight': 0.90},
          {'name': 'Failed Mathematics', 'level': 'high_negative', 'desc': 'Failed Mathematics with 52.0% average.', 'weight': 0.85},
        ]
      },
      {
        'id': '23VIII002',
        'score': 0.00,
        'label': 'low',
        'status': 'Resolved',
        'notes': 'Good regular academic standing.',
        'factors': [
          {'name': 'Good Attendance', 'level': 'positive', 'desc': 'Attendance at 94.0% with 88.5% GPA.', 'weight': 0.95},
        ]
      },
      {
        'id': '23VIII003',
        'score': 0.55,
        'label': 'medium',
        'status': 'Under Review',
        'notes': 'Medium risk flagged (55%). Attendance dropped below 80%.',
        'factors': [
          {'name': 'Attendance Drop', 'level': 'moderate_negative', 'desc': 'Attendance dropped below 80% (78.0%).', 'weight': 0.55},
        ]
      },
      {
        'id': 'std-101',
        'score': 0.88,
        'label': 'high',
        'status': 'Pending Review',
        'notes': 'Chronic absenteeism (58% attendance). Single mother household.',
        'factors': [
          {'name': 'Attendance Deficit', 'level': 'high_negative', 'desc': 'Attendance dropped to 58%.', 'weight': 0.88},
          {'name': 'Subject Failures', 'level': 'high_negative', 'desc': 'Failed 3 subjects in Half-Yearly.', 'weight': 0.82},
        ]
      },
    ];

    Map<String, DropoutPrediction> map = {};

    for (var p in predictionsData) {
      final factorsRaw = p['factors'] as List<Map<String, dynamic>>;
      final factors = factorsRaw.map((f) {
        return ShapFactor(
          factorName: f['name'],
          impactLevel: f['level'],
          plainTextDescription: f['desc'],
          weight: (f['weight'] as num).toDouble(),
        );
      }).toList();

      map[p['id'] as String] = DropoutPrediction(
        studentId: p['id'] as String,
        riskScore: (p['score'] as num).toDouble(),
        riskLabel: p['label'] as String,
        topFactors: factors,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 4)),
        modelVersion: 'v2.1-XGBoost-TN',
        principalNotes: p['notes'] as String,
        interventionStatus: p['status'] as String,
      );
    }

    final allStudents = getDemoStudents();
    for (var s in allStudents) {
      if (!map.containsKey(s.studentId)) {
        final isMed = s.studentId.contains('106') || s.studentId.contains('107') || s.studentId.contains('108');
        final score = isMed ? 0.42 : 0.12;
        final label = isMed ? 'medium' : 'low';
        map[s.studentId] = DropoutPrediction(
          studentId: s.studentId,
          riskScore: score,
          riskLabel: label,
          topFactors: isMed
              ? [
                  ShapFactor(
                    factorName: 'GPA Warning',
                    impactLevel: 'moderate_negative',
                    plainTextDescription: 'GPA 2.4 requires academic tutoring.',
                    weight: 0.45,
                  )
                ]
              : [],
          lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
          modelVersion: 'v2.1-XGBoost-TN',
          principalNotes: label == 'low' ? 'Good standing.' : 'Monitoring attendance.',
          interventionStatus: label == 'low' ? 'Resolved' : 'Under Review',
        );
      }
    }

    return map;
  }

  static SchoolStats getDemoStats() {
    return SchoolStats(
      schoolId: demoSchoolId,
      totalStudents: 480,
      highRiskCount: 18,
      mediumRiskCount: 42,
      lowRiskCount: 420,
      averageRiskScore: 0.18,
      averageAttendanceRate: 86.4,
      averageGpa: 3.1,
      classStats: {},
      lastCalculated: DateTime.now(),
    );
  }

  static SchoolStats getDemoSchoolStats() {
    return getDemoStats();
  }

  static List<AttendanceRecord> getDemoAttendanceHistory(String studentId) {
    return [
      AttendanceRecord(
        recordId: "att-1",
        studentId: studentId,
        date: DateTime.now().subtract(const Duration(days: 1)),
        present: true,
        enteredBy: "Class Teacher",
      ),
      AttendanceRecord(
        recordId: "att-2",
        studentId: studentId,
        date: DateTime.now().subtract(const Duration(days: 2)),
        present: false,
        enteredBy: "Class Teacher",
      ),
    ];
  }

  static List<AcademicRecord> getDemoAcademicHistory(String studentId) {
    return [
      AcademicRecord(
        recordId: "acad-1",
        studentId: studentId,
        term: "Quarterly Evaluation",
        subject: "Mathematics",
        marks: 52.0,
        gpa: 2.4,
        backlogs: 1,
        assignmentCompletionRate: 0.80,
        studyHoursReported: 6.0,
      ),
    ];
  }
}
