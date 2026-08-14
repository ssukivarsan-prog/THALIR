import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/school.dart';
import '../models/student.dart';
import '../models/dropout_prediction.dart';
import '../models/school_stats.dart';

class ReportExportService {
  // Generate & Download CSV Summary
  static void exportToCsv({
    required School school,
    required List<Student> students,
    required Map<String, DropoutPrediction> predictions,
    String? selectedClass,
  }) {
    final filteredStudents =
        selectedClass != null && selectedClass != 'All Classes'
        ? students.where((s) => s.classId == selectedClass).toList()
        : students;

    List<List<dynamic>> csvData = [
      [
        'Student ID',
        'Roll Number',
        'Student Name',
        'Class/Grade',
        'Gender',
        'Risk Level',
        'Risk Score (0-1)',
        'Intervention Status',
        'Primary Predictive Factor',
        'Guardian Contact',
      ],
    ];

    for (var s in filteredStudents) {
      final p = predictions[s.studentId];
      final riskLabel = (p?.riskLabel ?? 'low').toUpperCase();
      final riskScore = p != null
          ? (p.riskScore * 100).toStringAsFixed(1) + '%'
          : 'N/A';
      final status = p?.interventionStatus ?? 'None';
      final topFactor = p != null && p.topFactors.isNotEmpty
          ? p.topFactors.first.plainTextDescription
          : 'None';

      csvData.add([
        s.studentId,
        s.rollNumber,
        s.name,
        s.classId,
        s.gender,
        riskLabel,
        riskScore,
        status,
        topFactor,
        s.guardianContact,
      ]);
    }

    String csvString = const ListToCsvConverter().convert(csvData);
    final bytes = utf8.encode(csvString);
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download =
          '${school.name.replaceAll(' ', '_')}_Dropout_Risk_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';

    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  // Generate & Preview/Download PDF Report
  static Future<void> generatePdfReport({
    required School school,
    required SchoolStats stats,
    required List<Student> students,
    required Map<String, DropoutPrediction> predictions,
    String? selectedClass,
  }) async {
    final pdf = pw.Document();
    final nowStr = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    final filteredStudents =
        selectedClass != null && selectedClass != 'All Classes'
        ? students.where((s) => s.classId == selectedClass).toList()
        : students;

    // Filter high and medium risk for focus section
    final atRiskList = filteredStudents.where((s) {
      final p = predictions[s.studentId];
      return p != null && (p.riskLabel == 'high' || p.riskLabel == 'medium');
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 20),
          child: pw.Text(
            'CONFIDENTIAL — SCHOOL HEAD OFFICE REPORT',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey600,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        footer: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'THALIR — Student Retention Platform | Scoped to Headmaster View',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey500,
                ),
              ),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey500,
                ),
              ),
            ],
          ),
        ),
        build: (context) => [
          // Header Banner
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#0F172A'),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  school.name,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'THALIR (தளீர்) — Student Retention & Support Summary Report',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.teal200,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Generated: $nowStr',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey300,
                      ),
                    ),
                    pw.Text(
                      'Scope: ${selectedClass ?? "School-Wide (All Classes)"}',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Overview Summary Cards
          pw.Row(
            children: [
              _pdfStatBox(
                'Total Enrolled',
                '${stats.totalStudents}',
                PdfColors.grey800,
              ),
              pw.SizedBox(width: 12),
              _pdfStatBox(
                'High Risk',
                '${stats.highRiskCount}',
                PdfColors.red700,
              ),
              pw.SizedBox(width: 12),
              _pdfStatBox(
                'Medium Risk',
                '${stats.mediumRiskCount}',
                PdfColors.orange700,
              ),
              pw.SizedBox(width: 12),
              _pdfStatBox(
                'Low Risk',
                '${stats.lowRiskCount}',
                PdfColors.green700,
              ),
            ],
          ),

          pw.SizedBox(height: 24),

          // Section Title: At-Risk Students Requiring Intervention
          pw.Text(
            'Students Requiring Priority Intervention (${atRiskList.length})',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#0F172A'),
            ),
          ),
          pw.SizedBox(height: 8),

          // Table of At-Risk Students
          pw.TableHelper.fromTextArray(
            headers: [
              'Roll No',
              'Student Name',
              'Class',
              'Risk Band',
              'Risk Score',
              'Primary Risk Driver (SHAP)',
              'Status',
            ],
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#1E293B'),
            ),
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
            cellStyle: const pw.TextStyle(fontSize: 8.5),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 6,
            ),
            data: atRiskList.map((s) {
              final p = predictions[s.studentId];
              final riskLabel = (p?.riskLabel ?? 'low').toUpperCase();
              final riskScoreStr = p != null
                  ? '${(p.riskScore * 100).toStringAsFixed(0)}%'
                  : 'N/A';
              final topFactor = p != null && p.topFactors.isNotEmpty
                  ? p.topFactors.first.plainTextDescription
                  : 'N/A';
              final status = p?.interventionStatus ?? 'Pending';

              return [
                s.rollNumber,
                s.name,
                s.classId,
                riskLabel,
                riskScoreStr,
                topFactor,
                status,
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 30),

          // Sign-off signature block for Headmaster
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Report Compiled By:',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Container(width: 150, height: 1, color: PdfColors.grey400),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Headmaster / Principal Signature',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Submitted to Municipal Office:',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Container(width: 150, height: 1, color: PdfColors.grey400),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Date & Received Stamp',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Dropout_Risk_Report_${school.name.replaceAll(' ', '_')}.pdf',
    );
  }

  static pw.Widget _pdfStatBox(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(6),
          color: PdfColors.grey100,
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
