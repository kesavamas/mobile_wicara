import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/screens/main_layout.dart';
import 'package:wicara_application_1/screens/login_screen.dart';
import 'package:wicara_application_1/screens/onboarding_screen.dart';
import 'package:wicara_application_1/screens/splash_screen.dart';

// Mode pratinjau dengan frame device (mis. iPhone 16) untuk dicoba di Chrome/desktop.
// Aktifkan dengan: flutter run -d chrome --dart-define=DEVICE_PREVIEW=true
const bool kDevicePreview = bool.fromEnvironment(
  // 'DEVICE_PREVIEW',
  'DEVICE_PREVIEW',
  defaultValue: false,
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const app = MyApp();

  runApp(
    kDevicePreview
        ? DevicePreview(
            defaultDevice: Devices.ios.iPhone16,
            builder: (context) => app,
          )
        : app,
  );
}

class MyApp extends StatelessWidget {
  final bool? isLoggedIn;
  final bool? showOnboarding;

  const MyApp({super.key, this.isLoggedIn, this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WICARA',
      debugShowCheckedModeBanner: false,
      locale: kDevicePreview ? DevicePreview.locale(context) : null,
      builder: kDevicePreview ? DevicePreview.appBuilder : null,
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
      home: isLoggedIn == null || showOnboarding == null
          ? const SplashScreen()
          : showOnboarding!
          ? const OnboardingScreen()
          : isLoggedIn!
          ? const MainLayout()
          : const LoginScreen(),
    );
  }
}
