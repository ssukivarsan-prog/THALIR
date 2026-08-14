import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/dashboard_provider.dart';
import '../models/school_stats.dart';

class ClassBreakdownScreen extends StatefulWidget {
  const ClassBreakdownScreen({super.key});

  @override
  State<ClassBreakdownScreen> createState() => _ClassBreakdownScreenState();
}

class _ClassBreakdownScreenState extends State<ClassBreakdownScreen> {
  int _sortColumnIndex = 3; // Default sort by Avg Risk Score
  bool _sortAscending = false; // Highest risk first

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final stats = provider.schoolStats;

    if (provider.isLoading || stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    List<ClassStat> classList = stats.classStats.values.toList();

    // Sort logic
    classList.sort((a, b) {
      int comparison = 0;
      switch (_sortColumnIndex) {
        case 0:
          comparison = a.classId.compareTo(b.classId);
          break;
        case 1:
          comparison = a.totalStudents.compareTo(b.totalStudents);
          break;
        case 2:
          comparison = a.highRiskCount.compareTo(b.highRiskCount);
          break;
        case 3:
          comparison = a.avgRiskScore.compareTo(b.avgRiskScore);
          break;
        case 4:
          comparison = a.avgAttendanceRate.compareTo(b.avgAttendanceRate);
          break;
        case 5:
          comparison = a.avgGpa.compareTo(b.avgGpa);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Class-Wise Predictive Risk Breakdown",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Compare academic performance, high risk density, and attendance across grade sections.",
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
              boxShadow: AppTheme.softShadow,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                headingRowColor: WidgetStateProperty.all(AppTheme.surfaceSubtle),
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavy,
                  fontSize: 13,
                ),
                dataRowMinHeight: 52,
                dataRowMaxHeight: 56,
                columns: [
                  DataColumn(
                    label: const Text("Class / Grade Section"),
                    onSort: (idx, asc) => setState(() {
                      _sortColumnIndex = idx;
                      _sortAscending = asc;
                    }),
                  ),
                  DataColumn(
                    label: const Text("Total Students"),
                    numeric: true,
                    onSort: (idx, asc) => setState(() {
                      _sortColumnIndex = idx;
                      _sortAscending = asc;
                    }),
                  ),
                  DataColumn(
                    label: const Text("High Risk Count"),
                    numeric: true,
                    onSort: (idx, asc) => setState(() {
                      _sortColumnIndex = idx;
                      _sortAscending = asc;
                    }),
                  ),
                  DataColumn(
                    label: const Text("Avg Risk Score"),
                    numeric: true,
                    onSort: (idx, asc) => setState(() {
                      _sortColumnIndex = idx;
                      _sortAscending = asc;
                    }),
                  ),
                  DataColumn(
                    label: const Text("Avg Attendance"),
                    numeric: true,
                    onSort: (idx, asc) => setState(() {
                      _sortColumnIndex = idx;
                      _sortAscending = asc;
                    }),
                  ),
                  DataColumn(
                    label: const Text("Avg GPA"),
                    numeric: true,
                    onSort: (idx, asc) => setState(() {
                      _sortColumnIndex = idx;
                      _sortAscending = asc;
                    }),
                  ),
                  const DataColumn(
                    label: Text("Action"),
                  ),
                ],
                rows: classList.map((c) {
                  final pctHighRisk = c.totalStudents > 0
                      ? (c.highRiskCount / c.totalStudents * 100).toStringAsFixed(0)
                      : "0";

                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            const Icon(Icons.school_outlined, size: 18, color: AppTheme.secondaryTeal),
                            const SizedBox(width: 10),
                            Text(
                              c.classId,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text("${c.totalStudents}")),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: c.highRiskCount > 0 ? AppTheme.riskHighBg : AppTheme.surfaceSubtle,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${c.highRiskCount} ($pctHighRisk%)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: c.highRiskCount > 0
                                  ? AppTheme.riskHighText
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          "${(c.avgRiskScore * 100).toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: c.avgRiskScore > 0.35
                                ? AppTheme.riskHighText
                                : (c.avgRiskScore > 0.20
                                    ? AppTheme.riskMediumText
                                    : AppTheme.riskLowText),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          "${c.avgAttendanceRate.toStringAsFixed(1)}%",
                          style: TextStyle(
                            color: c.avgAttendanceRate < 80
                                ? AppTheme.riskHighText
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      DataCell(Text(c.avgGpa.toStringAsFixed(2))),
                      DataCell(
                        OutlinedButton(
                          onPressed: () {
                            provider.setClassFilter(c.classId);
                            provider.setNavIndex(2); // Jump to Student Roster
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            side: const BorderSide(color: AppTheme.border),
                          ),
                          child: const Text("View Class Roster"),
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
