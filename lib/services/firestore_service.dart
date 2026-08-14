import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/school.dart';
import '../models/student.dart';
import '../models/attendance_record.dart';
import '../models/academic_record.dart';
import '../models/dropout_prediction.dart';
import '../models/school_stats.dart';
import '../models/intervention_recommendation.dart';
import 'mock_data_generator.dart';
import 'xgboost_inference_service.dart';

class FirestoreService {
  FirebaseFirestore? get _db {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance;
      }
    } catch (e) {
      debugPrint("Firestore instance getter notice: $e");
    }
    return null;
  }

  // Get School Profile
  Future<School> getSchool(String schoolId) async {
    final db = _db;
    if (db == null) return MockDataGenerator.getDemoSchool();
    try {
      final doc = await db.collection('schools').doc(schoolId).get();
      if (doc.exists && doc.data() != null) {
        return School.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      debugPrint("Firestore getSchool error: $e");
    }
    return MockDataGenerator.getDemoSchool();
  }

  // Get Aggregated School Stats
  Stream<SchoolStats> streamSchoolStats(String schoolId) async* {
    final db = _db;
    if (db == null) {
      yield MockDataGenerator.getDemoStats();
      return;
    }
    try {
      yield* db
          .collection('school_stats')
          .doc(schoolId)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          return SchoolStats.fromMap(snapshot.data()!, snapshot.id);
        }
        return MockDataGenerator.getDemoStats();
      });
    } catch (e) {
      debugPrint("Firestore streamSchoolStats error: $e");
      yield MockDataGenerator.getDemoStats();
    }
  }

  // Real-time Stream of Students from Cloud Firestore
  Stream<List<Student>> streamStudents(String schoolId) async* {
    final db = _db;
    if (db == null) {
      yield MockDataGenerator.getDemoStudents();
      return;
    }
    try {
      yield* db.collection('students').snapshots().map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => Student.fromMap(doc.data(), doc.id))
              .toList();
        }
        return MockDataGenerator.getDemoStudents();
      });
    } catch (e) {
      debugPrint("Firestore streamStudents error: $e");
      yield MockDataGenerator.getDemoStudents();
    }
  }

  // Fetch Students once
  Future<List<Student>> getStudents(String schoolId) async {
    final db = _db;
    if (db == null) return MockDataGenerator.getDemoStudents();
    try {
      final querySnapshot = await db.collection('students').get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs
            .map((doc) => Student.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (e) {
      debugPrint("Firestore getStudents error: $e");
    }
    return MockDataGenerator.getDemoStudents();
  }

  // Add new Student to Cloud Firestore & Automatically Compute XGBoost Prediction
  Future<bool> addStudent(
    Student student, {
    double attendanceRate = 85.0,
    double academicAvg = 75.0,
    int backlogs = 0,
    double assignmentRate = 0.80,
  }) async {
    final db = _db;
    if (db == null) return false;
    try {
      await db.collection('students').doc(student.studentId).set(student.toMap());
      debugPrint("Student ${student.name} saved to Cloud Firestore database.");

      // Automatically evaluate XGBoost Risk Profile and store in Firestore
      final prediction = XGBoostInferenceService.predictStudentDropout(
        student: student,
        attendanceRate: attendanceRate,
        academicAvg: academicAvg,
        backlogs: backlogs,
        assignmentRate: assignmentRate,
      );
      await addDropoutPrediction(prediction);

      return true;
    } catch (e) {
      debugPrint("Error saving student to Firestore: $e");
      return false;
    }
  }

  // Add new Dropout Prediction to Cloud Firestore
  Future<bool> addDropoutPrediction(DropoutPrediction prediction) async {
    final db = _db;
    if (db == null) return false;
    try {
      await db.collection('dropout_predictions').doc(prediction.studentId).set(prediction.toMap());
      debugPrint("Prediction for student ${prediction.studentId} saved to Cloud Firestore.");
      return true;
    } catch (e) {
      debugPrint("Error saving prediction to Firestore: $e");
      return false;
    }
  }

  // Get Dropout Predictions map
  Future<Map<String, DropoutPrediction>> getDropoutPredictions() async {
    final db = _db;
    if (db == null) return MockDataGenerator.getDemoPredictions();
    try {
      final querySnapshot = await db.collection('dropout_predictions').get();
      if (querySnapshot.docs.isNotEmpty) {
        Map<String, DropoutPrediction> map = {};
        for (var doc in querySnapshot.docs) {
          map[doc.id] = DropoutPrediction.fromMap(doc.data(), doc.id);
        }
        return map;
      }
    } catch (e) {
      debugPrint("Firestore getDropoutPredictions error: $e");
    }
    return MockDataGenerator.getDemoPredictions();
  }

  // Real-time Stream of Dropout Predictions
  Stream<Map<String, DropoutPrediction>> streamDropoutPredictions() async* {
    final db = _db;
    if (db == null) {
      yield MockDataGenerator.getDemoPredictions();
      return;
    }
    try {
      yield* db.collection('dropout_predictions').snapshots().map((snapshot) {
        Map<String, DropoutPrediction> map = {};
        for (var doc in snapshot.docs) {
          map[doc.id] = DropoutPrediction.fromMap(doc.data(), doc.id);
        }
        return map;
      });
    } catch (e) {
      debugPrint("Firestore streamDropoutPredictions error: $e");
      yield MockDataGenerator.getDemoPredictions();
    }
  }

  // Real-time Stream of Recommendations
  Stream<List<InterventionRecommendation>> streamRecommendations() async* {
    final db = _db;
    if (db == null) {
      yield MockDataGenerator.getDemoRecommendations();
      return;
    }
    try {
      yield* db.collection('intervention_recommendations').snapshots().map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => InterventionRecommendation.fromMap(doc.data(), doc.id))
              .toList();
        }
        return MockDataGenerator.getDemoRecommendations();
      });
    } catch (e) {
      debugPrint("Firestore streamRecommendations error: $e");
      yield MockDataGenerator.getDemoRecommendations();
    }
  }

  // Update Principal Intervention Notes & Status
  Future<bool> updateInterventionNotes(
      String studentId, String notes, String status) async {
    final db = _db;
    if (db == null) return false;
    try {
      await db.collection('dropout_predictions').doc(studentId).set({
        'principalNotes': notes,
        'interventionStatus': status,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint("Error updating intervention notes: $e");
      return false;
    }
  }

  // Add Support Intervention Recommendation to Cloud Firestore
  Future<bool> addInterventionRecommendation(InterventionRecommendation rec) async {
    final db = _db;
    if (db == null) return false;
    try {
      await db.collection('intervention_recommendations').doc(rec.recommendationId).set(rec.toMap());
      debugPrint("Support request for ${rec.studentName} saved to Cloud Firestore.");
      return true;
    } catch (e) {
      debugPrint("Error saving recommendation to Firestore: $e");
      return false;
    }
  }

  // Update Recommendation Status in Cloud Firestore
  Future<bool> updateRecommendationStatus(String recId, String status, {String? principalNotes, String? municipalityNotes}) async {
    final db = _db;
    if (db == null) return false;
    try {
      Map<String, dynamic> data = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (principalNotes != null) data['principalNotes'] = principalNotes;
      if (municipalityNotes != null) data['municipalityNotes'] = municipalityNotes;

      await db.collection('intervention_recommendations').doc(recId).set(data, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint("Error updating recommendation status: $e");
      return false;
    }
  }

  // Attendance Records history for student
  Future<List<AttendanceRecord>> getStudentAttendanceHistory(
      String studentId) async {
    final db = _db;
    if (db == null) return MockDataGenerator.getDemoAttendanceHistory(studentId);
    try {
      final querySnapshot = await db
          .collection('attendance_records')
          .where('studentId', isEqualTo: studentId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs
            .map((doc) => AttendanceRecord.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (e) {
      debugPrint("Firestore getAttendance error: $e");
    }
    return MockDataGenerator.getDemoAttendanceHistory(studentId);
  }

  // Academic Records history for student
  Future<List<AcademicRecord>> getStudentAcademicHistory(
      String studentId) async {
    final db = _db;
    if (db == null) return MockDataGenerator.getDemoAcademicHistory(studentId);
    try {
      final querySnapshot = await db
          .collection('academic_records')
          .where('studentId', isEqualTo: studentId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs
            .map((doc) => AcademicRecord.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (e) {
      debugPrint("Firestore getAcademic error: $e");
    }
    return MockDataGenerator.getDemoAcademicHistory(studentId);
  }

  // 1-Click Firestore Seed Utility
  Future<void> seedDemoDataToFirestore() async {
    final db = _db;
    if (db == null) return;
    try {
      final school = MockDataGenerator.getDemoSchool();
      await db.collection('schools').doc(school.schoolId).set(school.toMap());

      final headmaster = MockDataGenerator.getDemoHeadmaster();
      await db.collection('users').doc(headmaster.userId).set(headmaster.toMap());

      final students = MockDataGenerator.getDemoStudents();
      for (var s in students) {
        await db.collection('students').doc(s.studentId).set(s.toMap());
      }

      final predictions = MockDataGenerator.getDemoPredictions();
      for (var entry in predictions.entries) {
        await db
            .collection('dropout_predictions')
            .doc(entry.key)
            .set(entry.value.toMap());
      }

      final stats = MockDataGenerator.getDemoStats();
      await db
          .collection('school_stats')
          .doc(stats.schoolId)
          .set(stats.toMap());

      final recs = MockDataGenerator.getDemoRecommendations();
      for (var r in recs) {
        await db.collection('intervention_recommendations').doc(r.recommendationId).set(r.toMap());
      }

      debugPrint("Cloud Firestore seeded successfully!");
    } catch (e) {
      debugPrint("Error seeding Firestore: $e");
    }
  }
}
