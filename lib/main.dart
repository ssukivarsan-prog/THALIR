import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app_theme.dart';
import 'services/auth_service.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/app_drawer.dart';
import 'widgets/header_bar.dart';
import 'screens/login_screen.dart';
import 'screens/overview_screen.dart';
import 'screens/municipality_overview_screen.dart';
import 'screens/class_breakdown_screen.dart';
import 'screens/student_list_screen.dart';
import 'screens/student_support_hub_screen.dart';
import 'screens/reports_export_screen.dart';
import 'screens/student_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase successfully initialized for Web project ${DefaultFirebaseOptions.web.projectId}");
  } catch (e) {
    debugPrint("Firebase init notice (using demo fallback if offline): $e");
  }
  runApp(const HeadmasterDashboardApp());
}

class HeadmasterDashboardApp extends StatelessWidget {
  const HeadmasterDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        title: 'Thalir (தளீர்) — Student Retention & Support Platform',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppRootRouter(),
      ),
    );
  }
}

class AppRootRouter extends StatelessWidget {
  const AppRootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (!authService.isAuthenticated) {
      return const LoginScreen();
    }

    return const MainDashboardLayout();
  }
}

class MainDashboardLayout extends StatelessWidget {
  const MainDashboardLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final isMunicipality = dashboardProvider.activeRole == 'municipality_head';

    Widget currentScreen;
    switch (dashboardProvider.selectedNavIndex) {
      case 0:
        currentScreen = isMunicipality
            ? const MunicipalityOverviewScreen()
            : const OverviewScreen();
        break;
      case 1:
        currentScreen = const ClassBreakdownScreen();
        break;
      case 2:
        currentScreen = const StudentListScreen();
        break;
      case 3:
        currentScreen = const StudentSupportHubScreen();
        break;
      case 4:
        currentScreen = const ReportsExportScreen();
        break;
      default:
        currentScreen = isMunicipality
            ? const MunicipalityOverviewScreen()
            : const OverviewScreen();
    }

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // Left Permanent Navigation Sidebar
              const AppDrawer(),

              // Right Main Area (Header + Active View)
              Expanded(
                child: Column(
                  children: [
                    const HeaderBar(),
                    Expanded(
                      child: Container(
                        color: AppTheme.background,
                        child: currentScreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Student Drill-Down Profile Modal Overlay
          if (dashboardProvider.selectedStudent != null)
            const StudentDetailModal(),
        ],
      ),
    );
  }
}
