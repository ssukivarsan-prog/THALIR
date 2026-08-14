import 'package:flutter/foundation.dart';
import '../models/school.dart';
import '../models/app_user.dart';
import '../models/student.dart';
import '../models/dropout_prediction.dart';
import '../models/school_stats.dart';
import '../models/attendance_record.dart';
import '../models/academic_record.dart';
import '../models/intervention_recommendation.dart';
import '../services/firestore_service.dart';
import '../services/mock_data_generator.dart';

class DashboardProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  String _activeRole = 'principal'; // 'principal' or 'municipality_head'
  int _selectedNavIndex = 0; // Navigation tab index
  String? _selectedClassFilter = 'All Classes';
  String? _selectedRiskFilter = 'All Risk Levels';
  String _selectedMunicipalitySchoolId = 'All Schools';
  String _searchQuery = '';

  Student? _selectedStudent;
  List<AttendanceRecord> _selectedStudentAttendance = [];
  List<AcademicRecord> _selectedStudentAcademics = [];

  School? _school;
  List<School> _municipalitySchools = [];
  SchoolStats? _schoolStats;
  List<Student> _students = [];
  Map<String, DropoutPrediction> _predictions = {};
  List<InterventionRecommendation> _recommendations = [];
  bool _isLoading = true;

  // Getters
  String get activeRole => _activeRole;
  int get selectedNavIndex => _selectedNavIndex;
  String? get selectedClassFilter => _selectedClassFilter;
  String? get selectedRiskFilter => _selectedRiskFilter;
  String get selectedMunicipalitySchoolId => _selectedMunicipalitySchoolId;
  String get searchQuery => _searchQuery;

  Student? get selectedStudent => _selectedStudent;
  List<AttendanceRecord> get selectedStudentAttendance => _selectedStudentAttendance;
  List<AcademicRecord> get selectedStudentAcademics => _selectedStudentAcademics;

  School? get school => _school;
  List<School> get municipalitySchools => _municipalitySchools;
  SchoolStats? get schoolStats => _schoolStats;
  List<Student> get students => _students;
  Map<String, DropoutPrediction> get predictions => _predictions;
  List<InterventionRecommendation> get recommendations => _recommendations;
  bool get isLoading => _isLoading;

  List<String> get availableClasses {
    Set<String> set = {'All Classes'};
    for (var s in _students) {
      set.add(s.classId);
    }
    return set.toList()..sort();
  }

  DashboardProvider() {
    loadDashboardData();
  }

  void setActiveRole(String role) {
    _activeRole = role;
    _selectedNavIndex = 0; // Reset tab on role switch
    notifyListeners();
  }

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  void setClassFilter(String? classId) {
    _selectedClassFilter = classId;
    notifyListeners();
  }

  void setRiskFilter(String? risk) {
    _selectedRiskFilter = risk;
    notifyListeners();
  }

  void setMunicipalitySchoolId(String schoolId) {
    _selectedMunicipalitySchoolId = schoolId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final schoolId = MockDataGenerator.demoSchoolId;
      _school = MockDataGenerator.getDemoSchool();
      _municipalitySchools = MockDataGenerator.getDemoMunicipalitySchools();
      _students = MockDataGenerator.getDemoStudents();
      _predictions = MockDataGenerator.getDemoDropoutPredictions();
      _recommendations = MockDataGenerator.getDemoRecommendations();
      _schoolStats = MockDataGenerator.getDemoSchoolStats();

      // Listen/Sync to Cloud Firestore in real time
      try {
        final fsSchool = await _firestoreService.getSchool(schoolId);
        if (fsSchool != null) _school = fsSchool;

        _firestoreService.streamStudents(schoolId).listen((fsStudents) {
          if (fsStudents.isNotEmpty) {
            Map<String, Student> studentMap = {};
            for (var s in MockDataGenerator.getDemoStudents()) {
              studentMap[s.studentId] = s;
            }
            for (var s in fsStudents) {
              studentMap[s.studentId] = s;
            }
            _students = studentMap.values.toList();
            notifyListeners();
          }
        });

        _firestoreService.streamDropoutPredictions().listen((fsPreds) {
          if (fsPreds.isNotEmpty) {
            _predictions.addAll(fsPreds);
            notifyListeners();
          }
        });

        _firestoreService.streamRecommendations().listen((fsRecs) {
          if (fsRecs.isNotEmpty) {
            Map<String, InterventionRecommendation> recMap = {};
            for (var r in MockDataGenerator.getDemoRecommendations()) {
              recMap[r.recommendationId] = r;
            }
            for (var r in fsRecs) {
              recMap[r.recommendationId] = r;
            }
            _recommendations = recMap.values.toList();
            notifyListeners();
          }
        });
      } catch (e) {
        debugPrint("Using mock dataset fallback: $e");
      }
    } catch (e) {
      debugPrint("Error loading dashboard data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filtered recommendations by pillar & school
  List<InterventionRecommendation> filteredRecommendations(String? pillarType) {
    return _recommendations.where((rec) {
      // Role scoping: Principal sees only their school's recommendations
      if (_activeRole == 'principal' && rec.schoolId != _school?.schoolId) {
        return false;
      }

      // Municipality School Filter
      if (_activeRole == 'municipality_head' &&
          _selectedMunicipalitySchoolId != 'All Schools' &&
          rec.schoolId != _selectedMunicipalitySchoolId) {
        return false;
      }

      // Pillar Filter
      if (pillarType != null && pillarType != 'all' && rec.pillarType != pillarType) {
        return false;
      }

      // Search Query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nameMatch = rec.studentName.toLowerCase().contains(q);
        final entityMatch = rec.targetEntity.toLowerCase().contains(q);
        final notesMatch = rec.reasonNotes.toLowerCase().contains(q);
        if (!nameMatch && !entityMatch && !notesMatch) return false;
      }

      return true;
    }).toList();
  }

  // Filtered student list for table view
  List<Student> get filteredStudents {
    return _students.where((student) {
      final pred = _predictions[student.studentId];
      final riskLabel = pred?.riskLabel ?? 'low';

      // Flexible Class Filter with Roman Numeral Support (e.g. 'Class VIII-A', 'Grade 8-A', '8 A')
      if (_selectedClassFilter != null &&
          _selectedClassFilter != 'All Classes') {
        String normalizeClass(String input) {
          String s = input.toLowerCase().replaceAll('class', '').replaceAll('grade', '').replaceAll('std', '').replaceAll(RegExp(r'[^a-z0-9]'), '');
          s = s.replaceAll('viii', '8')
               .replaceAll('vii', '7')
               .replaceAll('xii', '12')
               .replaceAll('xi', '11')
               .replaceAll('ix', '9')
               .replaceAll('x', '10');
          return s;
        }

        final filterNorm = normalizeClass(_selectedClassFilter!);
        final studentClassNorm = normalizeClass(student.classId);

        if (student.classId != _selectedClassFilter &&
            filterNorm != studentClassNorm &&
            !studentClassNorm.contains(filterNorm) &&
            !filterNorm.contains(studentClassNorm)) {
          return false;
        }
      }

      // Risk Filter
      if (_selectedRiskFilter != null &&
          _selectedRiskFilter != 'All Risk Levels') {
        final filterLower = _selectedRiskFilter!.toLowerCase();
        if (filterLower.contains('high') && riskLabel != 'high') return false;
        if (filterLower.contains('medium') && riskLabel != 'medium') return false;
        if (filterLower.contains('low') && riskLabel != 'low') return false;
      }

      // Search Query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nameMatch = student.name.toLowerCase().contains(q);
        final rollMatch = student.rollNumber.toLowerCase().contains(q);
        final classMatch = student.classId.toLowerCase().contains(q);
        if (!nameMatch && !rollMatch && !classMatch) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        final scoreA = _predictions[a.studentId]?.riskScore ?? 0.0;
        final scoreB = _predictions[b.studentId]?.riskScore ?? 0.0;
        return scoreB.compareTo(scoreA);
      });
  }

  // Select student for drill-down modal / detail view
  Future<void> selectStudent(Student student) async {
    _selectedStudent = student;
    notifyListeners();

    _selectedStudentAttendance =
        await _firestoreService.getStudentAttendanceHistory(student.studentId);
    _selectedStudentAcademics =
        await _firestoreService.getStudentAcademicHistory(student.studentId);
    notifyListeners();
  }

  void clearSelectedStudent() {
    _selectedStudent = null;
    _selectedStudentAttendance = [];
    _selectedStudentAcademics = [];
    notifyListeners();
  }

  // Submit new Teacher Intervention Recommendation
  void submitTeacherRecommendation(InterventionRecommendation rec) {
    _recommendations.insert(0, rec);
    _firestoreService.addInterventionRecommendation(rec);
    notifyListeners();
  }

  // Approve Recommendation by Principal (forwards to Municipality)
  void approveRecommendationByPrincipal(String recId, String notes) {
    final idx = _recommendations.indexWhere((r) => r.recommendationId == recId);
    if (idx != -1) {
      final old = _recommendations[idx];
      _recommendations[idx] = InterventionRecommendation(
        recommendationId: old.recommendationId,
        studentId: old.studentId,
        studentName: old.studentName,
        schoolId: old.schoolId,
        schoolName: old.schoolName,
        classId: old.classId,
        teacherName: old.teacherName,
        pillarType: old.pillarType,
        targetEntity: old.targetEntity,
        reasonNotes: old.reasonNotes,
        status: 'Approved by Principal (Sent to Municipality)',
        principalNotes: notes,
        municipalityNotes: old.municipalityNotes,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Endorse & Dispatch by Municipality Officer
  void endorseAndDispatchByMunicipality(String recId, String notes) {
    final idx = _recommendations.indexWhere((r) => r.recommendationId == recId);
    if (idx != -1) {
      final old = _recommendations[idx];
      _recommendations[idx] = InterventionRecommendation(
        recommendationId: old.recommendationId,
        studentId: old.studentId,
        studentName: old.studentName,
        schoolId: old.schoolId,
        schoolName: old.schoolName,
        classId: old.classId,
        teacherName: old.teacherName,
        pillarType: old.pillarType,
        targetEntity: old.targetEntity,
        reasonNotes: old.reasonNotes,
        status: 'Municipality Endorsed & Dispatched',
        principalNotes: old.principalNotes,
        municipalityNotes: notes,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Save intervention annotation to student prediction
  Future<bool> saveStudentIntervention(
      String studentId, String notes, String status) async {
    final success = await _firestoreService.updateInterventionNotes(
        studentId, notes, status);

    final currentPred = _predictions[studentId];
    if (currentPred != null) {
      _predictions[studentId] = DropoutPrediction(
        studentId: currentPred.studentId,
        riskScore: currentPred.riskScore,
        riskLabel: currentPred.riskLabel,
        topFactors: currentPred.topFactors,
        lastUpdated: DateTime.now(),
        modelVersion: currentPred.modelVersion,
        principalNotes: notes,
        interventionStatus: status,
      );
      notifyListeners();
    }
    return true;
  }

  // Add new student
  Future<void> addNewStudent(
      Student student, DropoutPrediction prediction) async {
    _students.insert(0, student);
    _predictions[student.studentId] = prediction;

    await _firestoreService.addStudent(student);
    await _firestoreService.addDropoutPrediction(prediction);

    int high = 0, med = 0, low = 0;
    for (var p in _predictions.values) {
      if (p.riskLabel == 'high') {
        high++;
      } else if (p.riskLabel == 'medium') {
        med++;
      } else {
        low++;
      }
    }

    final total = _students.length;
    final avgRisk = _predictions.values
            .map((e) => e.riskScore)
            .reduce((a, b) => a + b) /
        (total > 0 ? total : 1);

    _schoolStats = SchoolStats(
      schoolId: student.schoolId,
      totalStudents: total,
      highRiskCount: high,
      mediumRiskCount: med,
      lowRiskCount: low,
      averageRiskScore: double.parse(avgRisk.toStringAsFixed(2)),
      averageAttendanceRate: _schoolStats?.averageAttendanceRate ?? 83.5,
      averageGpa: _schoolStats?.averageGpa ?? 2.85,
      classStats: _schoolStats?.classStats ?? {},
      lastCalculated: DateTime.now(),
    );

    notifyListeners();
  }
}
