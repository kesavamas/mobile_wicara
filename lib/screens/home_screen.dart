import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/models/bilik.dart';
import 'package:wicara_application_1/services/api_service.dart';
import 'package:wicara_application_1/services/session_service.dart';
import 'package:wicara_application_1/screens/login_screen.dart';
import 'package:wicara_application_1/screens/level_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
      backgroundColor: const Color(0xFFF7F7F2),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refreshProgress,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _openEditProfileSheet,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: _parseColor(
                                  _avatar['color'] ?? '#3B82F6',
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Center(
                                child: Icon(
                                  getAvatarIcon(_avatar['emoji'] ?? 'face'),
                                  size: 26,
                                  color: _parseColor(_avatar['color'] ?? '#3B82F6'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, $_studentId',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  'Pilih bilik dan lanjutkan latihanmu',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Keluar',
                            onPressed: _handleLogout,
                            icon: const Icon(Icons.logout_rounded),
                            color: const Color(0xFF475569),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withOpacity(0.18),
                              blurRadius: 26,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'PROGRES BELAJAR',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFFFDE68A),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Color(0xFFF59E0B),
                                  size: 22,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              '$_totalCompleted dari $_totalLevels level selesai',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                minHeight: 9,
                                value: _totalLevels == 0
                                    ? 0
                                    : _totalCompleted / _totalLevels,
                                backgroundColor: Colors.white.withOpacity(0.16),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFF59E0B),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Susun kalimat formal lewat cerita singkat, lalu lihat pola SPOK-nya dengan jelas.',
                              style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.78),
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Bilik latihan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _biliks.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final bilik = _biliks[index];
                          final completed = _getCompletedCount(bilik.id);
                          final totalLevels = _levelCounts[bilik.id] ?? 0;
                          final progressPct = totalLevels == 0
                              ? 0.0
                              : completed / totalLevels;
                          final brandColor = _parseColor(bilik.color);
                          final softBgColor = _parseColor(
                            bilik.colorTheme.soft,
                          );
                          final inkColor = _parseColor(bilik.colorTheme.ink);

                          return InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LevelMapScreen(
                                    bilik: bilik,
                                    totalLevels: totalLevels,
                                  ),
                                ),
                              );
                              _refreshProgress();
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Ink(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: _parseColor(bilik.colorTheme.border),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: brandColor.withOpacity(0.08),
                                    blurRadius: 22,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 66,
                                    height: 74,
                                    decoration: BoxDecoration(
                                      color: softBgColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: brandColor.withOpacity(0.12),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        bilik.icon,
                                        style: const TextStyle(fontSize: 31),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                bilik.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: const Color(
                                                        0xFF0F172A,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: brandColor.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                '$completed/$totalLevels',
                                                style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w900,
                                                  color: inkColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          bilik.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: const Color(0xFF64748B),
                                            height: 1.35,
                                          ),
                                        ),
                                        const SizedBox(height: 11),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                                child: LinearProgressIndicator(
                                                  minHeight: 7,
                                                  value: progressPct,
                                                  backgroundColor: const Color(
                                                    0xFFE2E8F0,
                                                  ),
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(brandColor),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Icon(
                                              Icons.chevron_right_rounded,
                                              color: brandColor,
                                              size: 22,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
