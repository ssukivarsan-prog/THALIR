import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/dashboard_provider.dart';
import '../services/report_export_service.dart';
import '../widgets/add_student_modal.dart';

class HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  const HeaderBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final isMunicipality = provider.activeRole == 'municipality_head';

    final titleText = isMunicipality
        ? "Chennai Municipal Corporation — Education Directorate"
        : (provider.school?.name ?? "St. Xavier Model Higher Secondary School");

    final roleSubtitle = isMunicipality
        ? "Municipality CEO View | 4 City Schools Monitored"
        : "School Principal View | St. Xavier Model School";

    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Title & Subtitle (Auto-truncates cleanly)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isMunicipality ? 14.5 : 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryNavy,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isMunicipality ? AppTheme.primaryNavy : AppTheme.riskLowText,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        roleSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Search Field (Compact 160px width)
          SizedBox(
            width: 160,
            height: 36,
            child: TextField(
              onChanged: (val) => provider.setSearchQuery(val),
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: isMunicipality ? "Search..." : "Search student/roll...",
                hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                prefixIcon: const Icon(Icons.search, size: 15, color: AppTheme.textMuted),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: AppTheme.surfaceSubtle,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.secondaryTeal),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Role Switcher Dropdown
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isMunicipality
                  ? AppTheme.primaryNavy.withOpacity(0.08)
                  : AppTheme.secondaryTeal.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isMunicipality ? AppTheme.primaryNavy : AppTheme.secondaryTeal,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: provider.activeRole,
                icon: Icon(
                  Icons.swap_horiz_rounded,
                  size: 16,
                  color: isMunicipality ? AppTheme.primaryNavy : AppTheme.secondaryTeal,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'principal',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.school, size: 14, color: AppTheme.secondaryTeal),
                        SizedBox(width: 4),
                        Text("Principal View",
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'municipality_head',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_city, size: 14, color: AppTheme.primaryNavy),
                        SizedBox(width: 4),
                        Text("Municipality CEO",
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) provider.setActiveRole(val);
                },
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Add Student Quick Button (Principal view only)
          if (!isMunicipality)
            SizedBox(
              height: 36,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AddStudentModal(),
                  );
                },
                icon: const Icon(Icons.person_add_alt_1, size: 14, color: Colors.white),
                label: const Text("+ Add Student",
                    style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryTeal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),

          if (!isMunicipality) const SizedBox(width: 8),

          // Executive PDF Export Button
          SizedBox(
            height: 36,
            child: ElevatedButton.icon(
              onPressed: () {
                if (provider.school != null && provider.schoolStats != null) {
                  ReportExportService.generatePdfReport(
                    school: provider.school!,
                    stats: provider.schoolStats!,
                    students: provider.students,
                    predictions: provider.predictions,
                  );
                }
              },
              icon: const Icon(Icons.picture_as_pdf, size: 14, color: Colors.white),
              label: const Text("PDF", style: TextStyle(color: Colors.white, fontSize: 11.5)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

          const SizedBox(width: 8),
          const SizedBox(height: 20, child: VerticalDivider(indent: 2, endIndent: 2)),
          const SizedBox(width: 8),

          // User Avatar & Profile Tag
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: isMunicipality ? AppTheme.primaryNavy : AppTheme.secondaryTeal,
                child: Text(
                  isMunicipality ? "CEO" : "EV",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMunicipality ? "Thiru Selvam" : "Dr. Vance",
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    isMunicipality ? "Municipality CEO" : "Principal",
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
