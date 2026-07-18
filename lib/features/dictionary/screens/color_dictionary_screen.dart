import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/core/theme/app_colors.dart';
import 'package:wicara_application_1/data/repositories/revision3_content_repository.dart';
import 'package:wicara_application_1/features/case_map/screens/case_map_screen.dart';
import 'package:wicara_application_1/features/dictionary/data/dictionary_catalog.dart';
import 'package:wicara_application_1/features/dictionary/models/dictionary_word.dart';
import 'package:wicara_application_1/features/dictionary/repositories/dictionary_learning_repository.dart';
import 'package:wicara_application_1/features/dictionary/screens/dictionary_practice_screen.dart';
import 'package:wicara_application_1/features/shared/widgets/fun_ui_components.dart';
import 'package:wicara_application_1/features/shared/widgets/wicara_illustration_icon.dart';
import 'package:wicara_application_1/screens/focus_screen.dart';

class _DictionaryEntry {
  final String keyName;
  final String name;
  final String question;
  final String description;
  final DictionaryRole role;
  final WicaraIllustrationType illustration;
  final Color accent;
  final Color softColor;

  const _DictionaryEntry({
    required this.keyName,
    required this.name,
    required this.question,
    required this.description,
    required this.role,
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
  final _sentenceSectionKey = GlobalKey();
  final _learningRepository = DictionaryLearningRepository();
  String _active = 'all';
  String _query = '';
  String? _selectedSentenceRole;
  bool _favoritesOnly = false;
  bool _loadingLearningState = true;
  DictionaryLearningState _learningState = const DictionaryLearningState();

  static const _entries = <_DictionaryEntry>[
    _DictionaryEntry(
      keyName: 's',
      name: 'Subjek',
      question: 'Siapa yang melakukan?',
      description: 'Orang atau benda yang melakukan kegiatan.',
      role: DictionaryRole.subject,
      illustration: WicaraIllustrationType.subject,
      accent: Color(0xFF3D73DB),
      softColor: Color(0xFFEAF2FF),
    ),
    _DictionaryEntry(
      keyName: 'p',
      name: 'Predikat',
      question: 'Apa yang dilakukan?',
      description: 'Kegiatan atau keadaan yang sedang dilakukan.',
      role: DictionaryRole.predicate,
      illustration: WicaraIllustrationType.predicate,
      accent: Color(0xFFD94865),
      softColor: Color(0xFFFFECEF),
    ),
    _DictionaryEntry(
      keyName: 'o',
      name: 'Objek',
      question: 'Apa yang dikenai kegiatan?',
      description: 'Benda atau hal yang dikenai kegiatan.',
      role: DictionaryRole.object,
      illustration: WicaraIllustrationType.object,
      accent: Color(0xFFC28A00),
      softColor: Color(0xFFFFF4CC),
    ),
    _DictionaryEntry(
      keyName: 'k',
      name: 'Keterangan',
      question: 'Kapan, di mana, atau mengapa?',
      description: 'Menjelaskan waktu, tempat, cara, atau alasan.',
      role: DictionaryRole.adverb,
      illustration: WicaraIllustrationType.adverb,
      accent: Color(0xFF19845F),
      softColor: Color(0xFFE8F8F1),
    ),
    _DictionaryEntry(
      keyName: 'pel',
      name: 'Pelengkap',
      question: 'Apa yang melengkapi makna?',
      description: 'Bagian tambahan agar makna predikat menjadi utuh.',
      role: DictionaryRole.complement,
      illustration: WicaraIllustrationType.practice,
      accent: Color(0xFF6C4FD3),
      softColor: Color(0xFFF1EDFF),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() => setState(() {}));
    _loadLearningState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadLearningState() async {
    final state = await _learningRepository.load();
    if (!mounted) return;
    setState(() {
      _learningState = state;
      _loadingLearningState = false;
    });
  }

  _DictionaryEntry _entryFor(DictionaryRole role) =>
      _entries.firstWhere((entry) => entry.role == role);

  List<DictionaryWord> get _visibleWords {
    final needle = _query.trim().toLowerCase();
    return DictionaryCatalog.words
        .where((word) {
          final matchesCategory = _active == 'all' || word.role.id == _active;
          final matchesFavorite =
              !_favoritesOnly || _learningState.favoriteIds.contains(word.id);
          final matchesQuery =
              needle.isEmpty ||
              word.word.toLowerCase().contains(needle) ||
              word.role.label.toLowerCase().contains(needle) ||
              word.meaning.toLowerCase().contains(needle) ||
              word.contextLabel.toLowerCase().contains(needle) ||
              (word.missionTitle?.toLowerCase().contains(needle) ?? false);
          return matchesCategory && matchesFavorite && matchesQuery;
        })
        .toList(growable: false);
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
                sliver: SliverToBoxAdapter(child: _buildLearningSummary()),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                sliver: SliverToBoxAdapter(child: _buildSearch()),
              ),
              SliverToBoxAdapter(child: _buildFilters()),
              if (_learningState.recentIds.isNotEmpty &&
                  !_favoritesOnly &&
                  _query.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 12),
                  sliver: SliverToBoxAdapter(child: _buildRecentWords()),
                ),
              if (!_favoritesOnly && _query.isEmpty && !_loadingLearningState)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  sliver: SliverToBoxAdapter(child: _buildRecommendation()),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: FunSectionHeader(
                    title: _favoritesOnly ? 'Kata Tersimpan' : 'Koleksi Kata',
                    subtitle: _favoritesOnly
                        ? 'Kata yang ingin kamu pelajari kembali.'
                        : 'Tekan kategori untuk memusatkan latihanmu.',
                  ),
                ),
              ),
              if (words.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: FriendlyEmptyState(
                      title: _favoritesOnly
                          ? 'Belum ada kata tersimpan'
                          : 'Kata belum ditemukan',
                      message: _favoritesOnly
                          ? 'Simpan kata dari koleksi agar mudah dipelajari lagi.'
                          : 'Coba cari kata lain, ya.',
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
                                'Hari ini',
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
                            onPressed: () {
                              _clearSearch();
                              setState(() => _favoritesOnly = false);
                            },
                            icon: const Icon(Icons.close_rounded),
                            label: Text(
                              _favoritesOnly
                                  ? 'Lihat Semua Kata'
                                  : 'Hapus Pencarian',
                            ),
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
                      final entry = _entryFor(item.role);
                      return _DictionaryWordCard(
                        entry: entry,
                        word: item,
                        progress: _learningState.progressFor(item.id),
                        favorite: _learningState.favoriteIds.contains(item.id),
                        onFavorite: () => _toggleFavorite(item.id),
                        onTap: () => _showWordDetails(item),
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

  Widget _buildLearningSummary() {
    final mastered = DictionaryCatalog.words
        .where(
          (word) =>
              _learningState.progressFor(word.id).mastery ==
              DictionaryMastery.mastered,
        )
        .length;
    final practicing = DictionaryCatalog.words
        .where(
          (word) =>
              _learningState.progressFor(word.id).mastery ==
              DictionaryMastery.practicing,
        )
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD8E2FF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const WicaraIllustrationIcon(
                type: WicaraIllustrationType.practice,
                size: 45,
                accent: AppColors.indigo,
                background: Colors.white,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perjalanan Katamu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      'Buka kata, berlatih, lalu kuasai penggunaannya.',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 10,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          if (_loadingLearningState)
            const LinearProgressIndicator(
              minHeight: 5,
              color: AppColors.indigo,
              backgroundColor: Colors.white,
            )
          else
            Row(
              children: [
                Expanded(
                  child: _LearningStat(
                    value: '$mastered',
                    label: 'Dikuasai',
                    icon: Icons.verified_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: _LearningStat(
                    value: '$practicing',
                    label: 'Dilatih',
                    icon: Icons.school_rounded,
                    color: AppColors.purple,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: _LearningStat(
                    value: '${_learningState.favoriteIds.length}',
                    label: _favoritesOnly ? 'Tersimpan aktif' : 'Tersimpan',
                    icon: _favoritesOnly
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    color: AppColors.indigo,
                    selected: _favoritesOnly,
                    onTap: () => setState(() {
                      _favoritesOnly = !_favoritesOnly;
                      _active = 'all';
                    }),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRecentWords() {
    final recentWords = _learningState.recentIds
        .map(DictionaryCatalog.byId)
        .whereType<DictionaryWord>()
        .toList(growable: false);
    if (recentWords.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Terakhir Dipelajari',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recentWords.length,
            separatorBuilder: (_, _) => const SizedBox(width: 7),
            itemBuilder: (context, index) {
              final word = recentWords[index];
              final entry = _entryFor(word.role);
              return ActionChip(
                avatar: CircleAvatar(
                  backgroundColor: entry.softColor,
                  child: Text(
                    word.role.shortLabel,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: entry.accent,
                    ),
                  ),
                ),
                label: Text(word.word),
                onPressed: () => _showWordDetails(word),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendation() {
    DictionaryWord? recommended;
    for (final word in DictionaryCatalog.words) {
      if (_learningState.progressFor(word.id).mastery ==
          DictionaryMastery.practicing) {
        recommended = word;
        break;
      }
    }
    recommended ??= DictionaryCatalog.words.firstWhere(
      (word) =>
          _learningState.progressFor(word.id).mastery ==
          DictionaryMastery.newWord,
      orElse: () => DictionaryCatalog.words.first,
    );
    final entry = _entryFor(recommended.role);
    final progress = _learningState.progressFor(recommended.id);

    return Material(
      color: entry.softColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => _openPractice(recommended!),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              WicaraIllustrationIcon(
                type: entry.illustration,
                size: 46,
                accent: entry.accent,
                background: Colors.white,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      progress.attempts == 0
                          ? 'Kata untuk dipelajari'
                          : 'Lanjutkan latihanmu',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: entry.accent,
                      ),
                    ),
                    Text(
                      recommended.word,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      progress.attempts == 0
                          ? '${entry.name} · sekitar 1 menit'
                          : 'Nilai terakhir ${progress.lastScore} · coba sekali lagi',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text2,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: entry.accent),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(String wordId) async {
    final isFavorite = await _learningRepository.toggleFavorite(wordId);
    await _loadLearningState();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? 'Kata disimpan ke koleksi.'
              : 'Kata dihapus dari koleksi.',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
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

  Future<void> _openPractice(DictionaryWord word) async {
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => DictionaryPracticeScreen(word: word),
      ),
    );
    if (completed == true) await _loadLearningState();
  }

  void _showSentenceRole(String roleId) {
    setState(() => _selectedSentenceRole = roleId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sectionContext = _sentenceSectionKey.currentContext;
      if (sectionContext == null) return;
      Scrollable.ensureVisible(
        sectionContext,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        alignment: 0.18,
      );
    });
  }

  Future<void> _openRelatedMission(DictionaryWord word) async {
    final missionId = word.missionId;
    if (missionId == null) return;
    final content = await Revision3ContentRepository.load();
    final mission = content.missions
        .where((item) => item.id == missionId)
        .first;
    final bilik = content.biliks
        .where((item) => item.id == mission.bilikId)
        .first;
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CaseMapScreen(
          bilik: bilik,
          missions: Revision3ContentRepository.missionsFor(content, bilik.id),
        ),
      ),
    );
  }

  Future<void> _showWordDetails(DictionaryWord word) async {
    final entry = _entryFor(word.role);
    await _learningRepository.markViewed(word.id);
    await _loadLearningState();
    if (!mounted) return;
    var isFavorite = _learningState.favoriteIds.contains(word.id);
    final progress = _learningState.progressFor(word.id);

    final action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          top: false,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.88,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                              word.word.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            Wrap(
                              spacing: 7,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  '${entry.name} (${entry.keyName.toUpperCase()})',
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: entry.accent,
                                  ),
                                ),
                                _MasteryBadge(
                                  mastery: progress.mastery,
                                  compact: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: isFavorite
                            ? 'Hapus dari koleksi'
                            : 'Simpan kata',
                        onPressed: () async {
                          final next = await _learningRepository.toggleFavorite(
                            word.id,
                          );
                          setSheetState(() => isFavorite = next);
                          await _loadLearningState();
                        },
                        icon: Icon(
                          isFavorite
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline_rounded,
                          color: isFavorite
                              ? AppColors.indigo
                              : AppColors.muted,
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
                    title: 'Arti Sederhana',
                    text: word.meaning,
                    color: entry.softColor,
                  ),
                  const SizedBox(height: 10),
                  _WordDetailSection(
                    title: 'Fungsi dalam Kalimat',
                    text: word.usage,
                    color: entry.softColor,
                  ),
                  const SizedBox(height: 10),
                  _WordDetailSection(
                    title: 'Contoh Kalimat',
                    text: word.example,
                    color: entry.softColor,
                  ),
                  const SizedBox(height: 10),
                  _MessageComparison(
                    everyday: word.everydayExample,
                    formal: word.formalExample,
                    accent: entry.accent,
                    softColor: entry.softColor,
                  ),
                  if (word.missionTitle != null) ...[
                    const SizedBox(height: 10),
                    Material(
                      color: AppColors.softPurple,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.pop(sheetContext, 'mission'),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              const WicaraIllustrationIcon(
                                type: WicaraIllustrationType.target,
                                size: 42,
                                accent: AppColors.purple,
                                background: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Digunakan dalam misi',
                                      style: GoogleFonts.nunitoSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.purple,
                                      ),
                                    ),
                                    Text(
                                      word.missionTitle!,
                                      style: GoogleFonts.nunitoSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: AppColors.purple,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(sheetContext, 'sentence'),
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Lihat dalam Kalimat'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(sheetContext, 'practice'),
                    icon: const Icon(Icons.extension_rounded),
                    label: Text(
                      progress.attempts == 0
                          ? 'Latih Kata Ini'
                          : 'Ulangi Latihan',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: entry.accent,
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (!mounted) return;
    switch (action) {
      case 'sentence':
        _showSentenceRole(entry.keyName);
        break;
      case 'practice':
        await _openPractice(word);
        break;
      case 'mission':
        await _openRelatedMission(word);
        break;
    }
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
      key: _sentenceSectionKey,
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
                    onTap: () => _showSentenceRole(phrase.$2),
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
  final DictionaryWord word;
  final DictionaryWordProgress progress;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  const _DictionaryWordCard({
    required this.entry,
    required this.word,
    required this.progress,
    required this.favorite,
    required this.onFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      semanticLabel: 'Buka detail kata ${word.word}',
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
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 6,
              child: ColoredBox(color: entry.accent),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Row(
                children: [
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
                                  word.word.toUpperCase(),
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
                                      word.contextLabel,
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
                                  word.meaning,
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 10, 10, 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          tooltip: favorite
                              ? 'Hapus dari koleksi'
                              : 'Simpan kata',
                          onPressed: onFavorite,
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            favorite
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_outline_rounded,
                            color: favorite
                                ? AppColors.indigo
                                : AppColors.muted,
                          ),
                        ),
                        _MasteryBadge(mastery: progress.mastery, compact: true),
                      ],
                    ),
                  ),
                ],
              ),
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

class _LearningStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  const _LearningStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.white.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          constraints: const BoxConstraints(minHeight: 70),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: selected ? Border.all(color: color, width: 1.5) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 4),
                  Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MasteryBadge extends StatelessWidget {
  final DictionaryMastery mastery;
  final bool compact;

  const _MasteryBadge({required this.mastery, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final (color, soft, icon) = switch (mastery) {
      DictionaryMastery.newWord => (
        AppColors.muted,
        const Color(0xFFF0F2F7),
        Icons.auto_awesome_outlined,
      ),
      DictionaryMastery.practicing => (
        AppColors.purple,
        AppColors.softPurple,
        Icons.school_outlined,
      ),
      DictionaryMastery.mastered => (
        AppColors.success,
        AppColors.softMint,
        Icons.verified_rounded,
      ),
    };
    return Semantics(
      label: 'Status ${mastery.label}',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 9,
          vertical: compact ? 3 : 5,
        ),
        decoration: BoxDecoration(
          color: soft,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: compact ? 11 : 14, color: color),
            const SizedBox(width: 3),
            Text(
              mastery.label,
              style: GoogleFonts.nunitoSans(
                fontSize: compact ? 7.5 : 9,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageComparison extends StatelessWidget {
  final String everyday;
  final String formal;
  final Color accent;
  final Color softColor;

  const _MessageComparison({
    required this.everyday,
    required this.formal,
    required this.accent,
    required this.softColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PILIH SESUAI SITUASI',
            style: GoogleFonts.nunitoSans(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: AppColors.text2,
            ),
          ),
          const SizedBox(height: 10),
          _ComparisonLine(
            label: 'Sehari-hari',
            text: everyday,
            icon: Icons.forum_outlined,
            color: AppColors.text2,
            background: Colors.white,
          ),
          const SizedBox(height: 7),
          _ComparisonLine(
            label: 'Pesan formal',
            text: formal,
            icon: Icons.verified_outlined,
            color: accent,
            background: softColor,
          ),
        ],
      ),
    );
  }
}

class _ComparisonLine extends StatelessWidget {
  final String label;
  final String text;
  final IconData icon;
  final Color color;
  final Color background;

  const _ComparisonLine({
    required this.label,
    required this.text,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                Text(
                  text,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
