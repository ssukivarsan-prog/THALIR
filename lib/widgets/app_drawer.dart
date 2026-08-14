import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/dashboard_provider.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final authService = Provider.of<AuthService>(context);
    final isMunicipality = dashboardProvider.activeRole == 'municipality_head';

    return Container(
      width: 250,
      color: AppTheme.primaryNavy,
      child: Column(
        children: [
          // Sapling Branding Header matching Mobile App
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0F2338),
                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4), width: 1),
                      ),
                      child: const Icon(
                        Icons.spa_rounded,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "THALIR",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3.0,
                            ),
                          ),
                          Text(
                            isMunicipality ? "MUNICIPALITY HQ" : "STUDENT SUPPORT PLATFORM",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: const Text(
                    "தளிர்கள் வளரட்டும், கல்வி ஒளிரட்டும்",
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF1E293B), height: 1),

          const SizedBox(height: 16),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                if (!isMunicipality) ...[
                  _DrawerNavItem(
                    icon: Icons.dashboard_outlined,
                    selectedIcon: Icons.dashboard_rounded,
                    label: "School Overview",
                    index: 0,
                    currentIndex: dashboardProvider.selectedNavIndex,
                    onTap: () => dashboardProvider.setNavIndex(0),
                  ),
                  _DrawerNavItem(
                    icon: Icons.domain_outlined,
                    selectedIcon: Icons.domain_rounded,
                    label: "Class Breakdown",
                    index: 1,
                    currentIndex: dashboardProvider.selectedNavIndex,
                    onTap: () => dashboardProvider.setNavIndex(1),
                  ),
                  _DrawerNavItem(
                    icon: Icons.people_outline_rounded,
                    selectedIcon: Icons.people_rounded,
                    label: "Student Roster",
                    index: 2,
                    currentIndex: dashboardProvider.selectedNavIndex,
                    onTap: () => dashboardProvider.setNavIndex(2),
                  ),
                  _DrawerNavItem(
                    icon: Icons.volunteer_activism_outlined,
                    selectedIcon: Icons.volunteer_activism_rounded,
                    label: "4-Pillar Support Hub",
                    index: 3,
                    badgeCount: dashboardProvider.recommendations
                        .where((r) => r.status.contains('Pending'))
                        .length,
                    currentIndex: dashboardProvider.selectedNavIndex,
                    onTap: () => dashboardProvider.setNavIndex(3),
                  ),
                  _DrawerNavItem(
                    icon: Icons.receipt_long_outlined,
                    selectedIcon: Icons.receipt_long_rounded,
                    label: "Reports & Export",
                    index: 4,
                    currentIndex: dashboardProvider.selectedNavIndex,
                    onTap: () => dashboardProvider.setNavIndex(4),
                  ),
                ] else ...[
                  _DrawerNavItem(
                    icon: Icons.location_city_outlined,
                    selectedIcon: Icons.location_city_rounded,
                    label: "Municipality City View",
                    index: 0,
                    currentIndex: dashboardProvider.selectedNavIndex,
                    onTap: () => dashboardProvider.setNavIndex(0),
                  ),
                  _DrawerNavItem(
                    icon: Icons.account_balance_outlined,
                    selectedIcon: Icons.account_balance_rounded,
                    label: "All Schools Matrix",
                    index: 1,
                    currentIndex: dashboardProvider.selectedNavIndex,
                    onTap: () => dashboardProvider.setNavIndex(1),
                  ),
                  _DrawerNavItem(
                    icon: Icons.warning_amber_rounded,
                    selectedIcon: Icons.warning_rounded,
                    label: "City Risk Directory",
                    index: 2,
                    currentIndex: dashboardProvider.selectedNavIndex,
                    onTap: () => dashboardProvider.setNavIndex(2),
                  ),
                  _DrawerNavItem(
                    icon: Icons.approval_outlined,
                    selectedIcon: Icons.approval_rounded,
                    label: "Endorsements & Hub",
                    index: 3,
                    badgeCount: dashboardProvider.recommendations
                        .where((r) => r.status.contains('Approved by Principal'))
                        .length,
                    currentIndex: dashboardProvider.selectedNavIndex,
                    onTap: () => dashboardProvider.setNavIndex(3),
                  ),
                  _DrawerNavItem(
                    icon: Icons.description_outlined,
                    selectedIcon: Icons.description_rounded,
                    label: "Foundation Reports",
                    index: 4,
                    currentIndex: dashboardProvider.selectedNavIndex,
                    onTap: () => dashboardProvider.setNavIndex(4),
                  ),
                ],
              ],
            ),
          ),

          // Security Scoping Banner
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isMunicipality ? Icons.verified_user : Icons.security,
                      size: 14,
                      color: AppTheme.secondaryTeal,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isMunicipality ? "Municipality Scoped" : "Principal Scoped",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isMunicipality
                      ? "Full access to Chennai Corporation schools data."
                      : "Scoped to Greenwood High School (schoolId: greenwood-01).",
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                ),
              ],
            ),
          ),

          // Sign Out Button
          Container(
            padding: const EdgeInsets.all(12),
            child: ListTile(
              onTap: () => authService.signOut(),
              dense: true,
              horizontalTitleGap: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              leading: const Icon(Icons.logout_rounded, color: Color(0xFF94A3B8), size: 18),
              title: const Text(
                "Sign Out",
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerNavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int index;
  final int currentIndex;
  final int? badgeCount;
  final VoidCallback onTap;

  const _DrawerNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        onTap: onTap,
        dense: true,
        horizontalTitleGap: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
        leading: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected ? AppTheme.secondaryTeal : const Color(0xFF94A3B8),
          size: 20,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            if (badgeCount != null && badgeCount! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.riskHighText,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "$badgeCount",
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
