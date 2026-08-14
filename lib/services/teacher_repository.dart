import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/student_model.dart';
import '../models/ocr_model.dart';
import '../models/activity_model.dart';
import '../models/meeting_brief_model.dart';
import '../models/teacher_model.dart';
import 'ocr_parser_service.dart';

class TeacherRepository extends ChangeNotifier {
  late final FirebaseFirestore _db;
  late final FirebaseStorage _storage;
  bool _firestoreInitialized = false;

  // Teacher profile state
  final TeacherProfile _teacher = TeacherProfile(
    id: 'T-1082',
    name: 'Ananya Sharma',
    email: 'ananya.sharma@school.edu',
    schoolName: 'St. Xavier Model Higher Secondary School',
    subjects: ['Mathematics', 'Science', 'Computer Skills'],
    assignedClasses: ['VIII-A', 'VIII-B'],
    activeClass: 'VIII-A',
  );

  bool _isOnline = true;
  int _pendingSyncCount = 0;

  TeacherProfile get teacher => _teacher;
  bool get isOnline => _isOnline;
  int get pendingSyncCount => _pendingSyncCount;

  List<Student> _students = [];
  List<OcrScanRecord> _ocrHistory = [];
  List<MeetingRecord> _upcomingMeetings = [];
  
  // Aligned database structures
  Map<String, DropoutPrediction> _predictions = {};
  List<InterventionRecommendation> _recommendations = [];

  bool _matchClass(String classId, String activeClass) {
    String clean(String s) {
      var val = s.toLowerCase().replaceAll(RegExp(r'\s+|-|grade|class|standard'), '');
      val = val.replaceAll('viii', '8');
      val = val.replaceAll('vii', '7');
      val = val.replaceAll('iii', '3');
      val = val.replaceAll('ix', '9');
      val = val.replaceAll('iv', '4');
      val = val.replaceAll('vi', '6');
      val = val.replaceAll('v', '5');
      val = val.replaceAll('x', '10');
      val = val.replaceAll('ii', '2');
      val = val.replaceAll('i', '1');
      return val;
    }
    
    final c1 = clean(classId);
    final c2 = clean(activeClass);
    return c1 == c2 || c1.contains(c2) || c2.contains(c1);
  }

  List<Student> get students => _students.where((s) => _matchClass(s.classId, _teacher.activeClass)).toList();
  List<Student> get allStudents => List.unmodifiable(_students);
  List<OcrScanRecord> get ocrHistory => List.unmodifiable(_ocrHistory);
  List<MeetingRecord> get upcomingMeetings => List.unmodifiable(_upcomingMeetings);
  List<InterventionRecommendation> get recommendations => List.unmodifiable(_recommendations);

  TeacherRepository() {
    _initFirestore();
  }

  void _initFirestore() async {
    // Check if we are running in a test environment to prevent Firebase crash
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      _seedLocalData();
      return;
    }

