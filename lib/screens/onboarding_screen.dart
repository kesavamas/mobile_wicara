import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wicara_application_1/core/theme/app_colors.dart';
import 'package:wicara_application_1/screens/login_screen.dart';
import 'package:wicara_application_1/widgets/wika_mascot.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Stack(
            children: [
              const Positioned(
                right: -100,
                top: 120,
                child: _SoftCircle(size: 260, color: Color(0x1A6C4FD3)),
              ),
              const Positioned(
                left: -90,
                bottom: 120,
                child: _SoftCircle(size: 230, color: Color(0x1834B584)),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 42,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _BrandHeader(),
                          const SizedBox(height: 30),
                          const _MascotIntroduction(),
                          const SizedBox(height: 22),
                          const _LearningCard(),
                          const SizedBox(height: 28),
                          _StartButton(
                            onPressed: () => _completeOnboarding(context),
                          ),
                        ],
                      ),
                    ),
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

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.indigo,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x304C5FD7),
                blurRadius: 15,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Image.asset('assets/logo.png', semanticLabel: 'Logo WICARA'),
        ),
        const SizedBox(width: 10),
        Text(
          'WICARA',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w800,
            color: AppColors.indigoDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Susun Kata, Sampaikan Makna.',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunitoSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.text2,
            ),
          ),
        ),
      ],
    );
  }
}

class _MascotIntroduction extends StatelessWidget {
  const _MascotIntroduction();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 238,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            left: 4,
            top: 34,
            child: _FloatingWord(
              text: 'S - Saya',
              color: Color(0xFF3D73DB),
              background: Color(0xFFEAF2FF),
            ),
          ),
          const Positioned(
            right: 4,
            top: 3,
            child: _FloatingWord(
              text: 'P - izin',
              color: Color(0xFFD94865),
              background: Color(0xFFFFECEF),
            ),
          ),
          const Positioned(
            top: 22,
            child: WikaMascot(mood: WikaMood.welcome, size: 128),
          ),
          Positioned(
            bottom: 0,
            left: 42,
            right: 42,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFC9D3FF)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x124C5FD7),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                '"Hai! Aku Wika, teman belajarmu."',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningCard extends StatelessWidget {
  const _LearningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFCFD8F6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x124C5FD7),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Belajar Menyusun Pesan Formal',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              height: 1.3,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Susun kata menjadi kalimat yang jelas dan sopan melalui misi seru untuk sekolah, magang, dan dunia kerja.',
            style: GoogleFonts.nunitoSans(
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w700,
              color: AppColors.text2,
            ),
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 6,
            runSpacing: 7,
            children: [
              _SentenceToken(
                text: 'Saya',
                color: Color(0xFF3D73DB),
                background: Color(0xFFEAF2FF),
              ),
              _SentenceToken(
                text: 'izin',
                color: Color(0xFFD94865),
                background: Color(0xFFFFECEF),
              ),
              _SentenceToken(
                text: 'sekolah',
                color: Color(0xFF19845F),
                background: Color(0xFFE8F8F1),
              ),
              _SentenceToken(
                text: 'hari ini',
                color: Color(0xFFC28A00),
                background: Color(0xFFFFF4CC),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              const Icon(
                Icons.arrow_forward_rounded,
                size: 15,
                color: AppColors.muted,
              ),
              const SizedBox(width: 5),
              Text(
                'kalimat formal',
                style: GoogleFonts.nunitoSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 14,
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _StartButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      iconAlignment: IconAlignment.end,
      icon: const Icon(Icons.arrow_forward_rounded),
      label: const Text('Mulai Sekarang'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.indigo,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        elevation: 5,
        shadowColor: AppColors.indigoDark,
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FloatingWord extends StatelessWidget {
  final String text;
  final Color color;
  final Color background;

  const _FloatingWord({
    required this.text,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: text.startsWith('S') ? -0.05 : 0.05,
      child: _SentenceToken(
        text: text,
        color: color,
        background: background,
        large: true,
      ),
    );
  }
}

class _SentenceToken extends StatelessWidget {
  final String text;
  final Color color;
  final Color background;
  final bool large;

  const _SentenceToken({
    required this.text,
    required this.color,
    required this.background,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 13 : 10,
        vertical: large ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color, width: 1.4),
        boxShadow: large
            ? const [
                BoxShadow(
                  color: Color(0x1424304A),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        text,
        style: GoogleFonts.nunitoSans(
          fontSize: large ? 12 : 10,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
