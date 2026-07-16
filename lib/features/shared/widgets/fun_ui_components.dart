import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/core/theme/app_colors.dart';
import 'package:wicara_application_1/features/shared/widgets/wicara_illustration_icon.dart';

class FunPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final WicaraIllustrationType illustration;
  final bool showBackButton;
  final Color accent;

  const FunPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.illustration,
    this.showBackButton = false,
    this.accent = AppColors.indigo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 18,
        20,
        28,
      ),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -62,
            top: -86,
            child: Container(
              width: 178,
              height: 178,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
            ),
          ),
          Row(
            children: [
              if (showBackButton) ...[
                IconButton.filled(
                  tooltip: 'Kembali',
                  onPressed: () => Navigator.maybePop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.16),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              WicaraIllustrationIcon(
                type: illustration,
                size: 70,
                accent: accent,
                background: Colors.white.withValues(alpha: 0.9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FunSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const FunSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text2,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class FriendlyEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final WicaraIllustrationType illustration;
  final Color accent;
  final Widget? action;

  const FriendlyEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.illustration = WicaraIllustrationType.empty,
    this.accent = AppColors.indigo,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      decoration: BoxDecoration(
        color: Color.lerp(accent, Colors.white, 0.93),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          WicaraIllustrationIcon(
            type: illustration,
            size: 86,
            accent: accent,
            background: Colors.white,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w700,
              color: AppColors.text2,
            ),
          ),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const PressableScale({
    super.key,
    required this.child,
    required this.onTap,
    this.semanticLabel,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        child: AnimatedScale(
          scale: _pressed ? 0.975 : 1,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}

class AnimatedProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final Color backgroundColor;
  final double height;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.backgroundColor = AppColors.line,
    this.height = 9,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(0.0, 1.0);
    return Semantics(
      label: 'Progress ${(safeValue * 100).round()} persen',
      value: '${(safeValue * 100).round()}%',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: safeValue),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (context, animatedValue, _) => ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: height,
            value: animatedValue,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ),
    );
  }
}

class SkeletonCard extends StatefulWidget {
  final double height;

  const SkeletonCard({super.key, required this.height});

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(
              const Color(0xFFF0F2F8),
              const Color(0xFFF8F9FC),
              _controller.value,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}

enum StatusBannerKind { success, offline, error }

class StatusBanner extends StatelessWidget {
  final StatusBannerKind kind;
  final String message;
  final VoidCallback? onRetry;

  const StatusBanner({
    super.key,
    required this.kind,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final (color, background, icon) = switch (kind) {
      StatusBannerKind.success => (
        AppColors.success,
        AppColors.softMint,
        Icons.check_circle_outline_rounded,
      ),
      StatusBannerKind.offline => (
        const Color(0xFF9A6A00),
        AppColors.softYellow,
        Icons.cloud_off_rounded,
      ),
      StatusBannerKind.error => (
        AppColors.danger,
        AppColors.softCoral,
        Icons.error_outline_rounded,
      ),
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.nunitoSans(
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ),
            if (onRetry != null)
              IconButton(
                tooltip: 'Coba lagi',
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                color: color,
              ),
          ],
        ),
      ),
    );
  }
}
