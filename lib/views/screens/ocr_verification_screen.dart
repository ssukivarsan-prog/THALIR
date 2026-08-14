import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ocr_model.dart';
import '../../services/teacher_repository.dart';

class OcrVerificationScreen extends StatefulWidget {
  final OcrScanRecord scanRecord;
  final String? capturedImagePath;

  const OcrVerificationScreen({
    super.key,
    required this.scanRecord,
    this.capturedImagePath,
  });

  @override
  State<OcrVerificationScreen> createState() => _OcrVerificationScreenState();
}

class _OcrVerificationScreenState extends State<OcrVerificationScreen> {
  late List<OcrExtractionRow> _rows;
  bool _showPhotoPreview = false;

  @override
  void initState() {
    super.initState();
    _rows = widget.scanRecord.rows.map((r) => r.copyWith()).toList();
    if (widget.capturedImagePath != null) {
      _showPhotoPreview = true;
    }
  }

  int get _anomalyCount => _rows.where((r) => r.anomalies.isNotEmpty).length;

  void _editRow(OcrExtractionRow row, int index) {
    final nameController = TextEditingController(text: row.studentName);
    final rollController = TextEditingController(text: row.rollNumber);
    final marksController = TextEditingController(text: row.marks != null ? row.marks!.toStringAsFixed(0) : '');
    String attendance = row.attendanceStatus;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Extracted Row', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: rollController,
                decoration: const InputDecoration(labelText: 'Roll Number / ID', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Student Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              if (widget.scanRecord.documentType == OcrDocumentType.attendance)
                DropdownButtonFormField<String>(
                  value: attendance,
                  decoration: const InputDecoration(labelText: 'Attendance Status', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Present', child: Text('Present ✓')),
                    DropdownMenuItem(value: 'Absent', child: Text('Absent ⚠')),
                  ],
                  onChanged: (v) {
                    if (v != null) attendance = v;
                  },
                )
              else
                TextField(
                  controller: marksController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Marks Scored', border: OutlineInputBorder()),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
            onPressed: () {
              final double? newMarks = double.tryParse(marksController.text);
              setState(() {
                _rows[index] = _rows[index].copyWith(
                  rollNumber: rollController.text,
                  studentName: nameController.text,
                  marks: newMarks,
                  attendanceStatus: attendance,
                  confidenceScore: 1.0, // Set 100% since teacher verified
                  anomalies: [],
                  isEdited: true,
                );
              });
              Navigator.pop(ctx);
            },
            child: const Text('Update Row'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TeacherRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Extracted Data'),
        actions: [
          if (widget.capturedImagePath != null)
            IconButton(
              icon: Icon(_showPhotoPreview ? Icons.photo : Icons.photo_outlined, color: const Color(0xFF4F46E5)),
              tooltip: _showPhotoPreview ? 'Hide Photo Preview' : 'Show Photo Preview',
              onPressed: () => setState(() => _showPhotoPreview = !_showPhotoPreview),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Rescan Document',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header summary & Anomaly Warning Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: const Color(0xFFEEF2FF),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.scanRecord.documentType == OcrDocumentType.attendance
                            ? 'Attendance Sheet'
                            : 'Marks Sheet',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Class ${widget.scanRecord.className} • ${_rows.length} Extracted Rows',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
                      ),
                    ),
                  ],
                ),
                if (_anomalyCount > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '⚠ $_anomalyCount rows need review (Low OCR confidence / out of range). Please verify values.',
                            style: const TextStyle(color: Color(0xFF92400E), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Captured Photo Split/Collapsible Preview Drawer
          if (_showPhotoPreview && widget.capturedImagePath != null && File(widget.capturedImagePath!).existsSync())
            Container(
              height: 140,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF4F46E5)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.file(
                      File(widget.capturedImagePath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Captured Document Photo', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // OCR Extracted Data Table
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16,
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFEEF2FF)),
                  columns: const [
                    DataColumn(label: Text('Roll No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Extracted Value', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Confidence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                  rows: List.generate(_rows.length, (index) {
                    final row = _rows[index];
                    final isLowConf = row.confidenceScore < 0.70;
                    final hasAnomaly = row.anomalies.isNotEmpty;

                    String valueDisplay = widget.scanRecord.documentType == OcrDocumentType.attendance
                        ? row.attendanceStatus
                        : (row.marks != null ? '${row.marks!.toInt()}/${row.maxMarks?.toInt() ?? 100}' : 'Missing');

                    return DataRow(
                      color: WidgetStateProperty.resolveWith<Color?>((states) {
                        if (hasAnomaly) return const Color(0xFFFEF3C7);
                        if (row.isEdited) return const Color(0xFFEFF6FF);
                        return null;
                      }),
                      cells: [
                        DataCell(Text(row.rollNumber, style: const TextStyle(fontSize: 12))),
                        DataCell(Text(row.studentName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                        DataCell(
                          Row(
                            children: [
                              Text(
                                valueDisplay,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: hasAnomaly ? const Color(0xFFD97706) : null,
                                ),
                              ),
                              if (hasAnomaly)
                                const Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Icon(Icons.error_outline, color: Color(0xFFD97706), size: 14),
                                ),
                            ],
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isLowConf ? const Color(0xFFFEF3C7) : const Color(0xFFCCFBF1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${(row.confidenceScore * 100).toInt()}% ${isLowConf ? '⚠' : '✓'}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isLowConf ? const Color(0xFFD97706) : const Color(0xFF0D9488),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            row.isEdited ? 'Edited' : (hasAnomaly ? 'Verify' : 'OK'),
                            style: TextStyle(
                              fontSize: 11,
                              color: row.isEdited ? const Color(0xFF4F46E5) : (hasAnomaly ? const Color(0xFFD97706) : const Color(0xFF0D9488)),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.edit_note_rounded, size: 20, color: Color(0xFF4F46E5)),
                            onPressed: () => _editRow(row, index),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),

          // Overflow-Safe Bottom Confirmation Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, -2))],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Rescan', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Confirm & Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      onPressed: () {
                        final updatedRecord = OcrScanRecord(
                          id: widget.scanRecord.id,
                          title: widget.scanRecord.title,
                          documentType: widget.scanRecord.documentType,
                          className: widget.scanRecord.className,
                          scanDate: widget.scanRecord.scanDate,
                          recordCount: _rows.length,
                          verificationStatus: 'Verified',
                          isSynced: repo.isOnline,
                          rows: _rows,
                        );
                        repo.saveOcrScan(updatedRecord);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✓ OCR Records verified and saved to student profile!')),
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
