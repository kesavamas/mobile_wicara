import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({Key? key}) : super(key: key);

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  String _activeTab = 's';

  final Map<String, Map<String, String>> _entries = {
    's': {
      'emoji': '👤',
      'label': 'S Subjek',
      'example': 'SAYA',
      'q': 'Siapa yang berbicara?',
      'sentence': 'Saya membaca buku.',
      'bg': '0xFFEAF2FF',
      'border': '0xFF4D91FF',
      'text': '0xFF163E8C'
    },
    'p': {
      'emoji': '⚡',
      'label': 'P Predikat',
      'example': 'MEMBACA',
      'q': 'Apa yang dilakukan?',
      'sentence': 'Saya membaca buku.',
      'bg': '0xFFFFECEF',
      'border': '0xFFD9485F',
      'text': '0xFF8B2235'
    },
    'o': {
      'emoji': '📦',
      'label': 'O Objek',
      'example': 'BUKU',
      'q': 'Apa yang dikenai tindakan?',
      'sentence': 'Saya membaca buku.',
      'bg': '0xFFE8F8F1',
      'border': '0xFF1F9D70',
      'text': '0xFF145B42'
    },
    'k': {
      'emoji': '🕐',
      'label': 'K Keterangan',
      'example': 'HARI INI',
      'q': 'Kapan, di mana, atau mengapa?',
      'sentence': 'Saya membaca buku hari ini.',
      'bg': '0xFFFFF4D6',
      'border': '0xFFE5A91D',
      'text': '0xFF6A4C00'
    },
    'pel': {
      'emoji': '🔗',
      'label': 'Pel Pelengkap',
      'example': 'KARENA',
      'q': 'Melengkapi hubungan antarkata.',
      'sentence': 'Saya izin karena sakit.',
      'bg': '0xFFF1EAFE',
      'border': '0xFF7C3AED',
      'text': '0xFF4C1D95'
    },
  };

  Color _parseColor(String value) {
    return Color(int.parse(value));
  }

  IconData _getDictionaryIcon(String activeTab) {
    switch (activeTab) {
      case 's':
        return Icons.person_pin_rounded;
      case 'p':
        return Icons.bolt_rounded;
      case 'o':
        return Icons.inventory_2_rounded;
      case 'k':
        return Icons.schedule_rounded;
      case 'pel':
      default:
        return Icons.link_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = _entries[_activeTab]!;
    final bgColor = _parseColor(entry['bg']!);
    final borderClr = _parseColor(entry['border']!);
    final textClr = _parseColor(entry['text']!);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Kamus Warna Kata',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Buku saku SPOK',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF667085),
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar Placeholder
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE4E7EC)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: Color(0xFF98A2B3), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Cari kata atau fungsi kalimat',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF98A2B3),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tab bar selection row
            Row(
              children: _entries.keys.map((key) {
                final isSelected = _activeTab == key;
                final tabEntry = _entries[key]!;
                final tabBg = isSelected ? _parseColor(tabEntry['bg']!) : Colors.white;
                final tabBorder = isSelected ? _parseColor(tabEntry['border']!) : const Color(0xFFE4E7EC);
                final tabText = isSelected ? _parseColor(tabEntry['text']!) : const Color(0xFF667085);

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeTab = key;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: tabBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: tabBorder, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          key.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: tabText,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Flashcard definition
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: borderClr, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: borderClr.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    _getDictionaryIcon(_activeTab),
                    size: 56,
                    color: textClr,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      entry['example']!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: textClr,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    entry['label']!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textClr,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry['q']!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textClr.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Example sentence card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE4E7EC)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CONTOH KALIMAT',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF667085),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: entry['sentence']!.split(' ').map((w) {
                      final cleanWord = w.replaceAll('.', '').toLowerCase();
                      final isMatch = cleanWord == entry['example']!.toLowerCase() ||
                          entry['example']!.toLowerCase().contains(cleanWord);

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isMatch ? bgColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isMatch ? borderClr : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          w,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: isMatch ? FontWeight.w900 : FontWeight.w600,
                            color: isMatch ? textClr : const Color(0xFF475467),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120), // Spacer so float nav doesn't overlap content
          ],
        ),
      ),
    );
  }
}
