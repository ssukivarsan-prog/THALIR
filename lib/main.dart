 import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/teacher_repository.dart';
import 'services/speech_ai_service.dart';
import 'views/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
  runApp(const TeacherAssistantApp());
}

class TeacherAssistantApp extends StatelessWidget {
  const TeacherAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Premium Soft Light Color Palette
    const primaryIndigo = Color(0xFF4F46E5);
    const secondaryTeal = Color(0xFF0D9488);
    const softBackground = Color(0xFFF8FAFC);
    const cardSurface = Colors.white;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TeacherRepository()),
        Provider(create: (_) => SpeechAiService()),
      ],
      child: MaterialApp(
        title: 'Thalir — Student Support Assistant',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light, // Enforce light theme
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: softBackground,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryIndigo,
            brightness: Brightness.light,
            primary: primaryIndigo,
            primaryContainer: const Color(0xFFEEF2FF),
            secondary: secondaryTeal,
            secondaryContainer: const Color(0xFFCCFBF1),
            surface: cardSurface,
            surfaceContainerHighest: const Color(0xFFF1F5F9),
            onSurface: const Color(0xFF0F172A),
          ),
          textTheme: GoogleFonts.plusJakartaSansTextTheme(
            ThemeData.light().textTheme,
          ).apply(
            bodyColor: const Color(0xFF1E293B),
            displayColor: const Color(0xFF0F172A),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF0F172A),
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          cardTheme: CardThemeData(
            color: cardSurface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: const Color(0xFFF1F5F9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide.none,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: primaryIndigo, width: 2),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
