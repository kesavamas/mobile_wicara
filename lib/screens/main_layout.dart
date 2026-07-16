import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/core/theme/app_colors.dart';
import 'package:wicara_application_1/features/dictionary/screens/color_dictionary_screen.dart';
import 'package:wicara_application_1/features/home/screens/bilik_selection_screen.dart';
import 'package:wicara_application_1/features/profile/screens/profile_tab_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const BilikSelectionScreen(),
    const ColorDictionaryScreen(),
    ProfileTabScreen(
      onOpenBilik: () => _selectTab(0),
      onOpenDictionary: () => _selectTab(1),
    ),
  ];

  void _selectTab(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 18,
            child: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 390),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.line),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x2924304A),
                          blurRadius: 40,
                          offset: Offset(0, 12),
                        ),
                        BoxShadow(
                          color: Color(0x1024304A),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: _NavItem(
                            icon: Icons.home_outlined,
                            label: 'Beranda',
                            selected: _currentIndex == 0,
                            onTap: () => _selectTab(0),
                          ),
                        ),
                        Flexible(
                          child: _NavItem(
                            icon: Icons.menu_book_outlined,
                            label: 'Kamus',
                            selected: _currentIndex == 1,
                            onTap: () => _selectTab(1),
                          ),
                        ),
                        Flexible(
                          child: _NavItem(
                            icon: Icons.person_outline_rounded,
                            label: 'Progres',
                            selected: _currentIndex == 2,
                            onTap: () => _selectTab(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      selected: selected,
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.indigo : Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
            decoration: selected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x594C5FD7),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  )
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 23,
                  color: selected ? Colors.white : const Color(0xFF69738F),
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: selected ? Colors.white : const Color(0xFF69738F),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
