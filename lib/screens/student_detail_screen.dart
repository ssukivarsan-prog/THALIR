import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/risk_badge.dart';
import '../widgets/shap_factor_card.dart';
import '../widgets/attendance_academic_chart.dart';

class StudentDetailModal extends StatefulWidget {
  const StudentDetailModal({super.key});

  @override
  State<StudentDetailModal> createState() => _StudentDetailModalState();
}

class _StudentDetailModalState extends State<StudentDetailModal> {
  late TextEditingController _notesController;
  String _selectedStatus = "Counseling Scheduled";
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    final student = provider.selectedStudent;
    final pred = student != null ? provider.predictions[student.studentId] : null;

    _notesController = TextEditingController(text: pred?.principalNotes ?? "");
    if (pred?.interventionStatus != null) {
      _selectedStatus = pred!.interventionStatus!;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final student = provider.selectedStudent;

    if (student == null) return const SizedBox.shrink();

    final pred = provider.predictions[student.studentId];
    final riskScorePct = pred != null ? (pred.riskScore * 100).toStringAsFixed(0) : "0";

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          width: 960,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.92,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
            boxShadow: AppTheme.hoverShadow,
          ),
          child: Column(
            children: [
              // Top Header Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceSubtle,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(bottom: BorderSide(color: AppTheme.border)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.primaryNavy,
                      child: Text(
                        student.name.isNotEmpty ? student.name[0] : 'S',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  student.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "(${student.rollNumber})",
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Class: ${student.classId}  |  Father: ${student.fatherName}  |  Mother: ${student.motherName}  |  Phone: ${student.guardianContact}",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    RiskBadge(
                      riskLabel: pred?.riskLabel ?? 'low',
                      riskScore: pred?.riskScore,
                      showScore: true,
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => provider.clearSelectedStudent(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),

              // Modal Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Responsive SHAP & Risk Gauge Section
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 700;

                          final riskGaugeBox = Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceSubtle,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "DROPOUT RISK PROBABILITY",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textMuted,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text(
                                      "$riskScorePct%",
                                      style: TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.w900,
                                        color: pred?.riskLabel == 'high'
                                            ? AppTheme.riskHighText
                                            : (pred?.riskLabel == 'medium'
                                                ? AppTheme.riskMediumText
                                                : AppTheme.riskLowText),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${(pred?.riskLabel ?? 'low').toUpperCase()} RISK CATEGORY",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "Model: ${pred?.modelVersion ?? 'XGBoost v2'}",
                                            style: const TextStyle(
                                                fontSize: 11, color: AppTheme.textMuted),
                                          ),
                                          Text(
                                            "Updated: ${pred != null ? DateFormat('dd MMM, HH:mm').format(pred.lastUpdated) : 'N/A'}",
                                            style: const TextStyle(
                                                fontSize: 11, color: AppTheme.textMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: pred?.riskScore ?? 0.0,
                                    minHeight: 10,
                                    backgroundColor: AppTheme.border,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      pred?.riskLabel == 'high'
                                          ? AppTheme.riskHighText
                                          : (pred?.riskLabel == 'medium'
                                              ? AppTheme.riskMediumText
                                              : AppTheme.riskLowText),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          final shapFactorsBox = Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.psychology_outlined,
                                        color: AppTheme.secondaryTeal, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      "Plain-Language SHAP Risk Factors",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "AI model factors driving dropout risk calculation in order of impact.",
                                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                ),
                                const SizedBox(height: 16),
                                if (pred == null || pred.topFactors.isEmpty)
                                  const Text("No significant negative risk factors detected.")
                                else
                                  ...pred.topFactors
                                      .map((f) => ShapFactorCard(factor: f)),
                              ],
                            ),
                          );

                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 2, child: riskGaugeBox),
                                const SizedBox(width: 20),
                                Expanded(flex: 3, child: shapFactorsBox),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                riskGaugeBox,
                                const SizedBox(height: 20),
                                shapFactorsBox,
                              ],
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 24),

                      // Responsive Trends Charts Section
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 700;
                          final attChart = AttendanceTrendChart(
                            attendanceRecords: provider.selectedStudentAttendance,
                          );
                          final acadChart = AcademicGpaBarChart(
                            academicRecords: provider.selectedStudentAcademics,
                          );

                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: attChart),
                                const SizedBox(width: 20),
                                Expanded(child: acadChart),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                attChart,
                                const SizedBox(height: 20),
                                acadChart,
                              ],
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 24),

                      // Principal Intervention Log & Notes Writer
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSubtle,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.edit_note_rounded,
                                    color: AppTheme.primaryNavy, size: 22),
                                SizedBox(width: 8),
                                Text(
                                  "Headmaster Intervention Log & Notes",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Log actions taken, counselor assignments, parent discussions, or notes back to Firestore.",
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 12,
                              runSpacing: 10,
                              children: [
                                const Text(
                                  "Intervention Status: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppTheme.border),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedStatus,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'Pending Review',
                                            child: Text('Pending Review')),
                                        DropdownMenuItem(
                                            value: 'Under Review', child: Text('Under Review')),
                                        DropdownMenuItem(
                                            value: 'Counseling Scheduled',
                                            child: Text('Counseling Scheduled')),
                                        DropdownMenuItem(
                                            value: 'Action Taken', child: Text('Action Taken')),
                                        DropdownMenuItem(
                                            value: 'Resolved', child: Text('Resolved')),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _selectedStatus = val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: _notesController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText:
                                    "Enter principal intervention notes, meeting summaries, or counselor assignment...",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppTheme.border),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: _isSaving
                                    ? null
                                    : () async {
                                        setState(() => _isSaving = true);
                                        await provider.saveStudentIntervention(
                                          student.studentId,
                                          _notesController.text.trim(),
                                          _selectedStatus,
                                        );
                                        setState(() => _isSaving = false);

                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Intervention notes & status saved to Firestore!"),
                                            backgroundColor: AppTheme.secondaryTeal,
                                          ),
                                        );
                                      },
                                icon: _isSaving
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                            color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.save_rounded, size: 16),
                                label: const Text("Save Annotation to Firestore"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.secondaryTeal,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
