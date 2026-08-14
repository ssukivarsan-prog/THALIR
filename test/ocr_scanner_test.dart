import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:teacher_assistant_app/models/ocr_model.dart';
import 'package:teacher_assistant_app/services/ocr_parser_service.dart';
import 'package:teacher_assistant_app/services/teacher_repository.dart';
import 'package:teacher_assistant_app/views/screens/ocr_scanner_screen.dart';
import 'package:teacher_assistant_app/views/screens/ocr_verification_screen.dart';

void main() {
  group('OCR Engine & Parser Logic Tests', () {
    test('Attendance sheet extraction correctly parses status and confidence', () {
      final rows = OcrParserService.parseDocument(
        type: OcrDocumentType.attendance,
        className: 'VIII-A',
      );

      expect(rows, isNotEmpty);
      expect(rows.length, equals(6));
      expect(rows.first.rollNumber, equals('23VIII001'));
      expect(rows.first.studentName, equals('Arun Kumar'));
      expect(rows.first.attendanceStatus, equals('Present'));
      expect(rows.first.confidenceScore, equals(0.98));
      expect(rows.first.anomalies, isEmpty);

      // Verify low confidence anomaly detection for row 3 (Kumar Swamy)
      final lowConfRow = rows[2];
      expect(lowConfRow.confidenceScore, equals(0.54));
      expect(lowConfRow.anomalies, contains(OcrAnomalyType.lowConfidence));
    });

    test('Marks sheet extraction detects anomalies like marks exceeding maximum and missing values', () {
      final rows = OcrParserService.parseDocument(
        type: OcrDocumentType.classTestMarks,
        className: 'VIII-A',
      );

      expect(rows.length, equals(5));

      // Sneha Patel row (marks = 105 / 100)
      final rowExceeds = rows.firstWhere((r) => r.rollNumber == '23VIII004');
      expect(rowExceeds.marks, equals(105));
      expect(rowExceeds.anomalies, contains(OcrAnomalyType.marksExceedMax));

      // Rahul Verma row (missing marks)
      final rowMissing = rows.firstWhere((r) => r.rollNumber == '23VIII005');
      expect(rowMissing.marks, isNull);
      expect(rowMissing.anomalies, contains(OcrAnomalyType.missingValue));
    });

    test('OcrParserService.detectAnomalies returns correct flags', () {
      final row = OcrExtractionRow(
        id: 'test-1',
        rollNumber: '23VIII099',
        studentName: 'Test Student',
        subject: 'Math',
        assessmentType: 'Unit Test',
        marks: 110,
        maxMarks: 100,
        attendanceStatus: 'Present',
        date: DateTime.now(),
        confidenceScore: 0.50,
        anomalies: [],
      );

      final anomalies = OcrParserService.detectAnomalies(row);
      expect(anomalies, contains(OcrAnomalyType.lowConfidence));
      expect(anomalies, contains(OcrAnomalyType.marksExceedMax));
    });
  });

  group('OCR Scanner & Verification Widget Tests', () {
    testWidgets('OcrScannerScreen renders camera controls and document auto-classification', (WidgetTester tester) async {
      final repo = TeacherRepository();

      await tester.pumpWidget(
        ChangeNotifierProvider<TeacherRepository>.value(
          value: repo,
          child: const MaterialApp(
            home: OcrScannerScreen(initialTab: 0),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header & auto document classification text
      expect(find.text('📸 OCR Smart Scanner'), findsOneWidget);
      expect(find.textContaining('Attendance Register detected'), findsOneWidget);

      // Switch to Internal Test tab
      await tester.tap(find.text('Internal Test'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Internal Test Sheet detected'), findsOneWidget);
    });

    testWidgets('OcrVerificationScreen renders editable data table and anomaly alerts', (WidgetTester tester) async {
      final repo = TeacherRepository();
      final rows = OcrParserService.parseDocument(
        type: OcrDocumentType.classTestMarks,
        className: 'VIII-A',
      );

      final scanRecord = OcrScanRecord(
        id: 'scan-test',
        title: 'VIII-A Test Scan',
        documentType: OcrDocumentType.classTestMarks,
        className: 'VIII-A',
        scanDate: DateTime.now(),
        recordCount: rows.length,
        verificationStatus: 'Verification Required',
        isSynced: true,
        rows: rows,
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<TeacherRepository>.value(
          value: repo,
          child: MaterialApp(
            home: OcrVerificationScreen(scanRecord: scanRecord),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title & anomaly warning banner
      expect(find.text('Verify Extracted Data'), findsOneWidget);
      expect(find.textContaining('rows need review'), findsOneWidget);

      // Verify student names in data table
      expect(find.text('Arun Kumar'), findsOneWidget);
      expect(find.text('Priya Sharma'), findsOneWidget);
      expect(find.text('Ravi Teja'), findsOneWidget);

      // Verify confirm button
      expect(find.text('Confirm & Save'), findsOneWidget);
    });
  });
}
