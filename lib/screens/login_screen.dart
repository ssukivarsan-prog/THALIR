import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../services/auth_service.dart';
import '../providers/dashboard_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: "principal@greenwood.edu.in");
  final _passwordController = TextEditingController(text: "password123");
  bool _isLoading = false;
  String _selectedRole = 'principal'; // 'principal' or 'municipality_head'

  void _handleLogin() async {
    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);

    await authService.signInWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    dashboardProvider.setActiveRole(_selectedRole);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _handleDemoLogin(String role) async {
    setState(() {
      _selectedRole = role;
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);

    if (role == 'principal') {
      _emailController.text = "principal@greenwood.edu.in";
    } else {
      _emailController.text = "ceo.education@chennaicorp.gov.in";
    }

    await authService.signInAsHeadmaster();
    dashboardProvider.setActiveRole(role);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
              boxShadow: AppTheme.hoverShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sapling Icon & THALIR Branding matching Mobile Splash Screen
                Column(
                  children: [
                    // Sapling Icon Container
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0F2338),
                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.2),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.spa_rounded,
                          color: Color(0xFF10B981),
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "THALIR",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryNavy,
                        letterSpacing: 4.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "STUDENT SUPPORT PLATFORM",
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppTheme.secondaryTeal,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tamil Tagline Pill Container matching screenshot
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withOpacity(0.06),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF334155).withOpacity(0.2)),
                      ),
                      child: const Text(
                        "தளிர்கள் வளரட்டும், கல்வி ஒளிரட்டும்",
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryNavy,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                const Text(
                  "Select Portal Role",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                // 2 Role Toggle Cards
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = 'principal'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'principal'
                                ? AppTheme.secondaryTeal.withOpacity(0.12)
                                : AppTheme.surfaceSubtle,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _selectedRole == 'principal'
                                  ? AppTheme.secondaryTeal
                                  : AppTheme.border,
                              width: _selectedRole == 'principal' ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.school_rounded,
                                color: _selectedRole == 'principal'
                                    ? AppTheme.secondaryTeal
                                    : AppTheme.textMuted,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "School Principal",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedRole == 'principal'
                                      ? AppTheme.secondaryTeal
                                      : AppTheme.textSecondary,
                                ),
                              ),
                              const Text(
                                "(Single School)",
                                style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = 'municipality_head'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'municipality_head'
                                ? AppTheme.primaryNavy.withOpacity(0.12)
                                : AppTheme.surfaceSubtle,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _selectedRole == 'municipality_head'
                                  ? AppTheme.primaryNavy
                                  : AppTheme.border,
                              width: _selectedRole == 'municipality_head' ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.location_city_rounded,
                                color: _selectedRole == 'municipality_head'
                                    ? AppTheme.primaryNavy
                                    : AppTheme.textMuted,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Municipality CEO",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedRole == 'municipality_head'
                                      ? AppTheme.primaryNavy
                                      : AppTheme.textSecondary,
                                ),
                              ),
                              const Text(
                                "(All City Schools)",
                                style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Email Input
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Official Email Address",
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 16),

                // Password Input
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Security Password",
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 24),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          "Sign In as ${_selectedRole == 'principal' ? 'School Principal' : 'Municipality Officer'}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                ),

                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("OR DEMO ACCESS",
                          style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // Quick Demo Login Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleDemoLogin('principal'),
                        icon: const Icon(Icons.school, size: 16),
                        label: const Text("Principal Demo", style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleDemoLogin('municipality_head'),
                        icon: const Icon(Icons.location_city, size: 16),
                        label: const Text("Municipality Demo", style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    "v1.0.0 • Tamil Nadu Education Board Initiative",
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
