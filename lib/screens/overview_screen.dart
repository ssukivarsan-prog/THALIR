import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/risk_badge.dart';
import '../widgets/risk_trend_chart.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final stats = provider.schoolStats;

    if (provider.isLoading || stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final highRiskPct = stats.totalStudents > 0
        ? (stats.highRiskCount / stats.totalStudents * 100).toStringAsFixed(1)
        : "0.0";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Banner
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "School Executive Summary",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Real-time predictive analytics computed by XGBoost & Firestore sync.",
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => provider.setNavIndex(2),
                icon: const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.white),
                label: Text("View ${stats.highRiskCount} High Risk Students",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.riskHighText,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 4 Main Stat Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final double cardWidth = constraints.maxWidth > 1050
                  ? (constraints.maxWidth - 48) / 4
                  : (constraints.maxWidth > 550 ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth);

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: StatCard(
                      title: "TOTAL STUDENTS ENROLLED",
                      value: "${stats.totalStudents}",
                      subtitle: "Across 6 grade sections",
                      icon: Icons.people_alt_outlined,
                      iconBgColor: const Color(0xFFF1F5F9),
                      iconColor: AppTheme.primaryNavy,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: StatCard(
                      title: "HIGH DROPOUT RISK",
                      value: "${stats.highRiskCount}",
                      subtitle: "$highRiskPct% of total enrollment",
                      icon: Icons.warning_rounded,
                      iconBgColor: AppTheme.riskHighBg,
                      iconColor: AppTheme.riskHighText,
                      badgeWidget: const RiskBadge(riskLabel: "high"),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: StatCard(
                      title: "MEDIUM RISK (MONITOR)",
                      value: "${stats.mediumRiskCount}",
                      subtitle: "Requires early academic support",
                      icon: Icons.info_rounded,
                      iconBgColor: AppTheme.riskMediumBg,
                      iconColor: AppTheme.riskMediumText,
                      badgeWidget: const RiskBadge(riskLabel: "medium"),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: StatCard(
                      title: "AVERAGE ATTENDANCE RATE",
                      value: "${stats.averageAttendanceRate}%",
                      subtitle: "Target: >90% school-wide",
                      icon: Icons.fact_check_outlined,
                      iconBgColor: AppTheme.riskLowBg,
                      iconColor: AppTheme.riskLowText,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          // Responsive Charts & Heatmap Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 850;

              final barChart = RiskDistributionBarChart(stats: stats);
              final heatmap = Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Class Risk Heatmap",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "High risk density by class section",
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 16),
                    ...stats.classStats.values.map((cStat) {
                      final pctAtRisk = cStat.totalStudents > 0
                          ? (cStat.highRiskCount / cStat.totalStudents)
                          : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  cStat.classId,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  "${cStat.highRiskCount} High Risk (${(pctAtRisk * 100).toStringAsFixed(0)}%)",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: cStat.highRiskCount > 1
                                        ? AppTheme.riskHighText
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pctAtRisk,
                                minHeight: 6,
                                backgroundColor: AppTheme.border,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  cStat.highRiskCount > 1
                                      ? AppTheme.riskHighText
                                      : AppTheme.secondaryTeal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: barChart),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: heatmap),
                  ],
                );
              } else {
                return Column(
                  children: [
                    barChart,
                    const SizedBox(height: 20),
                    heatmap,
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 28),

          // High Priority Action List
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.priority_high_rounded, color: AppTheme.riskHighText, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Top At-Risk Students Requiring Headmaster Action",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => provider.setNavIndex(2),
                      child: const Text("See All Students →"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.filteredStudents.take(5).length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final student = provider.filteredStudents[index];
                    final pred = provider.predictions[student.studentId];
                    final topFactor = pred != null && pred.topFactors.isNotEmpty
                        ? pred.topFactors.first.plainTextDescription
                        : "Attendance or academic decline flagged.";

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.surfaceSubtle,
                        child: Text(
                          student.name.isNotEmpty ? student.name[0] : 'S',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ),
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          Text(
                            student.name,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          Text(
                            "(${student.rollNumber})",
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          ),
                          RiskBadge(
                            riskLabel: pred?.riskLabel ?? 'low',
                            riskScore: pred?.riskScore,
                            showScore: true,
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "Primary Factor: $topFactor",
                          style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                        ),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => provider.selectStudent(student),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.surfaceSubtle,
                          foregroundColor: AppTheme.primaryNavy,
                          elevation: 0,
                        ),
                        child: const Text("Student Profile"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
