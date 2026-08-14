import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../models/attendance_record.dart';
import '../models/academic_record.dart';

class AttendanceTrendChart extends StatelessWidget {
  final List<AttendanceRecord> attendanceRecords;

  const AttendanceTrendChart({super.key, required this.attendanceRecords});

  @override
  Widget build(BuildContext context) {
    final sorted = List<AttendanceRecord>.from(attendanceRecords)
      ..sort((a, b) => a.date.compareTo(b.date));

    List<FlSpot> spots = [];
    int runningPresent = 0;
    for (int i = 0; i < sorted.length; i++) {
      if (sorted[i].present) runningPresent++;
      double cumulativePct = (runningPresent / (i + 1)) * 100;
      spots.add(FlSpot(i.toDouble(), cumulativePct));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "30-Day Cumulative Attendance Trend",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (spots.isNotEmpty)
                Text(
                  "Current: ${spots.last.y.toStringAsFixed(1)}%",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryTeal,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: spots.isEmpty
                ? const Center(child: Text("No attendance records logged yet"))
                : LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 100,
                      gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppTheme.border,
                          strokeWidth: 1,
                          dashArray: [3, 3],
                        ),
                        drawVerticalLine: false,
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (val, meta) => Text(
                              '${val.toInt()}%',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: (spots.length / 4).clamp(1.0, 10.0),
                            getTitlesWidget: (val, meta) {
                              int idx = val.toInt();
                              if (idx >= 0 && idx < sorted.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    DateFormat('dd/MM').format(sorted[idx].date),
                                    style: const TextStyle(
                                        color: AppTheme.textMuted, fontSize: 10),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: AppTheme.secondaryTeal,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.secondaryTeal.withOpacity(0.12),
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

class AcademicGpaBarChart extends StatelessWidget {
  final List<AcademicRecord> academicRecords;

  const AcademicGpaBarChart({super.key, required this.academicRecords});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Academic Performance (GPA per Term)",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: academicRecords.isEmpty
                ? const Center(child: Text("No academic records logged"))
                : BarChart(
                    BarChartData(
                      maxY: 4.0,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (v) => FlLine(
                          color: AppTheme.border,
                          strokeWidth: 1,
                          dashArray: [3, 3],
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (v, meta) => Text(
                              v.toStringAsFixed(1),
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, meta) {
                              int idx = v.toInt();
                              if (idx >= 0 && idx < academicRecords.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    academicRecords[idx].term,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: academicRecords.asMap().entries.map((e) {
                        int idx = e.key;
                        var rec = e.value;
                        Color barCol = rec.gpa < 2.0
                            ? AppTheme.riskHighText
                            : (rec.gpa < 3.0
                                ? AppTheme.riskMediumText
                                : AppTheme.riskLowText);
                        return BarChartGroupData(
                          x: idx,
                          barRods: [
                            BarChartRodData(
                              toY: rec.gpa,
                              color: barCol,
                              width: 24,
                              borderRadius:
                                  const BorderRadius.vertical(top: Radius.circular(6)),
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
