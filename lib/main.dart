import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wicara_application_1/screens/main_layout.dart';
import 'package:wicara_application_1/screens/login_screen.dart';
import 'package:wicara_application_1/screens/onboarding_screen.dart';
import 'package:wicara_application_1/services/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final loggedIn = await SessionService.isLoggedIn();
  
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  runApp(MyApp(
    isLoggedIn: loggedIn,
    showOnboarding: !onboardingCompleted,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool showOnboarding;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.showOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WICARA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          secondary: const Color(0xFFF59E0B),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.nunitoSansTextTheme(Theme.of(context).textTheme),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
          ),
        ),
        useMaterial3: true,
      ),
      home: showOnboarding
          ? const OnboardingScreen()
          : (isLoggedIn ? const MainLayout() : const LoginScreen()),
    );
  }
}
