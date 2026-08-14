import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/risk_badge.dart';

class MunicipalityOverviewScreen extends StatelessWidget {
  const MunicipalityOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final schools = provider.municipalitySchools;
    final recommendations = provider.recommendations;

    final pendingEndorsementCount = recommendations
        .where((r) => r.status.contains('Approved by Principal'))
        .length;

    final totalDispatchedCount = recommendations
        .where((r) => r.status.contains('Municipality Endorsed'))
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Title Bar
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
                    "Chennai Municipal Corporation — Education Directorate",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "City-wide AI student dropout surveillance, school health matrix, and 4-pillar support pipeline.",
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => provider.setNavIndex(3), // Jump to Endorsements
                icon: const Icon(Icons.approval_rounded, size: 16, color: Colors.white),
                label: Text(
                  "$pendingEndorsementCount Pending Endorsements Requiring Action",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 4 Main City Stat Cards
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
                    child: const StatCard(
                      title: "CITY SCHOOLS MONITORED",
                      value: "4 Schools",
                      subtitle: "Chennai Municipal Corporation",
                      icon: Icons.domain_rounded,
                      iconBgColor: Color(0xFFEFF6FF),
                      iconColor: Color(0xFF2563EB),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: const StatCard(
                      title: "TOTAL CITY ENROLLMENT",
                      value: "1,044 Students",
                      subtitle: "SSLC 10th & HSC 12th Board",
                      icon: Icons.groups_rounded,
                      iconBgColor: AppTheme.surfaceSubtle,
                      iconColor: AppTheme.primaryNavy,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: StatCard(
                      title: "PENDING MUNICIPAL ENDORSEMENTS",
                      value: "$pendingEndorsementCount Requests",
                      subtitle: "Scholarships, Hostels, Sports",
                      icon: Icons.pending_actions_rounded,
                      iconBgColor: AppTheme.riskHighBg,
                      iconColor: AppTheme.riskHighText,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: StatCard(
                      title: "DISPATCHED TO FOUNDATIONS",
                      value: "$totalDispatchedCount Approved",
                      subtitle: "Agaram, Govt Hostels & SDAT",
                      icon: Icons.task_alt_rounded,
                      iconBgColor: AppTheme.riskLowBg,
                      iconColor: AppTheme.riskLowText,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          // All Schools Comparative Health Matrix Table
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "City Schools Comparative Dropout Risk & Support Matrix",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Monitor high risk density and endorsement requests across all municipal schools.",
                          style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppTheme.surfaceSubtle),
                    columnSpacing: 28,
                    columns: const [
                      DataColumn(label: Text("School Name & Zone")),
                      DataColumn(label: Text("Headmaster / Principal")),
                      DataColumn(label: Text("Enrollment")),
                      DataColumn(label: Text("High Risk Rate %")),
                      DataColumn(label: Text("Avg Attendance")),
                      DataColumn(label: Text("Pending Endorsements")),
                      DataColumn(label: Text("Action")),
                    ],
                    rows: schools.map((sch) {
                      final schoolRecs = recommendations
                          .where((r) => r.schoolId == sch.schoolId && r.status.contains('Approved by Principal'))
                          .length;

                      final isGreenwood = sch.schoolId == provider.school?.schoolId;
                      final riskPct = isGreenwood ? "31.3%" : (sch.schoolId.contains('tnagar') ? "18.5%" : "22.0%");
                      final principalName = isGreenwood
                          ? "Dr. Eleanor Vance"
                          : (sch.schoolId.contains('tnagar')
                              ? "Thiru R. Soundararajan"
                              : (sch.schoolId.contains('girls') ? "Dr. K. Meenakshi" : "Fr. S. Antony"));

                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                const Icon(Icons.school_rounded, color: AppTheme.secondaryTeal, size: 20),
                                const SizedBox(width: 10),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(sch.name,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                                    Text(sch.address,
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text(principalName)),
                          DataCell(Text(isGreenwood ? "261 Students" : "261 Students")),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isGreenwood ? AppTheme.riskHighBg : AppTheme.surfaceSubtle,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                riskPct,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isGreenwood ? AppTheme.riskHighText : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(isGreenwood ? "83.5%" : "88.0%")),
                          DataCell(
                            Text(
                              "$schoolRecs Pending",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: schoolRecs > 0 ? AppTheme.primaryNavy : AppTheme.textMuted,
                              ),
                            ),
                          ),
                          DataCell(
                            OutlinedButton(
                              onPressed: () {
                                provider.setMunicipalitySchoolId(sch.schoolId);
                                provider.setNavIndex(3); // Jump to Endorsements tab
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.border),
                              ),
                              child: const Text("Review Support Requests", style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
