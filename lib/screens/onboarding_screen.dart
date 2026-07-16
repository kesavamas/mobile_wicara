import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wicara_application_1/widgets/wika_mascot.dart';
import 'package:wicara_application_1/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Belajar Menyusun Pesan Formal',
      'desc': 'Latih cara menyampaikan pesan untuk sekolah, magang, dan dunia kerja.',
      'mood': WikaMood.welcome,
    },
    {
      'title': 'Belajar Lewat Misi Petualangan',
      'desc': 'Selesaikan kasus satu per satu dan buka tantangan berikutnya.',
      'mood': WikaMood.point,
    },
    {
      'title': 'Belajar Tanpa Takut Salah',
      'desc': 'Petunjuk warna akan membantu kamu merapikan susunan kalimat.',
      'mood': WikaMood.hint,
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentStep];

    return Scaffold(
      body: Stack(
        children: [
          // Aurora Gradient Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFEEF3FF),
              ),
            ),
          ),
          // Blur Circles simulation
          Positioned(
            top: -80,
            left: -80,
            width: 320,
            height: 320,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFC7D5FF).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 200,
            right: -80,
            width: 288,
            height: 288,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFDDD6FE).withOpacity(0.45),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: 30,
            width: 256,
            height: 256,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFBAF0D9).withOpacity(0.35),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Decorative Floating Word Chips
          Positioned(
            left: 20,
            top: 150,
            child: _buildFloatingChip('S · Saya', const Color(0xFFEAF2FF), const Color(0xFF4D91FF), const Color(0xFF163E8C)),
          ),
          Positioned(
            right: 20,
            top: 130,
            child: _buildFloatingChip('P · izin', const Color(0xFFFFECEF), const Color(0xFFD9485F), const Color(0xFF8B2235)),
          ),
          Positioned(
            left: 15,
            bottom: 240,
            child: _buildFloatingChip('K · hari ini', const Color(0xFFFFF4D6), const Color(0xFFE5A91D), const Color(0xFF6A4C00)),
          ),
          Positioned(
            right: 15,
            bottom: 200,
            child: _buildFloatingChip('O · sekolah', const Color(0xFFE8F8F1), const Color(0xFF1F9D70), const Color(0xFF145B42)),
          ),

          // Core UI Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Brand Header
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4C5FD7),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4C5FD7).withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chat_bubble_rounded,
                          size: 19,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WICARA',
                              style: GoogleFonts.plusJakartaSans(
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: Color(0xFF3445AC),
                                ),
                              ),
                            ),
                            Text(
                              'Susun Kata, Sampaikan Makna.',
                              style: GoogleFonts.inter(
                                textStyle: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5D6785),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Mascot & Slide Cards Space
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        WikaMascot(
                          key: ValueKey<int>(_currentStep),
                          mood: slide['mood'] as WikaMood,
                          size: 100,
                        ),
                        const SizedBox(height: 12),

                        // Mascot Speech Bubble
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFD4DCFF)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4263EB).withOpacity(0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Text(
                            '"Yuk, lanjutkan petualangan komunikasimu!"',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF667085),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Slide Text Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: const Color(0xFFD4DCFF)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4263EB).withOpacity(0.08),
                                blurRadius: 40,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slide['title'] as String,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF24304A),
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                slide['desc'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF667085),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildSampleChip('Saya', const Color(0xFFEAF2FF), const Color(0xFF4D91FF), const Color(0xFF163E8C)),
                                  const SizedBox(width: 4),
                                  _buildSampleChip('izin', const Color(0xFFFFECEF), const Color(0xFFD9485F), const Color(0xFF8B2235)),
                                  const SizedBox(width: 4),
                                  _buildSampleChip('sekolah', const Color(0xFFE8F8F1), const Color(0xFF1F9D70), const Color(0xFF145B42)),
                                  const SizedBox(width: 4),
                                  _buildSampleChip('hari ini', const Color(0xFFFFF4D6), const Color(0xFFE5A91D), const Color(0xFF6A4C00)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '→ kalimat formal ✓',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF98A2B3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Navigation Actions
                  Column(
                    children: [
                      // Steps indicator dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_slides.length, (index) {
                          final active = index == _currentStep;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: active ? 28 : 8,
                            decoration: BoxDecoration(
                              color: active ? const Color(0xFF4263EB) : const Color(0xFFD0D5DD),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),

                      // Next Button (Chunky Style)
                      GestureDetector(
                        onTap: () {
                          if (_currentStep < _slides.length - 1) {
                            setState(() {
                              _currentStep++;
                            });
                          } else {
                            _completeOnboarding();
                          }
                        },
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4C5FD7),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF3445AC),
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentStep < _slides.length - 1 ? 'Lanjut' : 'Mulai Belajar',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _currentStep < _slides.length - 1 ? Icons.arrow_forward_rounded : Icons.auto_awesome_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingChip(String text, Color bg, Color border, Color textClr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: textClr,
        ),
      ),
    );
  }

  Widget _buildSampleChip(String text, Color bg, Color border, Color textClr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: textClr,
        ),
      ),
    );
  }
}
