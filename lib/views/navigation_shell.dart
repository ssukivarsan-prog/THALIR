import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/teacher_repository.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/ocr_scanner_screen.dart';
import 'screens/student_list_screen.dart';
import 'screens/activity_recording_screen.dart';
import 'screens/teacher_profile_screen.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeDashboardScreen(),
    OcrScannerScreen(),
    StudentListScreen(),
    ActivityRecordingScreen(),
    TeacherProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TeacherRepository>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.school, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Thalir',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    '${repo.teacher.schoolName} • Class ${repo.teacher.activeClass}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Class Dropdown Selector Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: repo.teacher.activeClass,
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF4F46E5), size: 16),
                items: repo.teacher.assignedClasses.map((cls) {
                  return DropdownMenuItem(
                    value: cls,
                    child: Text(
                      'Class $cls',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) repo.setActiveClass(val);
                },
              ),
            ),
          ),
          IconButton(
            tooltip: repo.isOnline ? 'Online - Sync Active' : 'Offline Mode (${repo.pendingSyncCount} pending)',
            onPressed: () => repo.toggleOnlineStatus(),
            visualDensity: VisualDensity.compact,
            icon: Badge(
              isLabelVisible: repo.pendingSyncCount > 0,
              label: Text('${repo.pendingSyncCount}'),
              child: Icon(
                repo.isOnline ? Icons.wifi : Icons.wifi_off,
                size: 20,
                color: repo.isOnline ? const Color(0xFF0D9488) : const Color(0xFFF59E0B),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
          boxShadow: [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          elevation: 0,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFEEF2FF),
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF4F46E5)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.camera_alt_outlined, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.camera_alt_rounded, color: Color(0xFF4F46E5)),
              label: 'Capture',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.people_rounded, color: Color(0xFF4F46E5)),
              label: 'Students',
            ),
            NavigationDestination(
              icon: Icon(Icons.hub_outlined, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.hub_rounded, color: Color(0xFF4F46E5)),
              label: 'Risk Map',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF4F46E5)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
