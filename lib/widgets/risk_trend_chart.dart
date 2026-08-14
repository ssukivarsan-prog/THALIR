import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../app_theme.dart';
import '../models/school_stats.dart';

class RiskDistributionBarChart extends StatelessWidget {
  final SchoolStats stats;

  const RiskDistributionBarChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final double maxVal = [
      stats.highRiskCount.toDouble(),
      stats.mediumRiskCount.toDouble(),
      stats.lowRiskCount.toDouble(),
      10.0
    ].reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 1),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "School-Wide Dropout Risk Breakdown",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                "Live Firestore Aggregate",
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AppTheme.primaryNavy,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String label = groupIndex == 0
                          ? "High Risk"
                          : (groupIndex == 1 ? "Medium Risk" : "Low Risk");
                      return BarTooltipItem(
                        '$label: ${rod.toY.round()} Students',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text("High Risk",
                                  style: TextStyle(
                                      color: AppTheme.riskHighText,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            );
                          case 1:
                            return const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text("Medium Risk",
                                  style: TextStyle(
                                      color: AppTheme.riskMediumText,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            );
                          case 2:
                            return const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text("Low Risk",
                                  style: TextStyle(
                                      color: AppTheme.riskLowText,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            );
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppTheme.border,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: stats.highRiskCount.toDouble(),
                        color: AppTheme.riskHighText,
                        width: 32,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: stats.mediumRiskCount.toDouble(),
                        color: AppTheme.riskMediumText,
                        width: 32,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: stats.lowRiskCount.toDouble(),
                        color: AppTheme.riskLowText,
                        width: 32,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ],
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
