import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/core/theme/app_colors.dart';
import 'package:wicara_application_1/features/shared/widgets/fun_ui_components.dart';
import 'package:wicara_application_1/features/shared/widgets/wicara_illustration_icon.dart';
import 'package:wicara_application_1/screens/focus_screen.dart';

class _DictionaryEntry {
  final String keyName;
  final String name;
  final String question;
  final String description;
  final List<String> words;
  final WicaraIllustrationType illustration;
  final Color accent;
  final Color softColor;

  const _DictionaryEntry({
    required this.keyName,
    required this.name,
    required this.question,
    required this.description,
    required this.words,
    required this.illustration,
    required this.accent,
    required this.softColor,
  });
}

class ColorDictionaryScreen extends StatefulWidget {
  final bool showBackButton;

  const ColorDictionaryScreen({super.key, this.showBackButton = false});

  @override
  State<ColorDictionaryScreen> createState() => _ColorDictionaryScreenState();
}

class _ColorDictionaryScreenState extends State<ColorDictionaryScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _active = 'all';
  String _query = '';
  String? _selectedSentenceRole;

  static const _entries = <_DictionaryEntry>[
    _DictionaryEntry(
      keyName: 's',
      name: 'Subjek',
      question: 'Siapa yang melakukan?',
      description: 'Orang atau benda yang melakukan kegiatan.',
      words: ['Saya', 'Raka', 'Ibu', 'Mereka'],
      illustration: WicaraIllustrationType.subject,
      accent: Color(0xFF3D73DB),
      softColor: Color(0xFFEAF2FF),
    ),
    _DictionaryEntry(
      keyName: 'p',
      name: 'Predikat',
      question: 'Apa yang dilakukan?',
      description: 'Kegiatan atau keadaan yang sedang dilakukan.',
      words: ['Membaca', 'Belajar', 'Menulis', 'Datang'],
      illustration: WicaraIllustrationType.predicate,
      accent: Color(0xFFD94865),
      softColor: Color(0xFFFFECEF),
    ),
    _DictionaryEntry(
      keyName: 'o',
      name: 'Objek',
      question: 'Apa yang dikenai kegiatan?',
      description: 'Benda atau hal yang dikenai kegiatan.',
      words: ['Buku', 'Pesan', 'Tugas', 'Proyektor'],
      illustration: WicaraIllustrationType.object,
      accent: Color(0xFFC28A00),
      softColor: Color(0xFFFFF4CC),
    ),
    _DictionaryEntry(
      keyName: 'k',
      name: 'Keterangan',
      question: 'Kapan, di mana, atau mengapa?',
      description: 'Menjelaskan waktu, tempat, cara, atau alasan.',
      words: ['Hari ini', 'Di sekolah', 'Karena sakit', 'Dengan sopan'],
      illustration: WicaraIllustrationType.adverb,
      accent: Color(0xFF19845F),
      softColor: Color(0xFFE8F8F1),
    ),
    _DictionaryEntry(
      keyName: 'pel',
      name: 'Pelengkap',
      question: 'Apa yang melengkapi makna?',
      description: 'Bagian tambahan agar makna predikat menjadi utuh.',
      words: ['Untuk belajar', 'Menjadi ketua', 'Kepada Ibu'],
      illustration: WicaraIllustrationType.practice,
      accent: Color(0xFF6C4FD3),
      softColor: Color(0xFFF1EDFF),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<(_DictionaryEntry, String)> get _visibleWords {
    final needle = _query.trim().toLowerCase();
    return [
      for (final entry in _entries)
        if (_active == 'all' || entry.keyName == _active)
          for (final word in entry.words)
            if (needle.isEmpty ||
                word.toLowerCase().contains(needle) ||
                entry.name.toLowerCase().contains(needle) ||
                entry.description.toLowerCase().contains(needle))
              (entry, word),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final words = _visibleWords;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: FunPageHeader(
                  title: 'Kamus Warna Kata',
                  subtitle:
                      'Pelajari fungsi kata dengan warna yang mudah dipahami.',
                  illustration: WicaraIllustrationType.dictionary,
                  showBackButton: widget.showBackButton,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                sliver: SliverToBoxAdapter(child: _buildSearch()),
              ),
              SliverToBoxAdapter(child: _buildFilters()),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: FunSectionHeader(
                    title: 'Koleksi Kata',
                    subtitle: 'Tekan kategori untuk memusatkan latihanmu.',
                  ),
                ),
              ),
              if (words.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: FriendlyEmptyState(
                      title: 'Kata belum ditemukan',
                      message: 'Coba cari kata lain, ya.',
                      illustration: WicaraIllustrationType.empty,
                      action: Column(
                        children: [
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 7,
                            runSpacing: 7,
                            children: [
                              for (final suggestion in const [
                                'Saya',
                                'Membaca',
                                'Sekolah',
                                'Kapan',
                              ])
                                ActionChip(
                                  label: Text(suggestion),
                                  onPressed: () {
                                    _searchController.text = suggestion;
                                    setState(() => _query = suggestion);
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          FilledButton.icon(
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.close_rounded),
                            label: const Text('Hapus Pencarian'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList.separated(
                    itemCount: words.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = words[index];
                      return _DictionaryWordCard(
                        entry: item.$1,
                        word: item.$2,
                        onTap: () => _showWordDetails(item.$1, item.$2),
                      );
                    },
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                sliver: SliverToBoxAdapter(child: _buildSentenceExample()),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 132),
                sliver: SliverToBoxAdapter(child: _buildFocusAction(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _searchFocus.hasFocus ? AppColors.indigo : AppColors.line,
          width: _searchFocus.hasFocus ? 1.7 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1F2858),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        onChanged: (value) => setState(() => _query = value),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Cari kata atau fungsi kalimat',
          hintStyle: GoogleFonts.nunitoSans(
            color: AppColors.muted,
            fontWeight: FontWeight.w700,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.all(9),
            child: WicaraIllustrationIcon(
              type: WicaraIllustrationType.search,
              size: 36,
              showBackground: false,
            ),
          ),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Hapus pencarian',
                  onPressed: () {
                    _clearSearch();
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 17),
        ),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  String _exampleFor(_DictionaryEntry entry, String word) {
    switch (entry.keyName) {
      case 's':
        return '$word membaca buku di perpustakaan.';
      case 'p':
        return 'Saya ${word.toLowerCase()} buku hari ini.';
      case 'o':
        return 'Saya membaca ${word.toLowerCase()} di sekolah.';
      case 'k':
        return 'Saya belajar ${word.toLowerCase()}.';
      default:
        return 'Kalimat ini digunakan ${word.toLowerCase()}.';
    }
  }

  Future<void> _showWordDetails(_DictionaryEntry entry, String word) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  WicaraIllustrationIcon(
                    type: entry.illustration,
                    size: 64,
                    accent: entry.accent,
                    background: entry.softColor,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          word.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          '${entry.name} (${entry.keyName.toUpperCase()})',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: entry.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup',
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _WordDetailSection(
                title: 'Fungsi',
                text: entry.description,
                color: entry.softColor,
              ),
              const SizedBox(height: 10),
              _WordDetailSection(
                title: 'Contoh Kalimat',
                text: _exampleFor(entry, word),
                color: entry.softColor,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  setState(() => _selectedSentenceRole = entry.keyName);
                },
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Lihat dalam Kalimat'),
                style: FilledButton.styleFrom(
                  backgroundColor: entry.accent,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const FocusScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.extension_outlined),
                label: const Text('Latih Kata Ini'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = <(String, String, WicaraIllustrationType, Color)>[
      ('all', 'Semua', WicaraIllustrationType.dictionary, AppColors.indigo),
      for (final entry in _entries)
        (entry.keyName, entry.name, entry.illustration, entry.accent),
    ];
    return SizedBox(
      height: 64,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = _active == filter.$1;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: selected
                  ? Color.lerp(filter.$4, Colors.white, 0.82)
                  : Colors.white,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: selected ? filter.$4 : AppColors.line,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(99),
              onTap: () => setState(() => _active = filter.$1),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(7, 5, 13, 5),
                child: Row(
                  children: [
                    WicaraIllustrationIcon(
                      type: filter.$3,
                      size: 28,
                      accent: filter.$4,
                      showBackground: false,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      filter.$2,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: selected ? filter.$4 : AppColors.text2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSentenceExample() {
    const phrases = <(String, String, String, Color, Color)>[
      ('Saya', 's', 'Subjek', Color(0xFFEAF2FF), Color(0xFF245BB7)),
      ('membaca', 'p', 'Predikat', Color(0xFFFFECEF), Color(0xFFB8324B)),
      ('buku', 'o', 'Objek', Color(0xFFFFF4CC), Color(0xFF8A6300)),
      (
        'di perpustakaan.',
        'k',
        'Keterangan',
        Color(0xFFE8F8F1),
        Color(0xFF176B50),
      ),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONTOH KALIMAT',
            style: GoogleFonts.nunitoSans(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 7,
            children: [
              for (final phrase in phrases)
                Semantics(
                  button: true,
                  label: '${phrase.$1}, ${phrase.$3}',
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedSentenceRole = phrase.$2),
                    child: AnimatedScale(
                      scale: _selectedSentenceRole == phrase.$2 ? 1.08 : 1,
                      duration: const Duration(milliseconds: 180),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: phrase.$4,
                          borderRadius: BorderRadius.circular(10),
                          border: _selectedSentenceRole == phrase.$2
                              ? Border.all(color: phrase.$5, width: 2)
                              : null,
                        ),
                        child: Text(
                          phrase.$1,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: phrase.$5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _selectedSentenceRole == null
                ? 'Tekan setiap kata untuk melihat perannya dalam SPOK.'
                : '${phrases.firstWhere((item) => item.$2 == _selectedSentenceRole).$3}: ${_entries.firstWhere((item) => item.keyName == _selectedSentenceRole).description}',
            style: GoogleFonts.nunitoSans(
              fontSize: 11,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const FocusScreen()),
            ),
            icon: const Icon(Icons.extension_outlined),
            label: const Text('Coba Susun Kalimat'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white38),
              minimumSize: const Size.fromHeight(46),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusAction(BuildContext context) {
    return Material(
      color: AppColors.softPurple,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const FocusScreen())),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const WicaraIllustrationIcon(
                type: WicaraIllustrationType.practice,
                size: 50,
                accent: AppColors.purple,
                background: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lihat Pohon Kalimat',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      'Pelajari hubungan setiap bagian kalimat.',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text2,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: AppColors.purple),
            ],
          ),
        ),
      ),
    );
  }
}

class _DictionaryWordCard extends StatelessWidget {
  final _DictionaryEntry entry;
  final String word;
  final VoidCallback onTap;

  const _DictionaryWordCard({
    required this.entry,
    required this.word,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      semanticLabel: 'Buka detail kata $word',
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: entry.accent.withValues(alpha: 0.18)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x091F2858),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: entry.accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    WicaraIllustrationIcon(
                      type: entry.illustration,
                      size: 54,
                      accent: entry.accent,
                      background: entry.softColor,
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            word.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 7,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: entry.softColor,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  entry.name,
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: entry.accent,
                                  ),
                                ),
                              ),
                              Text(
                                entry.question,
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            entry.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 10,
                              height: 1.3,
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordDetailSection extends StatelessWidget {
  final String title;
  final String text;
  final Color color;

  const _WordDetailSection({
    required this.title,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunitoSans(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.text2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: GoogleFonts.nunitoSans(
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
