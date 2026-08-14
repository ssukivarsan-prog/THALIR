import '../models/ocr_model.dart';

class OcrParserService {
  /// Generates realistic extracted OCR rows for demo scanning
  static List<OcrExtractionRow> parseDocument({
    required OcrDocumentType type,
    required String className,
  }) {
    final now = DateTime.now();

    if (type == OcrDocumentType.attendance) {
      return [
        OcrExtractionRow(
          id: 'row-1',
          rollNumber: '23VIII001',
          studentName: 'Arun Kumar',
          subject: 'General Attendance',
          assessmentType: 'Daily Roll Call',
          attendanceStatus: 'Present',
          date: now,
          confidenceScore: 0.98,
          anomalies: [],
        ),
        OcrExtractionRow(
          id: 'row-2',
          rollNumber: '23VIII002',
          studentName: 'Priya Sharma',
          subject: 'General Attendance',
          assessmentType: 'Daily Roll Call',
          attendanceStatus: 'Present',
          date: now,
          confidenceScore: 0.96,
          anomalies: [],
        ),
        OcrExtractionRow(
          id: 'row-3',
          rollNumber: '23VIII003',
          studentName: 'Kumar Swamy',
          subject: 'General Attendance',
          assessmentType: 'Daily Roll Call',
          attendanceStatus: 'Absent',
          date: now,
          confidenceScore: 0.54,
          anomalies: [OcrAnomalyType.lowConfidence],
        ),
        OcrExtractionRow(
          id: 'row-4',
          rollNumber: '23VIII004',
          studentName: 'Deepa Raj',
          subject: 'General Attendance',
          assessmentType: 'Daily Roll Call',
          attendanceStatus: 'Present',
          date: now,
          confidenceScore: 0.97,
          anomalies: [],
        ),
        OcrExtractionRow(
          id: 'row-5',
          rollNumber: '23VIII005',
          studentName: 'Ravi Teja',
          subject: 'General Attendance',
          assessmentType: 'Daily Roll Call',
          attendanceStatus: 'Present',
          date: now,
          confidenceScore: 0.95,
          anomalies: [],
        ),
        OcrExtractionRow(
          id: 'row-6',
          rollNumber: '23VIII006',
          studentName: 'Sneha Patel',
          subject: 'General Attendance',
          assessmentType: 'Daily Roll Call',
          attendanceStatus: 'Absent',
          date: now,
          confidenceScore: 0.99,
          anomalies: [],
        ),
      ];
    } else if (type == OcrDocumentType.classTestMarks) {
      return [
        OcrExtractionRow(
          id: 'row-101',
          rollNumber: '23VIII001',
          studentName: 'Arun Kumar',
          subject: 'Mathematics',
          assessmentType: 'Unit Test 2',
          marks: 82,
          maxMarks: 100,
          attendanceStatus: 'Present',
          date: now,
          confidenceScore: 0.98,
          anomalies: [],
        ),
        OcrExtractionRow(
          id: 'row-102',
          rollNumber: '23VIII002',
          studentName: 'Priya Sharma',
          subject: 'Mathematics',
          assessmentType: 'Unit Test 2',
          marks: 91,
          maxMarks: 100,
          attendanceStatus: 'Present',
          date: now,
          confidenceScore: 0.97,
          anomalies: [],
        ),
        OcrExtractionRow(
          id: 'row-103',
          rollNumber: '23VIII003',
          studentName: 'Ravi Teja',
          subject: 'Mathematics',
          assessmentType: 'Unit Test 2',
          marks: 88, // Low confidence extraction (e.g. read as 8?)
          maxMarks: 100,
          attendanceStatus: 'Present',
          date: now,
          confidenceScore: 0.52,
          anomalies: [OcrAnomalyType.lowConfidence],
        ),
        OcrExtractionRow(
          id: 'row-104',
          rollNumber: '23VIII004',
          studentName: 'Sneha Patel',
          subject: 'Mathematics',
          assessmentType: 'Unit Test 2',
          marks: 105, // Anomaly: Marks > maxMarks
          maxMarks: 100,
          attendanceStatus: 'Present',
          date: now,
          confidenceScore: 0.92,
          anomalies: [OcrAnomalyType.marksExceedMax],
        ),
        OcrExtractionRow(
          id: 'row-105',
          rollNumber: '23VIII005',
          studentName: 'Rahul Verma',
          subject: 'Mathematics',
          assessmentType: 'Unit Test 2',
          marks: null, // Anomaly: Missing value
          maxMarks: 100,
          attendanceStatus: 'Present',
          date: now,
          confidenceScore: 0.45,
          anomalies: [OcrAnomalyType.missingValue, OcrAnomalyType.lowConfidence],
        ),
      ];
    } else {
      // Exam Marks
      return [
        OcrExtractionRow(
          id: 'row-201',
          rollNumber: '23VIII001',
          studentName: 'Arun Kumar',
          subject: 'Science',
          assessmentType: 'Half-Yearly Exam',
          marks: 78,
          maxMarks: 100,
          attendanceStatus: 'Present',
          date: now,
          confidenceScore: 0.99,
          anomalies: [],
        ),
        OcrExtractionRow(
          id: 'row-202',
          rollNumber: '23VIII002',
          studentName: 'Priya Sharma',
          subject: 'Science',
          assessmentType: 'Half-Yearly Exam',
          marks: 94,
          maxMarks: 100,
          attendanceStatus: 'Present',
          date: now,
          confidenceScore: 0.98,
          anomalies: [],
        ),
        OcrExtractionRow(
          id: 'row-203',
          rollNumber: '23VIII003',
          studentName: 'Kumar Swamy',
          subject: 'Science',
          assessmentType: 'Half-Yearly Exam',
          marks: 61,
          maxMarks: 100,
          attendanceStatus: 'Present',
          date: now,
          confidenceScore: 0.96,
          anomalies: [],
        ),
      ];
    }
  }

  /// Automatically validates extraction rows for anomalies
  static List<OcrAnomalyType> detectAnomalies(OcrExtractionRow row) {
    final List<OcrAnomalyType> list = [];
    if (row.confidenceScore < 0.70) {
      list.add(OcrAnomalyType.lowConfidence);
    }
    if (row.marks == null && row.attendanceStatus == 'Present') {
      list.add(OcrAnomalyType.missingValue);
    }
    if (row.marks != null && row.maxMarks != null && row.marks! > row.maxMarks!) {
      list.add(OcrAnomalyType.marksExceedMax);
    }
    return list;
  }
}
