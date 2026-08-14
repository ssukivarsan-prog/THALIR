import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/student.dart';
import '../models/dropout_prediction.dart';
import '../providers/dashboard_provider.dart';

class AddStudentModal extends StatefulWidget {
  const AddStudentModal({super.key});

  @override
  State<AddStudentModal> createState() => _AddStudentModalState();
}

class _AddStudentModalState extends State<AddStudentModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollController = TextEditingController();
  final _fatherController = TextEditingController();
  final _motherController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedGrade = "Grade 10";
  String _selectedDivision = "A";
  String _selectedGender = "Male";

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    _fatherController.dispose();
    _motherController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitNewStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = Provider.of<DashboardProvider>(context, listen: false);
    final String classId = "$_selectedGrade-$_selectedDivision";
    final String studentId = "std-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

    final newStudent = Student(
      studentId: studentId,
      schoolId: provider.school?.schoolId ?? "school-greenwood-01",
      classId: classId,
      name: _nameController.text.trim(),
      rollNumber: _rollController.text.trim(),
      gender: _selectedGender,
      fatherName: _fatherController.text.trim().isEmpty ? "N/A" : _fatherController.text.trim(),
      motherName: _motherController.text.trim().isEmpty ? "N/A" : _motherController.text.trim(),
      guardianContact: _phoneController.text.trim().isEmpty
          ? "+91 98765 00000"
          : _phoneController.text.trim(),
    );

    // Baseline prediction state for newly enrolled student:
    // 0.0% Risk (NOT AT RISK) with 0% attendance starting from scratch
    final newPrediction = DropoutPrediction(
      studentId: studentId,
      riskScore: 0.0,
      riskLabel: 'low',
      topFactors: [
        ShapFactor(
          factorName: 'Newly Enrolled Student',
          impactLevel: 'positive',
          plainTextDescription:
              'Newly enrolled student — 0% attendance starting from scratch. Not at risk (Awaiting teacher attendance & marks).',
          weight: 0.0,
        ),
      ],
      lastUpdated: DateTime.now(),
      modelVersion: 'v2.1-XGBoost',
      principalNotes: 'Newly enrolled student. 0% attendance starting from scratch. Not at risk.',
      interventionStatus: 'Resolved',
    );

    await provider.addNewStudent(newStudent, newPrediction);

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Student '${newStudent.name}' enrolled into $classId! (0% Risk — Synced to Teacher App)",
        ),
        backgroundColor: AppTheme.secondaryTeal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            width: 600,
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
              boxShadow: AppTheme.hoverShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modal Header (Overflow fixed using Expanded)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppTheme.border)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.person_add_rounded,
                            color: AppTheme.secondaryTeal, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Enroll New Student to Class Standard",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Register student profile. Attendance & academic marks will be collected by teachers.",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),

                // Modal Form Body
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name & Roll No Row
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Full Student Name *",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _nameController,
                                      validator: (val) =>
                                          val == null || val.trim().isEmpty
                                              ? "Name is required"
                                              : null,
                                      decoration: InputDecoration(
                                        hintText: "e.g. Aarav Sharma",
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Roll Number *",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _rollController,
                                      validator: (val) =>
                                          val == null || val.trim().isEmpty
                                              ? "Required"
                                              : null,
                                      decoration: InputDecoration(
                                        hintText: "e.g. 10A-25",
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Father Name & Mother Name Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Father's Name *",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _fatherController,
                                      validator: (val) =>
                                          val == null || val.trim().isEmpty
                                              ? "Father's name required"
                                              : null,
                                      decoration: InputDecoration(
                                        hintText: "e.g. Ramesh Sharma",
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Mother's Name *",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _motherController,
                                      validator: (val) =>
                                          val == null || val.trim().isEmpty
                                              ? "Mother's name required"
                                              : null,
                                      decoration: InputDecoration(
                                        hintText: "e.g. Sunita Sharma",
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Standard / Division / Gender Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Standard / Grade *",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppTheme.border),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: _selectedGrade,
                                          items: const [
                                            DropdownMenuItem(
                                                value: 'Grade 8', child: Text('Grade 8')),
                                            DropdownMenuItem(
                                                value: 'Grade 9', child: Text('Grade 9')),
                                            DropdownMenuItem(
                                                value: 'Grade 10', child: Text('Grade 10')),
                                            DropdownMenuItem(
                                                value: 'Grade 11', child: Text('Grade 11')),
                                            DropdownMenuItem(
                                                value: 'Grade 12', child: Text('Grade 12')),
                                          ],
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() => _selectedGrade = val);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Division / Section *",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppTheme.border),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: _selectedDivision,
                                          items: const [
                                            DropdownMenuItem(
                                                value: 'A', child: Text('Section A')),
                                            DropdownMenuItem(
                                                value: 'B', child: Text('Section B')),
                                            DropdownMenuItem(
                                                value: 'C', child: Text('Section C')),
                                            DropdownMenuItem(
                                                value: 'D', child: Text('Section D')),
                                          ],
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() => _selectedDivision = val);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Gender *",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppTheme.border),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: _selectedGender,
                                          items: const [
                                            DropdownMenuItem(
                                                value: 'Male', child: Text('Male')),
                                            DropdownMenuItem(
                                                value: 'Female', child: Text('Female')),
                                            DropdownMenuItem(
                                                value: 'Other', child: Text('Other')),
                                          ],
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() => _selectedGender = val);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Parent / Guardian Phone Field
                          const Text("Parent / Guardian Contact Phone *",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _phoneController,
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                    ? "Parent contact phone required"
                                    : null,
                            decoration: InputDecoration(
                              hintText: "e.g. +91 98401 23456",
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _submitNewStudent,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Icon(Icons.check_circle_outline,
                                      size: 18, color: Colors.white),
                              label: const Text(
                                "Enroll Student & Sync to Teacher App",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondaryTeal,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
