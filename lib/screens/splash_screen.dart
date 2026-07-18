import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wicara_application_1/screens/login_screen.dart';
import 'package:wicara_application_1/screens/main_layout.dart';
import 'package:wicara_application_1/screens/onboarding_screen.dart';
import 'package:wicara_application_1/services/session_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _loadingController;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
    _fade = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );
    _prepareApp();
  }

  Future<void> _prepareApp() async {
    final startedAt = DateTime.now();
    final loggedIn = await SessionService.isLoggedIn();
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    const minimumDuration = Duration(milliseconds: 1800);
    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed < minimumDuration) {
      await Future<void>.delayed(minimumDuration - elapsed);
    }
    if (!mounted) return;

    final destination = !onboardingCompleted
        ? const OnboardingScreen()
        : loggedIn
        ? const MainLayout()
        : const LoginScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, animation, secondaryAnimation) => destination,
        transitionsBuilder: (_, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4C5FD7),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const Positioned(
                right: -72,
                top: -80,
                child: _SplashCircle(size: 260, outlined: true),
              ),
              const Positioned(
                left: -74,
                top: 270,
                child: _SplashCircle(size: 150),
              ),
              const Positioned(
                left: -50,
                bottom: -90,
                child: _SplashCircle(size: 230, outlined: true),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const Spacer(flex: 4),
                      FadeTransition(
                        opacity: _fade,
                        child: ScaleTransition(
                          scale: _scale,
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/logo.png',
                                width: 205,
                                semanticLabel: 'Logo WICARA',
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'WICARA',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 42,
                                  letterSpacing: 8,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Susun Kata, Sampaikan Makna.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white.withValues(alpha: 0.82),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(flex: 4),
                      AnimatedBuilder(
                        animation: _loadingController,
                        builder: (context, _) => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            final phase =
                                (_loadingController.value * math.pi * 2) -
                                (index * 0.75);
                            final opacity = 0.38 + (math.sin(phase) + 1) * 0.31;
                            return Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: opacity),
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 42),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashCircle extends StatelessWidget {
  final double size;
  final bool outlined;

  const _SplashCircle({required this.size, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: outlined ? Colors.transparent : Colors.white10,
        border: outlined ? Border.all(color: Colors.white12, width: 1.5) : null,
      ),
    );
  }
}
