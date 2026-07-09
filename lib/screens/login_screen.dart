import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/services/api_service.dart';
import 'package:wicara_application_1/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isRegistering = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Selected Avatar details
  String _selectedEmoji = 'face';
  String _selectedColor = '#F59E0B';

  final List<String> _emojis = ['face', 'robot', 'paw', 'rabbit', 'star'];

  IconData getAvatarIcon(String emojiOrKey) {
    switch (emojiOrKey) {
      case 'robot':
      case '🤖':
        return Icons.smart_toy_rounded;
      case 'paw':
      case '🐼':
        return Icons.pets_rounded;
      case 'rabbit':
      case '🦊':
        return Icons.cruelty_free_rounded;
      case 'star':
      case '🦄':
        return Icons.auto_awesome_rounded;
      case 'face':
      case '🦁':
      default:
        return Icons.face_rounded;
    }
  }
  final List<String> _colors = ['#F59E0B', '#3B82F6', '#EF4444', '#10B981', '#8B5CF6'];

  @override
  void dispose() {
    _tokenController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  Future<void> _handleLogin() async {
    final token = _tokenController.text.trim();
    final password = _passwordController.text;

    if (token.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Token dan password wajib diisi';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ApiService.login(token, password);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      setState(() {
        _errorMessage =
            ApiService.lastError ??
            'Token tidak ditemukan. Coba hubungi gurumu atau daftar baru.';
      });
    }
  }

  Future<void> _handleRegister() async {
    final nickname = _nicknameController.text.trim();
    final password = _passwordController.text;

    if (nickname.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Nama panggilan dan password wajib diisi';
      });
      return;
    }

    if (nickname.length < 2) {
      setState(() {
        _errorMessage = 'Nama panggilan minimal 2 karakter';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Password minimal 6 karakter';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final token = await ApiService.register(
      nickname,
      password,
      _selectedEmoji,
      _selectedColor,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (token != null) {
      // Show success modal displaying generated token
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              'Registrasi Sukses! 🎉',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catat token masuk unik Anda di bawah ini untuk digunakan login kembali nanti:',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Text(
                      token,
                      style: GoogleFonts.robotoMono(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Password Anda: $password',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Mulai Latihan',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      setState(() {
        _errorMessage = ApiService.lastError ?? 'Registrasi gagal.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEAF2FF), Color(0xFFFFFBEB), Color(0xFFF7F7F2)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                          blurRadius: 32,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // App Brand Header
                        Row(
                          children: [
                            Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: const DecorationImage(
                                  image: AssetImage('assets/logo.png'),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'WICARA',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Latihan kalimat formal',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),

                        // Login Screen View
                        if (!_isRegistering) ...[
                          Text(
                            'Masuk ke bilik belajarmu',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gunakan token dan password untuk membuka latihan dan menyimpan progresmu.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF64748B),
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Token siswa',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _tokenController,
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.next,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.robotoMono(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.6,
                              color: const Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText: 'WCR-01',
                              prefixIcon: const Icon(Icons.key_rounded),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              hintStyle: GoogleFonts.robotoMono(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFCBD5E1),
                                letterSpacing: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Password siswa',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _isLoading ? null : _handleLogin(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.robotoMono(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: const Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Password Anda',
                              prefixIcon: const Icon(Icons.lock_rounded),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              hintStyle: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFCBD5E1),
                              ),
                            ),
                          ),
                        ] else ...[
                          // Registration Screen View
                          Text(
                            'Daftar akun siswa baru',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dapatkan token masuk unik dengan membuat profil barumu sendiri.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF64748B),
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Nama Panggilan',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nicknameController,
                            textInputAction: TextInputAction.next,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Misal: Budi',
                              prefixIcon: Icon(Icons.person_rounded),
                              contentPadding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Buat Password',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            style: GoogleFonts.robotoMono(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: const Color(0xFF0F172A),
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Minimal 6 karakter',
                              prefixIcon: Icon(Icons.lock_rounded),
                              contentPadding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Pilih Avatar Vektor',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: _emojis.map((emoji) {
                              final isSelected = _selectedEmoji == emoji;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedEmoji = emoji),
                                child: Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF2563EB).withValues(alpha: 0.15) : const Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                                      width: isSelected ? 2.5 : 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      getAvatarIcon(emoji),
                                      size: 24,
                                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Pilih Warna Profil',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: _colors.map((colorHex) {
                              final isSelected = _selectedColor == colorHex;
                              final color = _parseColor(colorHex);
                              return GestureDetector(
                                onTap: () => setState(() => _selectedColor = colorHex),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                                      width: isSelected ? 3.0 : 2.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        // Error message
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFFFCCD5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  color: Color(0xFFBE123C),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFFBE123C),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),

                        // Action submit button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : (_isRegistering ? _handleRegister : _handleLogin),
                            icon: _isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.arrow_forward_rounded),
                            label: Text(
                              _isLoading
                                  ? (_isRegistering ? 'Mendaftarkan...' : 'Memeriksa token...')
                                  : (_isRegistering ? 'Daftar Akun & Masuk' : 'Masuk'),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 0,
                              textStyle: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        
                        // Toggle link
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _isRegistering = !_isRegistering;
                                _errorMessage = null;
                              });
                            },
                            child: Text(
                              _isRegistering
                                  ? 'Sudah punya akun? Masuk dengan token'
                                  : 'Belum punya akun? Daftar siswa baru',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Progres tersimpan ke dashboard guru',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
