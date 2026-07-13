import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/models/bilik.dart';
import 'package:wicara_application_1/services/api_service.dart';
import 'package:wicara_application_1/services/session_service.dart';
import 'package:wicara_application_1/screens/login_screen.dart';
import 'package:wicara_application_1/screens/level_map_screen.dart';
import 'package:wicara_application_1/screens/focus_screen.dart';
import 'package:wicara_application_1/widgets/wika_mascot.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigate;
  const HomeScreen({Key? key, this.onNavigate}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Bilik> _biliks = [];
  Map<String, int> _levelCounts = {};
  Map<String, String> _avatar = {'emoji': '\u{1F642}', 'color': '#3B82F6'};
  String _studentId = '';
  List<StudentProgress> _progress = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final avatarData = await SessionService.getAvatar();
      final id = await SessionService.getStudentId();
      if (avatarData != null) _avatar = avatarData;
      _studentId = id ?? '';

      final String bilikContent = await rootBundle.loadString(
        'assets/data/bilik.json',
      );
      final List decodedBiliks = jsonDecode(bilikContent);
      _biliks = decodedBiliks.map((x) => Bilik.fromJson(x)).toList();

      final String levelContent = await rootBundle.loadString(
        'assets/data/bilik-levels.json',
      );
      final Map<String, dynamic> decodedLevels = jsonDecode(levelContent);
      _levelCounts = decodedLevels.map(
        (key, value) => MapEntry(key, value is List ? value.length : 0),
      );

      _progress = await ApiService.fetchProgress();
    } catch (e) {
      debugPrint('Error loading home data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshProgress() async {
    final freshProgress = await ApiService.fetchProgress();
    if (mounted) setState(() => _progress = freshProgress);
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Keluar aplikasi',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Keluar',
              style: TextStyle(color: Color(0xFFDC2626)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SessionService.clearSession();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  Future<void> _refreshSessionData() async {
    final avatarData = await SessionService.getAvatar();
    final id = await SessionService.getStudentId();
    if (avatarData != null && id != null) {
      setState(() {
        _avatar = avatarData;
        _studentId = id;
      });
    }
  }

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

  void _openEditProfileSheet() {
    final TextEditingController nicknameController = TextEditingController(text: _studentId);
    final TextEditingController passwordController = TextEditingController();
    String selectedEmoji = _avatar['emoji'] ?? 'face';
    String selectedColor = _avatar['color'] ?? '#3B82F6';
    bool sheetSaving = false;
    String? sheetError;

    final List<String> emojis = ['face', 'robot', 'paw', 'rabbit', 'star'];
    final List<String> colors = ['#F59E0B', '#3B82F6', '#EF4444', '#10B981', '#8B5CF6'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Ubah Profil Belajar',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
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
                      controller: nicknameController,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: 'Misal: Budi',
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Password Baru',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Sandi rahasia barumu',
                        prefixIcon: Icon(Icons.lock_rounded),
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
                      children: emojis.map((emoji) {
                        final isSelected = selectedEmoji == emoji;
                        return GestureDetector(
                          onTap: () => setSheetState(() => selectedEmoji = emoji),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF2563EB).withOpacity(0.12) : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                                width: isSelected ? 2.5 : 1.5,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                getAvatarIcon(emoji),
                                size: 22,
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
                      children: colors.map((colorHex) {
                        final isSelected = selectedColor == colorHex;
                        final color = _parseColor(colorHex);
                        return GestureDetector(
                          onTap: () => setSheetState(() => selectedColor = colorHex),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                                width: isSelected ? 3.0 : 2.0,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 16)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    
                    if (sheetError != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        sheetError!,
                        style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: sheetSaving ? null : () async {
                          final name = nicknameController.text.trim();
                          final pass = passwordController.text;

                          if (name.isEmpty || pass.isEmpty) {
                            setSheetState(() => sheetError = 'Nama dan password wajib diisi');
                            return;
                          }

                          if (pass.length < 6) {
                            setSheetState(() => sheetError = 'Password minimal 6 karakter');
                            return;
                          }

                          setSheetState(() {
                            sheetSaving = true;
                            sheetError = null;
                          });

                          final success = await ApiService.updateProfile(
                            name,
                            pass,
                            selectedEmoji,
                            selectedColor,
                          );

                          if (success) {
                            await _refreshSessionData();
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profil belajar berhasil disimpan!'),
                                  backgroundColor: Color(0xFF10B981),
                                ),
                              );
                            }
                          } else {
                            setSheetState(() {
                              sheetSaving = false;
                              sheetError = ApiService.lastError ?? 'Gagal memperbarui profil.';
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(sheetSaving ? 'Menyimpan...' : 'Simpan Perubahan'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  int _getCompletedCount(String bilikId) {
    return _progress
        .where((p) => p.bilikId == bilikId && p.status == 'completed')
        .length;
  }

  int get _totalLevels =>
      _levelCounts.values.fold(0, (sum, count) => sum + count);

  int get _totalCompleted {
    return _biliks.fold(0, (sum, bilik) => sum + _getCompletedCount(bilik.id));
  }

  Color _parseColor(String hex) {
    var value = hex.replaceAll('#', '');
    if (value.length == 6) value = 'FF$value';
    return Color(int.parse(value, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshProgress,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Redesigned Hero Section with curved bottom
                    _buildHeroSection(),

                    // Main tab contents
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 110), // Padding-bottom holds space for nav bar
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Toolkit Actions Grid Row
                          _buildToolkitRow(),
                          const SizedBox(height: 28),

                          // Pillow Bilik Belajar Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pilih Bilik Belajar',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1F2858),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_biliks.length - _progress.where((p) => p.status == 'completed').map((p) => p.bilikId).toSet().length} bilik tersisa',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF5D6785),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDE7FF),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '✨ Baru',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF8C6CFF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Bilik room list cards
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _biliks.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final bilik = _biliks[index];
                              final completed = _getCompletedCount(bilik.id);
                              final totalLevels = _levelCounts[bilik.id] ?? 0;
                              return _buildRoomCard(bilik, completed, totalLevels);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF4C5FD7),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 36),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Greeting Pill Badge
              GestureDetector(
                onTap: _openEditProfileSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        getAvatarIcon(_avatar['emoji'] ?? 'face'),
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '👋 Halo, $_studentId!',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title text
              Text(
                'Hari ini mau\nberlatih di mana?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Motivational bubble description
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('✨ ', style: TextStyle(fontSize: 14)),
                    Text(
                      'Yuk, lanjutkan petualangan\nkomunikasimu.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Mini Journey Path Info Row
              Row(
                children: [
                  Row(
                    children: List.generate(3, (index) {
                      final done = index < _totalCompleted;
                      return Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: done ? const Color(0xFFFFC95A) : Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: done ? const Color(0xFFFFC95A) : Colors.white.withOpacity(0.12),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                done ? '✓' : '${index + 1}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: done ? const Color(0xFF5C3C00) : Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                          if (index < 2)
                            Container(
                              width: 24,
                              height: 2,
                              color: done ? const Color(0xFFFFC95A) : Colors.white.withOpacity(0.32),
                            ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$_totalCompleted misi selesai',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Bouncing Wika Mascot overlapped
          Positioned(
            right: 0,
            bottom: -60,
            child: const WikaMascot(
              mood: WikaMood.welcome,
              size: 112,
              animated: true,
            ),
          ),

          // Logout Button
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout_rounded, color: Colors.white70),
              tooltip: 'Keluar',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolkitRow() {
    // Determine level dynamically based on completed count to match Figma XP
    final int level = (_totalCompleted / 3).floor() + 1;
    final int xp = _totalCompleted * 60; // 60 XP per mission to get 120 XP for 2 completed missions
    final int nextLevelXp = level * 300;
    final double levelPct = (xp / nextLevelXp).clamp(0.0, 1.0);

    return Row(
      children: [
        // Level Progress Card
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFDDE2F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1F2858).withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C4FD3),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C4FD3).withOpacity(0.28),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'L$level',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 5,
                          value: levelPct,
                          backgroundColor: const Color(0xFFE8EBF4),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4C5FD7)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$xp / $nextLevelXp XP',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5D6785),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Focus Mode Capsule
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FocusScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF2),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE5C56D)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1F2858).withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.folder_open_outlined,
                    size: 14,
                    color: Color(0xFFFFD36A),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Focus',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF6A4C00),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Streak Count Capsule
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF3445AC),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3445AC).withOpacity(0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'AKTIF',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: const Color(0xFFDDE4FF),
                      ),
                    ),
                    Text(
                      '2 hari',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFFFD36A),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomCard(Bilik bilik, int completed, int totalLevels) {
    final brandColor = _parseColor(bilik.color);
    final isSchool = bilik.id == 'akademik';
    final progressPct = totalLevels == 0 ? 0.0 : completed / totalLevels;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4B5DFF).withOpacity(0.12),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Illustration scene container
          Container(
            height: 195,
            decoration: BoxDecoration(
              color: isSchool ? const Color(0xFFEEF3FF) : const Color(0xFFF3EFFF),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Stack(
              children: [
                // Right aligned SVG-like vector decoration based on Bilik
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _buildRoomIllustration(bilik.id),
                ),

                // Card info details
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: brandColor,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: brandColor.withOpacity(0.38),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  bilik.id == 'akademik' ? Icons.school_rounded : Icons.business_center_rounded,
                                  color: Colors.white,
                                  size: 13,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$totalLevels Kasus',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.68),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.white.withOpacity(0.55)),
                            ),
                            child: Text(
                              completed < totalLevels ? '1 Terbuka' : 'Selesai',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF5D6785),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Room Title
                      Text(
                        bilik.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: isSchool ? const Color(0xFF1F2858) : const Color(0xFF2D1B6E),
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Room Desc
                      SizedBox(
                        width: 178,
                        child: Text(
                          bilik.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isSchool ? const Color(0xFF3A4A7A) : const Color(0xFF4A3080),
                            height: 1.4,
                          ),
                        ),
                      ),

                      // Figma Progress Bar for school room
                      if (bilik.id == 'akademik') ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 180,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Progres',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isSchool ? const Color(0xFF5D6785) : const Color(0xFF6D579E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(999),
                                      child: LinearProgressIndicator(
                                        minHeight: 5,
                                        value: progressPct,
                                        backgroundColor: const Color(0xFFE8EBF4),
                                        valueColor: AlwaysStoppedAnimation<Color>(brandColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: brandColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${(progressPct * 100).toInt()}%',
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Footer info row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⭐ +50 XP per misi',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFFC95A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      progressPct >= 1.0 ? 'Bilik Selesai' : 'Misi berikutnya siap',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5D6785),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () async {
                    final targetTab = await Navigator.push<int>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LevelMapScreen(
                          bilik: bilik,
                          totalLevels: totalLevels,
                        ),
                      ),
                    );
                    _refreshProgress();
                    if (targetTab != null && widget.onNavigate != null) {
                      widget.onNavigate!(targetTab);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: brandColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: brandColor.withOpacity(0.35),
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          progressPct >= 1.0 ? 'Jelajahi Bilik' : 'Mulai Petualangan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomIllustration(String bilikId) {
    // Generate simplified visual representation matching SVG curves
    if (bilikId == 'akademik') {
      return Container(
        width: 180,
        height: 158,
        child: Stack(
          children: [
            // Cloud 1
            Positioned(
              left: 20,
              top: 20,
              child: Opacity(
                opacity: 0.68,
                child: Container(
                  width: 44,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            // Cloud 2
            Positioned(
              right: 20,
              top: 10,
              child: Opacity(
                opacity: 0.48,
                child: Container(
                  width: 32,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
            ),
            // School Building block
            Positioned(
              right: 15,
              bottom: 20,
              child: Container(
                width: 76,
                height: 78,
                decoration: BoxDecoration(
                  color: const Color(0xFF4B5DFF).withOpacity(0.88),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Stack(
                  children: [
                    // Doors
                    Positioned(
                      bottom: 0,
                      left: 27,
                      child: Container(
                        width: 22,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.52),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                        ),
                      ),
                    ),
                    // Windows
                    Positioned(
                      top: 16,
                      left: 10,
                      child: Row(
                        children: List.generate(3, (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 14,
                          height: 13,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(3.5),
                          ),
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Tree
            Positioned(
              right: 90,
              bottom: 20,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF72D7B2).withOpacity(0.92),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: 180,
        height: 158,
        child: Stack(
          children: [
            // Building Block
            Positioned(
              right: 15,
              bottom: 10,
              child: Container(
                width: 76,
                height: 132,
                decoration: BoxDecoration(
                  color: const Color(0xFF8C6CFF).withOpacity(0.82),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (idx) => Container(
                      width: 12,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(index < 2 ? 0.55 : 0.22),
                        borderRadius: BorderRadius.circular(3.5),
                      ),
                    )),
                  )),
                ),
              ),
            ),
            // Laptop Block
            Positioned(
              left: 20,
              bottom: 15,
              child: Container(
                width: 58,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF6240BE).withOpacity(0.74),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
