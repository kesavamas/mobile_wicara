import 'package:flutter/material.dart';

class SpokBadge extends StatelessWidget {
  final String role; // 'S' | 'P' | 'O' | 'K'
  final String text;
  final bool showRoleLabel;

  const SpokBadge({
    Key? key,
    required this.role,
    required this.text,
    this.showRoleLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    Color bgColor;
    Color textColor;
    String label;

    switch (role.toUpperCase()) {
      case 'S':
        bgColor = const Color(0xFFDBEAFE); // Blue 100
        textColor = const Color(0xFF1D4ED8); // Blue 700
        label = 'S';
        break;
      case 'P':
        bgColor = const Color(0xFFFEE2E2); // Red 100
        textColor = const Color(0xFFDC2626); // Red 600
        label = 'P';
        break;
      case 'O':
        bgColor = const Color(0xFFDCFCE7); // Green 100
        textColor = const Color(0xFF15803D); // Green 700
        label = 'O';
        break;
      case 'K':
      default:
        bgColor = const Color(0xFFFFEDD5); // Orange 100
        textColor = const Color(0xFFC2410C); // Orange 700
        label = 'K';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showRoleLabel) ...[
            Text(
              '$label: ',
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
