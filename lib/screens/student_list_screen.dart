import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/risk_badge.dart';
import '../widgets/add_student_modal.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final students = provider.filteredStudents;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Filter Action Bar
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Student Roster & Risk Directory",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Showing ${students.length} students across selected filters.",
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),

              // Filter Controls & Add Student Button
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Class Dropdown Filter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: provider.selectedClassFilter,
                        hint: const Text("Filter Class"),
                        items: provider.availableClasses.map((c) {
                          return DropdownMenuItem(value: c, child: Text(c));
                        }).toList(),
                        onChanged: (val) => provider.setClassFilter(val),
                      ),
                    ),
                  ),

                  // Risk Band Dropdown Filter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: provider.selectedRiskFilter,
                        items: const [
                          DropdownMenuItem(
                              value: 'All Risk Levels', child: Text('All Risk Levels')),
                          DropdownMenuItem(
                              value: 'High Risk', child: Text('🔴 High Risk Only')),
                          DropdownMenuItem(
                              value: 'Medium Risk', child: Text('🟡 Medium Risk Only')),
                          DropdownMenuItem(
                              value: 'Low Risk', child: Text('🟢 Low Risk Only')),
                        ],
                        onChanged: (val) => provider.setRiskFilter(val),
                      ),
                    ),
                  ),

                  // Add New Student Button
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const AddStudentModal(),
                      );
                    },
                    icon: const Icon(Icons.person_add_alt_1_rounded,
                        size: 18, color: Colors.white),
                    label: const Text(
                      "Add New Student",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryTeal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Students Roster Table Container with Horizontal Scroll preventing ALL Overflow
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
              boxShadow: AppTheme.softShadow,
            ),
            child: students.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                      child: Text(
                        "No students match the selected filter criteria.",
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppTheme.surfaceSubtle),
                      columnSpacing: 24,
                      dataRowMinHeight: 60,
                      dataRowMaxHeight: 64,
                      columns: const [
                        DataColumn(label: Text("Roll No")),
                        DataColumn(label: Text("Student Name & Guardian")),
                        DataColumn(label: Text("Class / Standard")),
                        DataColumn(label: Text("Gender")),
                        DataColumn(label: Text("Dropout Risk Band")),
                        DataColumn(label: Text("Risk Score")),
                        DataColumn(label: Text("Intervention Status")),
                        DataColumn(label: Text("Action")),
                      ],
                      rows: students.map((student) {
                        final pred = provider.predictions[student.studentId];
                        final riskScorePct = pred != null
                            ? (pred.riskScore * 100).toStringAsFixed(1) + "%"
                            : "N/A";
                        final status = pred?.interventionStatus ?? "Pending Review";

                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                student.rollNumber,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryNavy,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 220,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppTheme.surfaceSubtle,
                                      child: Text(
                                        student.name.isNotEmpty ? student.name[0] : 'S',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryNavy,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13.5,
                                            ),
                                          ),
                                          Text(
                                            student.guardianContact,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  student.classId,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ),
                            DataCell(Text(student.gender)),
                            DataCell(
                              RiskBadge(
                                riskLabel: pred?.riskLabel ?? 'low',
                              ),
                            ),
                            DataCell(
                              Text(
                                riskScorePct,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: pred != null && pred.riskLabel == 'high'
                                      ? AppTheme.riskHighText
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 140,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceSubtle,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    status,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              ElevatedButton(
                                onPressed: () => provider.selectStudent(student),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryNavy,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                ),
                                child: const Text("View Profile",
                                    style: TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
