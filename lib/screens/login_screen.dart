import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/core/theme/app_colors.dart';
import 'package:wicara_application_1/screens/main_layout.dart';
import 'package:wicara_application_1/services/api_service.dart';
import 'package:wicara_application_1/services/session_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _tokenController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tokenFocusNode = FocusNode();

  bool _isRegistering = false;
  bool _isLoading = false;
  bool _isDemoLoading = false;
  bool _passwordHidden = true;
  String? _errorMessage;

  String _selectedEmoji = 'face';
  String _selectedColor = '#F59E0B';

  static const _avatars = ['face', 'robot', 'paw', 'rabbit', 'star'];
  static const _colors = [
    '#F59E0B',
    '#3B82F6',
    '#EF4444',
    '#10B981',
    '#8B5CF6',
  ];

  @override
  void initState() {
    super.initState();
    _tokenController.addListener(_refresh);
    _nicknameController.addListener(_refresh);
    _passwordController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tokenController
      ..removeListener(_refresh)
      ..dispose();
    _nicknameController
      ..removeListener(_refresh)
      ..dispose();
    _passwordController
      ..removeListener(_refresh)
      ..dispose();
    _tokenFocusNode.dispose();
    super.dispose();
  }

  bool get _loginReady =>
      _tokenController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty;

  bool get _registerReady =>
      _nicknameController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty;

  Color _parseColor(String hex) {
    final value = hex.replaceAll('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }

  IconData _avatarIcon(String key) {
    switch (key) {
      case 'robot':
        return Icons.smart_toy_rounded;
      case 'paw':
        return Icons.pets_rounded;
      case 'rabbit':
        return Icons.cruelty_free_rounded;
      case 'star':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.face_rounded;
    }
  }

  Future<void> _handleLogin() async {
    final token = _tokenController.text.trim();
    final password = _passwordController.text;

    if (token.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Token dan password wajib diisi');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ApiService.login(token, password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const MainLayout()),
      );
    } else {
      setState(() {
        _errorMessage =
            ApiService.lastError ??
            'Token belum ditemukan. Hubungi guru atau periksa kembali datanya.';
      });
    }
  }

  Future<void> _handleDemoLogin() async {
    setState(() {
      _isDemoLoading = true;
      _errorMessage = null;
    });
    await SessionService.saveDemoSession();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainLayout()),
    );
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
      setState(() => _errorMessage = 'Nama panggilan minimal 2 karakter');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password minimal 6 karakter');
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
    setState(() => _isLoading = false);

    if (token == null) {
      setState(() {
        _errorMessage = ApiService.lastError ?? 'Registrasi belum berhasil.';
      });
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
          size: 46,
        ),
        title: const Text('Akun berhasil dibuat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Simpan token berikut untuk masuk kembali ke WICARA.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.softBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: SelectableText(
                token,
                textAlign: TextAlign.center,
                style: GoogleFonts.robotoMono(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Mulai Belajar'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainLayout()),
    );
  }

  Future<void> _showQrInformation() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.indigo,
                size: 54,
              ),
              const SizedBox(height: 12),
              Text(
                'Masuk dengan QR Code',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pemindaian kamera belum diaktifkan pada versi ini. Gunakan token yang tercetak di bawah QR Code dari guru.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text2,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _tokenFocusNode.requestFocus();
                },
                child: const Text('Masukkan Token'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showTeacherHelp() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.support_agent_rounded,
          color: AppColors.indigo,
          size: 38,
        ),
        title: const Text('Minta bantuan guru'),
        content: const Text(
          'Mintalah token dan password kepada guru. Pastikan token berasal dari sekolahmu.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 46,
                  ),
                  child: _isRegistering
                      ? _buildRegistrationView()
                      : _buildLoginView(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Image.asset(
          'assets/logo.png',
          width: 158,
          height: 158,
          semanticLabel: 'Logo WICARA',
        ),
        const SizedBox(height: 13),
        Text(
          'Masuk ke Kelasmu',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Gunakan token dan password yang diberikan oleh guru untuk memulai belajar.',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunitoSans(
            fontSize: 13,
            height: 1.5,
            fontWeight: FontWeight.w700,
            color: AppColors.text2,
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(19),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFD7DEF1)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1424304A),
                blurRadius: 26,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _fieldLabel('Token dari Guru'),
              const SizedBox(height: 7),
              TextField(
                controller: _tokenController,
                focusNode: _tokenFocusNode,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  TextInputFormatter.withFunction(
                    (oldValue, newValue) =>
                        newValue.copyWith(text: newValue.text.toUpperCase()),
                  ),
                ],
                style: GoogleFonts.robotoMono(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
                decoration: _inputDecoration(
                  hint: 'Contoh: WCR-8K2P',
                  icon: Icons.badge_outlined,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Gunakan huruf kapital seperti pada token.',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                  Text(
                    '${_tokenController.text.length} karakter',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _fieldLabel('Password'),
              const SizedBox(height: 7),
              TextField(
                controller: _passwordController,
                obscureText: _passwordHidden,
                enableSuggestions: false,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) =>
                    _loginReady && !_isLoading ? _handleLogin() : null,
                style: GoogleFonts.nunitoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
                decoration: _inputDecoration(
                  hint: 'Masukkan password',
                  icon: Icons.lock_outline_rounded,
                  suffix: IconButton(
                    tooltip: _passwordHidden
                        ? 'Tampilkan password'
                        : 'Sembunyikan password',
                    onPressed: () =>
                        setState(() => _passwordHidden = !_passwordHidden),
                    icon: Icon(
                      _passwordHidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 13),
                _ErrorPanel(message: _errorMessage!),
              ],
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _loginReady && !_isLoading && !_isDemoLoading
                    ? _handleLogin
                    : null,
                iconAlignment: IconAlignment.end,
                icon: _isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  _isLoading ? 'Memeriksa akun...' : 'Masuk ke Kelas',
                ),
                style: _primaryButtonStyle(),
              ),
              const SizedBox(height: 17),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.line)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'atau',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.line)),
                ],
              ),
              const SizedBox(height: 15),
              OutlinedButton.icon(
                onPressed: _showQrInformation,
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Pindai Kode QR'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  backgroundColor: const Color(0xFFFAFBFF),
                  side: const BorderSide(color: Color(0xFFD7DEF1)),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Tidak menerima token?',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunitoSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
          ),
        ),
        TextButton(
          onPressed: _showTeacherHelp,
          child: const Text('Minta bantuan guru'),
        ),
        TextButton.icon(
          onPressed: _isLoading || _isDemoLoading ? null : _handleDemoLogin,
          icon: _isDemoLoading
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.play_circle_outline_rounded),
          label: Text(
            _isDemoLoading ? 'Menyiapkan akun demo...' : 'Coba akun demo',
          ),
        ),
        TextButton(
          onPressed: _isLoading || _isDemoLoading
              ? null
              : () {
                  _passwordController.clear();
                  setState(() {
                    _isRegistering = true;
                    _errorMessage = null;
                  });
                },
          child: const Text('Buat akun latihan'),
        ),
        const SizedBox(height: 5),
        Text(
          'Pastikan token berasal dari guru atau sekolahmu.',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunitoSans(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFB0B8CE),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton.filledTonal(
            tooltip: 'Kembali ke login',
            onPressed: () {
              _passwordController.clear();
              setState(() {
                _isRegistering = false;
                _errorMessage = null;
              });
            },
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        Image.asset(
          'assets/logo.png',
          width: 105,
          height: 105,
          semanticLabel: 'Logo WICARA',
        ),
        const SizedBox(height: 10),
        Text(
          'Buat Akun Latihan',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Fitur lama tetap tersedia untuk membuat akun latihan baru.',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w700,
            color: AppColors.text2,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(19),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFD7DEF1)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1424304A),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _fieldLabel('Nama panggilan'),
              const SizedBox(height: 7),
              TextField(
                controller: _nicknameController,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  hint: 'Contoh: Budi',
                  icon: Icons.person_outline_rounded,
                ),
              ),
              const SizedBox(height: 15),
              _fieldLabel('Buat password'),
              const SizedBox(height: 7),
              TextField(
                controller: _passwordController,
                obscureText: _passwordHidden,
                textInputAction: TextInputAction.done,
                decoration: _inputDecoration(
                  hint: 'Minimal 6 karakter',
                  icon: Icons.lock_outline_rounded,
                  suffix: IconButton(
                    tooltip: _passwordHidden
                        ? 'Tampilkan password'
                        : 'Sembunyikan password',
                    onPressed: () =>
                        setState(() => _passwordHidden = !_passwordHidden),
                    icon: Icon(
                      _passwordHidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _fieldLabel('Pilih avatar'),
              const SizedBox(height: 9),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 8,
                runSpacing: 8,
                children: _avatars.map((avatar) {
                  final selected = avatar == _selectedEmoji;
                  return Semantics(
                    button: true,
                    selected: selected,
                    label: 'Avatar $avatar',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () => setState(() => _selectedEmoji = avatar),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 49,
                        height: 49,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.softBlue
                              : const Color(0xFFF5F7FB),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: selected ? AppColors.indigo : AppColors.line,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          _avatarIcon(avatar),
                          color: selected ? AppColors.indigo : AppColors.muted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              _fieldLabel('Pilih warna profil'),
              const SizedBox(height: 9),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 8,
                runSpacing: 8,
                children: _colors.map((hex) {
                  final selected = hex == _selectedColor;
                  final color = _parseColor(hex);
                  return Semantics(
                    button: true,
                    selected: selected,
                    label: 'Warna profil $hex',
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => setState(() => _selectedColor = hex),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? AppColors.ink : Colors.white,
                            width: selected ? 3 : 2,
                          ),
                        ),
                        child: selected
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                _ErrorPanel(message: _errorMessage!),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _registerReady && !_isLoading
                    ? _handleRegister
                    : null,
                iconAlignment: IconAlignment.end,
                icon: _isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  _isLoading ? 'Membuat akun...' : 'Buat Akun dan Masuk',
                ),
                style: _primaryButtonStyle(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.nunitoSans(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: AppColors.ink,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.nunitoSans(
        color: const Color(0xFFB6C0DB),
        fontWeight: FontWeight.w700,
      ),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(9),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.softBlue,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 19, color: AppColors.indigo),
        ),
      ),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD7DEF1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD7DEF1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.indigo, width: 1.8),
      ),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: AppColors.indigo,
      disabledBackgroundColor: const Color(0xFFDDE2F0),
      foregroundColor: Colors.white,
      disabledForegroundColor: const Color(0xFF8A96B3),
      minimumSize: const Size.fromHeight(54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      textStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final String message;

  const _ErrorPanel({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.softCoral,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF4C9D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 19,
            color: AppColors.danger,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.nunitoSans(
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w800,
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