    try {
      _db = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      _firestoreInitialized = true;

      // Enable offline persistence (Firestore handles local cache automatically!)
      try {
        _db.settings = const Settings(persistenceEnabled: true);
      } catch (_) {}

      // Check if seeding is required (if students collection is empty)
      try {
        final snap = await _db.collection('students').limit(1).get();
        if (snap.docs.isEmpty) {
          await _seedFirestoreData();
        }
      } catch (e) {
        debugPrint("Firestore seeding check error: $e");
      }

      // 1. Set up real-time listener for students
      _db.collection('students').snapshots().listen((snap) {
        _students = snap.docs.map((doc) => Student.fromJson(doc.data())).toList();
        _mergePredictions();
        notifyListeners();
      }, onError: (e) => debugPrint("Firestore students stream error: $e"));

      // 2. Set up real-time listener for dropout predictions
      _db.collection('dropout_predictions').snapshots().listen((snap) {
        for (var doc in snap.docs) {
          final pred = DropoutPrediction.fromJson(doc.data());
          _predictions[pred.studentId] = pred;
        }
        _mergePredictions();
        notifyListeners();
      }, onError: (e) => debugPrint("Firestore predictions stream error: $e"));

      // 3. Set up real-time listener for OCR scan history
      _db.collection('ocr_history').snapshots().listen((snap) {
        _ocrHistory = snap.docs.map((doc) => OcrScanRecord.fromJson(doc.data())).toList();
        _ocrHistory.sort((a, b) => b.scanDate.compareTo(a.scanDate));
        notifyListeners();
      }, onError: (e) => debugPrint("Firestore OCR history stream error: $e"));

      // 4. Set up real-time listener for upcoming meetings
      _db.collection('meetings').snapshots().listen((snap) {
        _upcomingMeetings = snap.docs.map((doc) => MeetingRecord.fromJson(doc.data())).toList();
        notifyListeners();
      }, onError: (e) => debugPrint("Firestore meetings stream error: $e"));

      // 5. Set up real-time listener for intervention recommendations (4-pillars)
      _db.collection('intervention_recommendations').snapshots().listen((snap) {
        _recommendations = snap.docs.map((doc) => InterventionRecommendation.fromJson(doc.data())).toList();
        notifyListeners();
      }, onError: (e) => debugPrint("Firestore recommendations stream error: $e"));

    } catch (e) {
      debugPrint("Firebase connection/init failed. Running in offline fallback mode: $e");
      _seedLocalData();
    }
  }

  void _mergePredictions() {
    for (var i = 0; i < _students.length; i++) {
      final s = _students[i];
      final pred = _predictions[s.id];
      if (pred != null) {
        final profile = DropoutRiskProfile(
          riskScore: pred.riskScore * 100, // Scale back to percentage for UI rendering
          riskLevel: _capitalize(pred.riskLabel),
          primaryRiskFactors: pred.topFactors.map((e) => e.plainTextDescription).toList(),
          skippingAnxietySubjects: s.dropoutRiskProfile.skippingAnxietySubjects,
          warningHistory: s.dropoutRiskProfile.warningHistory,
        );
        _students[i] = s.copyWith(dropoutRiskProfile: profile);
      }
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return 'Low';
    return s[0].toUpperCase() + s.substring(1);
  }

  void setActiveClass(String className) {
    _teacher.activeClass = className;
    notifyListeners();
  }

  void toggleOnlineStatus() {
    _isOnline = !_isOnline;
    if (_isOnline && _pendingSyncCount > 0) {
      _pendingSyncCount = 0;
    }
    notifyListeners();
  }

  Student? getStudentById(String id) {
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // Helper method to upload a file to Firebase Storage
  Future<String> uploadMediaFile(String localPath, String storagePath) async {
    if (Platform.environment.containsKey('FLUTTER_TEST') || !_firestoreInitialized) {
      return 'https://example.com/mock-file.jpg';
    }

    try {
      final ref = _storage.ref().child(storagePath);
      final uploadTask = ref.putFile(File(localPath));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Firebase Storage upload error: $e");
      return '';
    }
  }

  // Verify and Save OCR Scan to Firestore
  void saveOcrScan(OcrScanRecord scanRecord) async {
    String publicUrl = scanRecord.previewImageUrl ?? '';
    if (publicUrl.isNotEmpty && !publicUrl.startsWith('http')) {
      publicUrl = await uploadMediaFile(publicUrl, 'ocr_scans/${scanRecord.id}.jpg');
    }

    final updatedRows = scanRecord.rows.map((row) => row.copyWith(isConfirmed: true)).toList();
    final verifiedRecord = OcrScanRecord(
      id: scanRecord.id,
      title: scanRecord.title,
      documentType: scanRecord.documentType,
      className: scanRecord.className,
      scanDate: scanRecord.scanDate,
      recordCount: updatedRows.length,
      verificationStatus: 'Verified',
      isSynced: _isOnline,
      rows: updatedRows,
      previewImageUrl: publicUrl,
    );

    // Save OCR scan record
    if (_firestoreInitialized) {
      await _db.collection('ocr_history').doc(verifiedRecord.id).set(verifiedRecord.toJson());
    }

    // Update students based on OCR content
    if (scanRecord.documentType == OcrDocumentType.attendance) {
      final targetClass = scanRecord.className;
      for (var i = 0; i < _students.length; i++) {
        final existing = _students[i];
        if (_matchClass(existing.classId, targetClass)) {
          // Find if this student is present in scanned rows
          final rowIndex = updatedRows.indexWhere((row) =>
              existing.rollNumber == row.rollNumber ||
              existing.name.toLowerCase() == row.studentName.toLowerCase());
          
          final isPresent = rowIndex != -1 && updatedRows[rowIndex].attendanceStatus == 'Present';

          final newAtt = (existing.attendancePercentage * 0.9 + (isPresent ? 100 : 0) * 0.1).clamp(0.0, 100.0);
          final formattedAtt = double.parse(newAtt.toStringAsFixed(1));
          
          final newTimeline = List<TimelineEvent>.from(existing.timeline)
            ..insert(0, TimelineEvent(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: isPresent ? 'Attendance Logged: Present' : 'Attendance Logged: Absent',
              description: isPresent
                  ? 'Marked PRESENT via OCR Attendance Scan.'
                  : 'Marked ABSENT via OCR Attendance Scan (not scanned as present).',
              category: 'attendance',
              date: DateTime.now(),
              badgeIcon: isPresent ? '✓' : '⚠',
            ));

          String newTrend = existing.attendanceTrend;
          if (formattedAtt > existing.attendancePercentage) {
            newTrend = 'improving';
          } else if (formattedAtt < existing.attendancePercentage) {
            newTrend = 'declining';
          } else {
            newTrend = 'stable';
          }

          Student updatedStudent = existing.copyWith(
            attendancePercentage: formattedAtt,
            attendanceTrend: newTrend,
            timeline: newTimeline,
          );

          // Recalculate dynamic dropout risk profile
          final double score = updatedStudent.calculatedDropoutRiskScore;
          final String level = updatedStudent.calculatedDropoutRiskLevel;
          final updatedFactors = <String>[];
          if (updatedStudent.attendancePercentage < 75) {
            updatedFactors.add('Chronic Absenteeism (${updatedStudent.attendancePercentage}%)');
          }
          if (updatedStudent.academicAverage < 60) {
            updatedFactors.add('Failing academic average (${updatedStudent.academicAverage}%)');
          }
          for (var sub in updatedStudent.skippingAnxietySubjects) {
            updatedFactors.add('Class-skipping anxiety: $sub');
          }

          // Scale risk score between 0.0 and 1.0
          final double scaledRiskScore = score / 100.0;

          final prediction = DropoutPrediction(
            studentId: updatedStudent.id,
            riskScore: scaledRiskScore,
            riskLabel: level.toLowerCase(),
            topFactors: updatedFactors.map((f) => DropoutFactor(
              factorName: f.split('(').first.trim(),
              impactLevel: 'high_negative',
              plainTextDescription: f,
              weight: scaledRiskScore,
            )).toList(),
            principalNotes: '',
            interventionStatus: 'Pending Review',
          );

          // Update local memory state instantly for responsive UI
          _predictions[prediction.studentId] = prediction;
          _mergePredictions();

          // Update student profile in students collection (Collection 1)
          if (_firestoreInitialized) {
            await _db.collection('students').doc(updatedStudent.id).set(updatedStudent.toJson());
          } else {
            _students[i] = updatedStudent;
          }
        }
      }
      if (!_firestoreInitialized) {
        notifyListeners();
      }
    } else {
      // Process marks documents
      for (var row in updatedRows) {
        final index = _students.indexWhere((s) => s.rollNumber == row.rollNumber || s.name.toLowerCase() == row.studentName.toLowerCase());
        if (index != -1) {
          final existing = _students[index];
          Student updatedStudent = existing;
          
          if (row.marks != null && row.maxMarks != null) {
            final newMark = SubjectMark(
              subject: row.subject.isNotEmpty ? row.subject : 'Mathematics',
              assessmentName: row.assessmentType,
              marks: row.marks!,
              maxMarks: row.maxMarks!,
              date: DateTime.now(),
            );

            final updatedMarks = List<SubjectMark>.from(existing.recentMarks)..insert(0, newMark);
            final avg = updatedMarks.fold(0.0, (acc, m) => acc + m.percentage) / updatedMarks.length;
            final formattedAvg = double.parse(avg.toStringAsFixed(1));

            final newTimeline = List<TimelineEvent>.from(existing.timeline)
              ..insert(0, TimelineEvent(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: '${row.assessmentType}: ${row.marks!.toInt()}/${row.maxMarks!.toInt()}',
                description: '${row.subject} mark parsed via OCR scanner.',
                category: 'academic',
                date: DateTime.now(),
                badgeIcon: '📚',
              ));

            String newTrend = existing.academicTrend;
            if (formattedAvg > existing.academicAverage) {
              newTrend = 'improving';
            } else if (formattedAvg < existing.academicAverage) {
              newTrend = 'declining';
            } else {
              newTrend = 'stable';
            }

            updatedStudent = existing.copyWith(
              academicAverage: formattedAvg,
              academicTrend: newTrend,
              recentMarks: updatedMarks,
              timeline: newTimeline,
            );

            // Recalculate dynamic dropout risk profile
            final double score = updatedStudent.calculatedDropoutRiskScore;
            final String level = updatedStudent.calculatedDropoutRiskLevel;
            final updatedFactors = <String>[];
            if (updatedStudent.attendancePercentage < 75) {
              updatedFactors.add('Chronic Absenteeism (${updatedStudent.attendancePercentage}%)');
            }
            if (updatedStudent.academicAverage < 60) {
              updatedFactors.add('Failing academic average (${updatedStudent.academicAverage}%)');
            }
            for (var sub in updatedStudent.skippingAnxietySubjects) {
              updatedFactors.add('Class-skipping anxiety: $sub');
            }

            // Scale risk score between 0.0 and 1.0
            final double scaledRiskScore = score / 100.0;

            final prediction = DropoutPrediction(
              studentId: updatedStudent.id,
              riskScore: scaledRiskScore,
              riskLabel: level.toLowerCase(),
              topFactors: updatedFactors.map((f) => DropoutFactor(
                factorName: f.split('(').first.trim(),
                impactLevel: 'high_negative',
                plainTextDescription: f,
                weight: scaledRiskScore,
              )).toList(),
              principalNotes: '',
              interventionStatus: 'Pending Review',
            );

            // Update local memory state instantly for responsive UI
            _predictions[prediction.studentId] = prediction;
            _mergePredictions();

            // Update student profile in students collection (Collection 1)
            if (_firestoreInitialized) {
              await _db.collection('students').doc(updatedStudent.id).set(updatedStudent.toJson());
            } else {
              _students[index] = updatedStudent;
            }
          }
        }
      }
      if (!_firestoreInitialized) {
        notifyListeners();
      }
    }
  }

  // Record classroom Intervention details
  void addStudentIntervention({
    required String studentId,
    required String title,
    required InterventionCategory category,
    required String description,
    required String actionTaken,
    List<String> localAttachmentPaths = const [],
  }) async {
    // Upload attachments
    final List<String> attachmentUrls = [];
    for (var i = 0; i < localAttachmentPaths.length; i++) {
      final path = localAttachmentPaths[i];
      final ext = path.split('.').last;
      final url = await uploadMediaFile(path, 'interventions/${studentId}_${DateTime.now().millisecondsSinceEpoch}_$i.$ext');
      if (url.isNotEmpty) {
        attachmentUrls.add(url);
      }
    }

    final index = _students.indexWhere((s) => s.id == studentId);
    if (index == -1) return;

    final student = _students[index];
    final newIntervention = InterventionRecord(
      id: 'int-${DateTime.now().millisecondsSinceEpoch}',
      studentId: studentId,
      studentName: student.name,
      title: title,
      category: category,
      description: description,
      date: DateTime.now(),
      actionTaken: actionTaken,
      attachmentUrls: attachmentUrls,
    );

    final updatedInterventions = List<InterventionRecord>.from(student.interventions)..insert(0, newIntervention);

    // Boost positive dimensions
    final updatedDimensions = Map<String, double>.from(student.positiveDimensions);
    updatedDimensions['Attendance Cohesion'] = ((updatedDimensions['Attendance Cohesion'] ?? 60.0) + 8.0).clamp(0.0, 100.0);
    updatedDimensions['Academic Growth'] = ((updatedDimensions['Academic Growth'] ?? 60.0) + 4.0).clamp(0.0, 100.0);

    final newTimeline = List<TimelineEvent>.from(student.timeline)
      ..insert(0, TimelineEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Intervention: $title',
        description: '$description - Action: $actionTaken',
        category: 'intervention',
        date: DateTime.now(),
        badgeIcon: '🛡',
      ));

    final updatedStudent = student.copyWith(
      interventions: updatedInterventions,
      positiveDimensions: updatedDimensions,
      timeline: newTimeline,
    );

    // Save updated student to Firestore
    if (_firestoreInitialized) {
      await _db.collection('students').doc(updatedStudent.id).set(updatedStudent.toJson());
    } else {
      _students[index] = updatedStudent;
      notifyListeners();
    }
  }

  // Create municipal 4-Pillar Support Recommendation (Collection 3)
  void addInterventionRecommendation({
    required String studentId,
    required String pillarType,
    required String targetEntity,
    required String reasonNotes,
  }) async {
    final student = getStudentById(studentId);
    if (student == null) return;

    final recId = 'rec-${DateTime.now().millisecondsSinceEpoch}';
    final rec = InterventionRecommendation(
      recommendationId: recId,
      studentId: studentId,
      studentName: student.name,
      schoolId: student.schoolId,
      schoolName: _teacher.schoolName,
      classId: student.classId,
      teacherName: _teacher.name,
      pillarType: pillarType,
      targetEntity: targetEntity,
      reasonNotes: reasonNotes,
      status: 'Pending Principal Review',
      principalNotes: '',
      municipalityNotes: '',
    );

    // Save recommendation
    if (_firestoreInitialized) {
      await _db.collection('intervention_recommendations').doc(rec.recommendationId).set(rec.toJson());
    } else {
      _recommendations.insert(0, rec);
    }

    // Record on student timeline
    final newTimeline = List<TimelineEvent>.from(student.timeline)
      ..insert(0, TimelineEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '4-Pillar Recommended: ${pillarType.replaceAll('_', ' ')}',
        description: 'Target Entity: $targetEntity - reason: $reasonNotes',
        category: 'intervention',
        date: DateTime.now(),
        badgeIcon: '🏛',
      ));

    final updatedStudent = student.copyWith(timeline: newTimeline);
    if (_firestoreInitialized) {
      await _db.collection('students').doc(updatedStudent.id).set(updatedStudent.toJson());
    } else {
      final idx = _students.indexWhere((s) => s.id == updatedStudent.id);
      if (idx != -1) {
        _students[idx] = updatedStudent;
      }
      notifyListeners();
    }
  }

  // Add Observation Note to Firestore
  void addObservation({
    required String studentId,
    required String category,
    required String text,
    bool isVoiceDerived = false,
    String? localAudioPath,
  }) async {
    String? audioUrl;
    if (localAudioPath != null && localAudioPath.isNotEmpty) {
      audioUrl = await uploadMediaFile(localAudioPath, 'observations/${studentId}_${DateTime.now().millisecondsSinceEpoch}.m4a');
    }

    final index = _students.indexWhere((s) => s.id == studentId);
    if (index == -1) return;

    final student = _students[index];
    final obs = TeacherObservation(
      id: 'obs-${DateTime.now().millisecondsSinceEpoch}',
      category: category,
      text: text,
      date: DateTime.now(),
      isVoiceDerived: isVoiceDerived,
      audioUrl: audioUrl,
    );

    final updatedObs = List<TeacherObservation>.from(student.observations)..insert(0, obs);
    final updatedStudent = student.copyWith(observations: updatedObs);

    // Save to Firestore
    if (_firestoreInitialized) {
      await _db.collection('students').doc(updatedStudent.id).set(updatedStudent.toJson());
    } else {
      _students[index] = updatedStudent;
      notifyListeners();
    }
  }

  // Add Meeting Record to Firestore
  void addMeetingRecord(MeetingRecord meeting) async {
    final index = _students.indexWhere((s) => s.id == meeting.studentId);
    if (index != -1) {
      final student = _students[index];
      final updatedMeetings = List<MeetingRecord>.from(student.previousMeetings)..insert(0, meeting);
      final updatedStudent = student.copyWith(previousMeetings: updatedMeetings);
      
      // Save updated student
      if (_firestoreInitialized) {
        await _db.collection('students').doc(updatedStudent.id).set(updatedStudent.toJson());
      } else {
        _students[index] = updatedStudent;
      }
    }

    // Save meeting record
    if (_firestoreInitialized) {
      await _db.collection('meetings').doc(meeting.id).set(meeting.toJson());
    } else {
      _upcomingMeetings.insert(0, meeting);
      notifyListeners();
    }
  }

  // Seeds default Class VIII-A data to Firestore on first setup
  Future<void> _seedFirestoreData() async {
    final now = DateTime.now();

    final arun = Student(
      id: 'std-23VIII001',
      schoolId: 'school-greenwood-01',
      classId: 'VIII-A',
      name: 'Arun Kumar',
      rollNumber: '23VIII001',
      gender: 'Male',
      guardianContact: '+91 98765 43210',
      attendancePercentage: 64.0,
      academicAverage: 52.0,
      attendanceTrend: 'declining',
      academicTrend: 'declining',
      weakSubjects: ['Mathematics', 'Python Programming'],
      skippingAnxietySubjects: ['Mathematics', 'Python Programming'],
      recentMarks: [
        SubjectMark(subject: 'Mathematics', assessmentName: 'Internal 3', marks: 43, maxMarks: 100, date: now.subtract(const Duration(days: 3))),
        SubjectMark(subject: 'Mathematics', assessmentName: 'Internal 2', marks: 61, maxMarks: 100, date: now.subtract(const Duration(days: 15))),
        SubjectMark(subject: 'Mathematics', assessmentName: 'Internal 1', marks: 72, maxMarks: 100, date: now.subtract(const Duration(days: 30))),
        SubjectMark(subject: 'Python Programming', assessmentName: 'Practical Test', marks: 48, maxMarks: 100, date: now.subtract(const Duration(days: 5))),
      ],
      dropoutRiskProfile: DropoutRiskProfile(
        riskScore: 82.0,
        riskLevel: 'High',
        primaryRiskFactors: ['Chronic Absenteeism (64% Attendance)', 'Declining Mathematics grades'],
        skippingAnxietySubjects: ['Mathematics', 'Python Programming'],
        warningHistory: ['Failed Math Assessment 3', 'Missed 4 consecutive days in July', 'Class-skipping anxiety flagged'],
      ),
      positiveDimensions: {
        'Academic Growth': 52.0,
        'Attendance Cohesion': 40.0,
        'Engagement': 45.0,
        'Peer Support': 60.0,
      },
      timeline: [
        TimelineEvent(id: 't1', title: '⚠ Class-Skipping Alert', description: 'Student skipped last two math classes due to test anxiety.', category: 'attendance', date: now.subtract(const Duration(days: 4)), badgeIcon: '⚠'),
        TimelineEvent(id: 't2', title: '📚 Mathematics Internal 3 Result', description: 'Scored 43/100 (Declining trend).', category: 'academic', date: now.subtract(const Duration(days: 14)), badgeIcon: '⚠'),
        TimelineEvent(id: 't3', title: '🛡 Parental Counseling Intervention', description: 'Met parents to outline attendance support guidelines.', category: 'intervention', date: now.subtract(const Duration(days: 25)), badgeIcon: '🌱'),
      ],
      schoolSkippingReasons: [
        'Fear of failing Mathematics assessments',
        'Anxiety about Python programming coding speed',
      ],
      interventions: [
        InterventionRecord(
          id: 'int-1',
          studentId: 'std-23VIII001',
          studentName: 'Arun Kumar',
          title: 'Mathematics Anxiety Counseling',
          category: InterventionCategory.counseling,
          description: 'One-on-one tutorial consultation addressing assessment fear.',
          date: now.subtract(const Duration(days: 4)),
          actionTaken: 'Assigned peer tutor and relaxed homework deadlines.',
        ),
      ],
      observations: [
        TeacherObservation(id: 'o1', category: 'Anxiety Trigger', text: 'Gets visibly overwhelmed during mock math tests and hides in class.', date: now.subtract(const Duration(days: 6))),
        TeacherObservation(id: 'o2', category: 'Academic Struggle', text: 'Requires remedial help in Python syntax definitions.', date: now.subtract(const Duration(days: 10))),
      ],
      previousMeetings: [
        MeetingRecord(
          id: 'm-1',
          studentId: 'std-23VIII001',
          studentName: 'Arun Kumar',
          date: now.subtract(const Duration(days: 7)),
          topic: 'Dropout Risk Consultation: Math & Python anxiety',
          outcome: 'Student confessed that test anxiety makes him skip classes. Agreed to peer support.',
          structuredOutcome: {
            'Anxiety Issue': 'Math class anxiety',
            'Skipping Risk': 'High',
            'Action Plan': 'Relaxed homework deadlines'
          },
          teacherNotes: 'Arun wants to pass, but the pressure triggers avoidance behavior.',
          followUpDate: now.add(const Duration(days: 2)),
          status: 'Scheduled',
        ),
      ],
    );

    final priya = Student(
      id: 'std-23VIII002',
      schoolId: 'school-greenwood-01',
      classId: 'VIII-A',
      name: 'Priya Sharma',
      rollNumber: '23VIII002',
      gender: 'Female',
      guardianContact: '+91 98765 43211',
      attendancePercentage: 94.0,
      academicAverage: 88.5,
      attendanceTrend: 'stable',
      academicTrend: 'improving',
      weakSubjects: [],
      skippingAnxietySubjects: [],
      recentMarks: [
        SubjectMark(subject: 'Mathematics', assessmentName: 'Unit Test 2', marks: 91, maxMarks: 100, date: now.subtract(const Duration(days: 2))),
        SubjectMark(subject: 'Science', assessmentName: 'Half-Yearly Exam', marks: 94, maxMarks: 100, date: now.subtract(const Duration(days: 10))),
      ],
      dropoutRiskProfile: DropoutRiskProfile(
        riskScore: 10.0,
        riskLevel: 'Low',
        primaryRiskFactors: [],
        skippingAnxietySubjects: [],
        warningHistory: [],
      ),
      positiveDimensions: {
        'Academic Growth': 90.0,
        'Attendance Cohesion': 95.0,
        'Engagement': 88.0,
        'Peer Support': 85.0,
      },
      timeline: [],
      schoolSkippingReasons: [],
      interventions: [],
      observations: [
        TeacherObservation(id: 'po1', category: 'Support Action', text: 'Assigned as peer mentor to help struggling students.', date: now.subtract(const Duration(days: 5))),
      ],
      previousMeetings: [],
    );

    final kumar = Student(
      id: 'std-23VIII003',
      schoolId: 'school-greenwood-01',
      classId: 'VIII-A',
      name: 'Kumar Swamy',
      rollNumber: '23VIII003',
      gender: 'Male',
      guardianContact: '+91 98765 43212',
      attendancePercentage: 78.0,
      academicAverage: 62.0,
      attendanceTrend: 'stable',
      academicTrend: 'stable',
      weakSubjects: ['Science'],
      skippingAnxietySubjects: ['Science'],
      recentMarks: [
        SubjectMark(subject: 'Science', assessmentName: 'Half-Yearly Exam', marks: 61, maxMarks: 100, date: now.subtract(const Duration(days: 10))),
      ],
      dropoutRiskProfile: DropoutRiskProfile(
        riskScore: 42.0,
        riskLevel: 'Medium',
        primaryRiskFactors: ['Attendance below 80%', 'Science class formula anxiety'],
        skippingAnxietySubjects: ['Science'],
        warningHistory: ['Absence alert logged in June'],
      ),
      positiveDimensions: {
        'Academic Growth': 60.0,
        'Attendance Cohesion': 75.0,
        'Engagement': 78.0,
        'Peer Support': 70.0,
      },
      timeline: [],
      schoolSkippingReasons: ['Anxiety about Physics formula calculations'],
      interventions: [],
      observations: [],
      previousMeetings: [],
    );

    // Save students to Collection 1
    await _db.collection('students').doc(arun.id).set(arun.toJson());
    await _db.collection('students').doc(priya.id).set(priya.toJson());
    await _db.collection('students').doc(kumar.id).set(kumar.toJson());

    // Save predictions to Collection 2
    final predArun = DropoutPrediction(
      studentId: arun.id,
      riskScore: 0.82,
      riskLabel: 'high',
      topFactors: [
        DropoutFactor(factorName: 'Attendance Deficit', impactLevel: 'high_negative', plainTextDescription: 'Attendance rate dropped to 64%.', weight: 0.82),
        DropoutFactor(factorName: 'Academic Struggle', impactLevel: 'medium_negative', plainTextDescription: 'Failed Mathematics assessment.', weight: 0.50),
      ],
      principalNotes: 'Needs immediate parent contact and counseling.',
      interventionStatus: 'Pending Review',
    );
    final predPriya = DropoutPrediction(
      studentId: priya.id,
      riskScore: 0.10,
      riskLabel: 'low',
      topFactors: [],
      principalNotes: '',
      interventionStatus: 'Resolved',
    );
    final predKumar = DropoutPrediction(
      studentId: kumar.id,
      riskScore: 0.42,
      riskLabel: 'medium',
      topFactors: [
        DropoutFactor(factorName: 'Attendance Decline', impactLevel: 'medium_negative', plainTextDescription: 'Attendance dropped below 80%.', weight: 0.42),
      ],
      principalNotes: '',
      interventionStatus: 'Pending Review',
    );
    await _db.collection('dropout_predictions').doc(predArun.studentId).set(predArun.toJson());
    await _db.collection('dropout_predictions').doc(predPriya.studentId).set(predPriya.toJson());
    await _db.collection('dropout_predictions').doc(predKumar.studentId).set(predKumar.toJson());

    // Save initial intervention recommendations to Collection 3 (4-Pillars)
    final rec = InterventionRecommendation(
      recommendationId: 'rec-101',
      studentId: arun.id,
      studentName: arun.name,
      schoolId: arun.schoolId,
      schoolName: _teacher.schoolName,
      classId: arun.classId,
      teacherName: _teacher.name,
      pillarType: 'subject_coaching',
      targetEntity: 'St. Xavier Morning Tutorial League',
      reasonNotes: 'Requires intensive remedial support in Algebra and Python syntax.',
      status: 'Pending Principal Review',
      principalNotes: '',
      municipalityNotes: '',
    );
    await _db.collection('intervention_recommendations').doc(rec.recommendationId).set(rec.toJson());

    // OCR History Seed
    final ocr1 = OcrScanRecord(
      id: 'ocr-101',
      title: 'VIII-A Mathematics Unit Test 2',
      documentType: OcrDocumentType.classTestMarks,
      className: 'VIII-A',
      scanDate: now.subtract(const Duration(hours: 3)),
      recordCount: 42,
      verificationStatus: 'Verified',
      isSynced: true,
      rows: OcrParserService.parseDocument(type: OcrDocumentType.classTestMarks, className: 'VIII-A'),
    );
    final ocr2 = OcrScanRecord(
      id: 'ocr-102',
      title: 'VIII-A Daily Attendance Register',
      documentType: OcrDocumentType.attendance,
      className: 'VIII-A',
      scanDate: now.subtract(const Duration(days: 1)),
      recordCount: 42,
      verificationStatus: 'Verified',
      isSynced: true,
      rows: OcrParserService.parseDocument(type: OcrDocumentType.attendance, className: 'VIII-A'),
    );
    await _db.collection('ocr_history').doc(ocr1.id).set(ocr1.toJson());
    await _db.collection('ocr_history').doc(ocr2.id).set(ocr2.toJson());

    // Meeting Seed
    final meeting = MeetingRecord(
      id: 'm-101',
      studentId: 'std-23VIII001',
      studentName: 'Arun Kumar',
      date: now.add(const Duration(hours: 2)),
      topic: 'Dropout Prevention Intervention Follow-up',
      outcome: 'Pending intervention',
      structuredOutcome: {},
      teacherNotes: 'Review progress of peer support tutoring plan.',
      followUpDate: now.add(const Duration(hours: 2)),
      status: 'Scheduled',
    );
    await _db.collection('meetings').doc(meeting.id).set(meeting.toJson());
  }

  // Local seed helper for offline widget testing environments
  void _seedLocalData() {
    final now = DateTime.now();
    _students = [
      Student(
        id: 'std-23VIII001',
        schoolId: 'school-greenwood-01',
        classId: 'VIII-A',
        name: 'Arun Kumar',
        rollNumber: '23VIII001',
        gender: 'Male',
        guardianContact: '+91 98765 43210',
        attendancePercentage: 64.0,
        academicAverage: 52.0,
        attendanceTrend: 'declining',
        academicTrend: 'declining',
        weakSubjects: ['Mathematics', 'Python Programming'],
        skippingAnxietySubjects: ['Mathematics', 'Python Programming'],
        recentMarks: [
          SubjectMark(subject: 'Mathematics', assessmentName: 'Internal 3', marks: 43, maxMarks: 100, date: now.subtract(const Duration(days: 3))),
        ],
        dropoutRiskProfile: DropoutRiskProfile(
          riskScore: 82.0,
          riskLevel: 'High',
          primaryRiskFactors: ['Chronic Absenteeism (64% Attendance)'],
          skippingAnxietySubjects: ['Mathematics', 'Python Programming'],
          warningHistory: [],
        ),
        positiveDimensions: {
          'Academic Growth': 52.0,
          'Attendance Cohesion': 40.0,
          'Engagement': 45.0,
          'Peer Support': 60.0,
        },
        timeline: [],
        schoolSkippingReasons: [],
        interventions: [],
        observations: [],
        previousMeetings: [],
      ),
    ];
    _ocrHistory = [];
    _upcomingMeetings = [];
    _recommendations = [];
  }
}
