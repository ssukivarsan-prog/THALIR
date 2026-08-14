import 'dart:async';
import 'package:flutter/material.dart';
import '../navigation_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.70, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    // Navigate to NavigationShell after 2.8 seconds
    Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const NavigationShell(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1329), // Premium dark navy background
      body: Stack(
        children: [
          // Background soft glowing aura
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: MediaQuery.of(context).size.width * 0.1,
            right: MediaQuery.of(context).size.width * 0.1,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.08), // Emerald glow
                    blurRadius: 100,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Vector Sprout Logo
                  CustomPaint(
                    size: const Size(120, 120),
                    painter: SproutLogoPainter(),
                  ),
                  const SizedBox(height: 28),
                  
                  // App Title (Thalir)
                  const Text(
                    'THALIR',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 8.0,
                      shadows: [
                        Shadow(
                          color: Color(0x3310B981),
                          blurRadius: 15,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Sub-branding
                  Text(
                    'STUDENT SUPPORT PLATFORM',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3.5,
                      color: const Color(0xFF10B981).withOpacity(0.85),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Tamil Tagline
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'தளிர்கள் வளரட்டும், கல்வி ஒளிரட்டும்',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom developer/version watermark
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.6,
              child: Text(
                'v1.0.0 • Tamil Nadu Education Board Initiative',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.0,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Sprout Leaf Painter for the Thalir logo vector
class SproutLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    
    // Draw background glowing circle ring
    final Paint ringPaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.45, ringPaint);

    final Paint circlePaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.04)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.45, circlePaint);
    
    // Left leaf gradient
    final Paint leftLeafPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF34D399), Color(0xFF059669)],
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
      ).createShader(Rect.fromLTWH(w * 0.2, h * 0.2, w * 0.35, h * 0.5));
      
    // Right leaf gradient  
    final Paint rightLeafPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF6EE7B7), Color(0xFF10B981)],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(w * 0.45, h * 0.3, w * 0.35, h * 0.4));
      
    // Stem Paint
    final Paint stemPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF059669), Color(0xFF047857)],
      ).createShader(Rect.fromLTWH(w * 0.45, h * 0.5, w * 0.1, h * 0.35))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    // 1. Draw Stem
    final Path stemPath = Path();
    stemPath.moveTo(w * 0.5, h * 0.8);
    stemPath.quadraticBezierTo(w * 0.48, h * 0.65, w * 0.51, h * 0.45);
    canvas.drawPath(stemPath, stemPaint);

    // 2. Draw Left Leaf (Bigger sprout leaf)
    final Path leftLeaf = Path();
    leftLeaf.moveTo(w * 0.50, h * 0.60);
    // Outer curve up to tip
    leftLeaf.quadraticBezierTo(w * 0.15, h * 0.55, w * 0.25, h * 0.25);
    // Tip curve back to base
    leftLeaf.quadraticBezierTo(w * 0.50, h * 0.32, w * 0.50, h * 0.60);
    canvas.drawPath(leftLeaf, leftLeafPaint);

    // 3. Draw Right Leaf (Younger, smaller sprout leaf shooting out)
    final Path rightLeaf = Path();
    rightLeaf.moveTo(w * 0.50, h * 0.52);
    // Outer curve up to tip
    rightLeaf.quadraticBezierTo(w * 0.80, h * 0.48, w * 0.72, h * 0.32);
    // Tip curve back to base
    rightLeaf.quadraticBezierTo(w * 0.52, h * 0.38, w * 0.50, h * 0.52);
    canvas.drawPath(rightLeaf, rightLeafPaint);
    
    // Draw a small shining dot near the leaf tip
    final Paint glowDot = Paint()..color = const Color(0xFFA7F3D0);
    canvas.drawCircle(Offset(w * 0.28, h * 0.28), 3.0, glowDot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
