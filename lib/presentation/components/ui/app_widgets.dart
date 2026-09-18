import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/constants/layout.dart';
import 'package:volt/models/media/media_item.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final bool showGlow;

  const AppBackground({
    super.key,
    required this.child,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.colorBackground,
      child: Stack(
        children: [
          if (showGlow) const Positioned.fill(child: IgnorePointer(child: _CinemaAtmosphere())),
          child,
        ],
      ),
    );
  }
}

class _CinemaAtmosphere extends StatelessWidget {
  const _CinemaAtmosphere();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CinemaPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _CinemaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final orange = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.colorOrange.withValues(alpha: 0.16),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.08, size.height * 0.12), radius: 280));
    canvas.drawCircle(Offset(size.width * 0.08, size.height * 0.12), 280, orange);

    final blue = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.colorAccent.withValues(alpha: 0.18),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.92, size.height * 0.82), radius: 300));
    canvas.drawCircle(Offset(size.width * 0.92, size.height * 0.82), 300, blue);

    final gold = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.colorGold.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.7, -20), radius: 220));
    canvas.drawCircle(Offset(size.width * 0.7, -20), 220, gold);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EnergyTrail extends StatelessWidget {
  final double height;
  final bool orange;

  const EnergyTrail({super.key, this.height = 2, this.orange = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: orange
              ? [
                  AppColors.colorOrange.withValues(alpha: 0),
                  AppColors.colorOrange,
                  AppColors.colorGold,
                  AppColors.colorOrange.withValues(alpha: 0),
                ]
              : [
                  AppColors.colorAccent.withValues(alpha: 0),
                  AppColors.colorAccent,
                  AppColors.colorElectric,
                  AppColors.colorAccent.withValues(alpha: 0),
                ],
        ),
      ),
    );
  }
}

class LightningDivider extends StatelessWidget {
  const LightningDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      width: double.infinity,
      child: CustomPaint(painter: _LightningDividerPainter()),
    );
  }
}

class _LightningDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.55)
      ..lineTo(size.width * 0.42, size.height * 0.55)
      ..lineTo(size.width * 0.46, size.height * 0.18)
      ..lineTo(size.width * 0.5, size.height * 0.82)
      ..lineTo(size.width * 0.54, size.height * 0.55)
      ..lineTo(size.width, size.height * 0.55);
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x00008CFF), Color(0xFFFF6A00), Color(0xFF20B8FF), Color(0x00008CFF)],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChromeRule extends StatelessWidget {
  final double? width;
  final double thickness;
  final bool orange;

  const ChromeRule({super.key, this.width = 48, this.thickness = 1, this.orange = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: thickness,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: orange
              ? [
                  AppColors.colorOrange.withValues(alpha: 0),
                  AppColors.colorOrange,
                  AppColors.colorGold,
                  AppColors.colorOrange.withValues(alpha: 0),
                ]
              : [
                  AppColors.colorSilver.withValues(alpha: 0),
                  AppColors.colorSilver,
                  AppColors.colorChrome,
                  AppColors.colorSilver.withValues(alpha: 0),
                ],
        ),
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  final double height;
  final bool showWordmark;

  const BrandMark({
    super.key,
    this.height = 56,
    this.showWordmark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      BrandAssets.logo,
      height: height,
      fit: BoxFit.contain,
    );
  }
}

class BrandWordmark extends StatelessWidget {
  final double fontSize;

  const BrandWordmark({super.key, this.fontSize = 26});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'VOLT',
            style: TextStyle(
              fontFamily: AppTheme.displayFamily,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              color: AppColors.colorSilver,
              height: 1,
              letterSpacing: 1.2,
            ),
          ),
          TextSpan(
            text: ' OTT',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: fontSize * 0.42,
              fontWeight: FontWeight.w700,
              color: AppColors.colorOrange,
              letterSpacing: 2.4,
            ),
          ),
        ],
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final void Function()? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final EdgeInsets margin;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 54,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: GestureDetector(
        onTap: isLoading ? null : onPressed,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: onPressed == null ? 0.55 : 1,
          child: ClipPath(
            clipper: const _BoltCutClipper(),
            child: Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.colorOrange.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF030609)),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, color: const Color(0xFF030609), size: 20),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            label.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF030609),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MetallicButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  const MetallicButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: AppColors.colorSilver.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.colorSilver, size: 16),
              const SizedBox(width: 8),
            ],
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: AppColors.colorSilver,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final int? maxLength;
  final String? errorText;
  final Widget? suffix;
  final VoidCallback? onEditingComplete;

  const DarkField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.errorText,
    this.suffix,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hintText.toUpperCase(),
          style: AppTextStyles.eyebrow.copyWith(
            color: hasError ? Colors.redAccent : AppColors.colorAccent,
            letterSpacing: 2.6,
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: AppTheme.displayFamily,
            fontWeight: FontWeight.w600,
          ),
          cursorColor: AppColors.colorOrange,
          decoration: InputDecoration(
            counterText: '',
            border: InputBorder.none,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: hasError ? Colors.redAccent : AppColors.colorHairline),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.colorAccent, width: 1.6),
            ),
            hintText: '',
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onEditingComplete: onEditingComplete,
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

class SocialCircleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  const SocialCircleButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.colorHairline),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? labelColor;
  final bool showChevron;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.iconColor,
    this.labelColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.colorAccent;
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: labelColor ?? Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            if (showChevron)
              Icon(Icons.arrow_forward, color: AppColors.colorTextMuted, size: 16),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppLayout.gutter(context), 22, AppLayout.gutter(context), 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ChromeRule(width: 36, thickness: 1.4, orange: true),
                const SizedBox(height: 8),
                Text(title, style: AppTextStyles.sectionTitle),
              ],
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: const Text('SEE ALL', style: AppTextStyles.seeAll),
            ),
        ],
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Color? background;
  final Color? iconColor;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 44,
    this.background,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background ?? Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.colorHairline),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.colorSilver, size: size * 0.42),
      ),
    );
  }
}

class CategoryChipBar extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const CategoryChipBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: AppLayout.gutter(context)),
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 28),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  labels[index].toUpperCase(),
                  style: TextStyle(
                    color: selected ? AppColors.colorOrange : AppColors.colorTextMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 2.1,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  height: 2,
                  width: selected ? 36 : 0,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ButterflyBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool showDownloads;

  const ButterflyBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.showDownloads,
  });

  @override
  Widget build(BuildContext context) {
    return VoltBottomNav(
      currentIndex: currentIndex,
      onTap: onTap,
      showDownloads: showDownloads,
    );
  }
}

class VoltBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool showDownloads;

  const VoltBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.showDownloads,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_NavSpec>[
      const _NavSpec(Icons.bolt_outlined, Icons.bolt, 'Home'),
      const _NavSpec(Icons.explore_outlined, Icons.explore, 'Discover'),
      const _NavSpec(Icons.playlist_add_outlined, Icons.playlist_add_check, 'My List'),
      if (showDownloads) const _NavSpec(Icons.offline_bolt_outlined, Icons.offline_bolt, 'Downloads'),
      const _NavSpec(Icons.person_outline, Icons.person, 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.colorBackground.withValues(alpha: 0.96),
        border: const Border(top: BorderSide(color: AppColors.colorHairline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (index) {
              final selected = currentIndex == index;
              final spec = items[index];
              final isCenter = index == (showDownloads ? 2 : 1);
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isCenter)
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: selected ? AppColors.primaryGradient : null,
                            border: selected ? null : Border.all(color: AppColors.colorAccent, width: 1.2),
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: selected ? const Color(0xFF030609) : AppColors.colorAccent,
                            size: 20,
                          ),
                        )
                      else
                        Icon(
                          selected ? spec.selectedIcon : spec.icon,
                          color: selected ? AppColors.colorOrange : AppColors.colorTextMuted,
                          size: 22,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        spec.label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700,
                          color: selected ? AppColors.colorOrange : AppColors.colorTextMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        height: 2,
                        width: selected ? 18 : 0,
                        decoration: const BoxDecoration(gradient: AppColors.premiumGradient),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavSpec {
  final IconData selectedIcon;
  final IconData icon;
  final String label;

  const _NavSpec(this.icon, this.selectedIcon, this.label);
}

class GlassDialog extends StatelessWidget {
  final Widget child;

  const GlassDialog({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipPath(
        clipper: const _BoltCutClipper(),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.colorSurface.withValues(alpha: 0.94),
              border: Border.all(color: AppColors.colorOrange.withValues(alpha: 0.4)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

String mediaMetaLine(BaseItem item) {
  final parts = <String>[];
  if (item.showReleaseTime) {
    parts.add('${item.releaseTime.year}');
  }
  if (item.categories.isNotEmpty) {
    parts.add(item.categories.first.toUpperCase());
  }
  if (item.length.isNotEmpty) {
    parts.add(item.length);
  } else if (item.lengthSeconds > 0) {
    final hours = item.lengthSeconds ~/ 3600;
    final minutes = (item.lengthSeconds % 3600) ~/ 60;
    parts.add(hours > 0 ? '${hours}H ${minutes}M' : '${minutes}M');
  }
  String age = '';
  if (item.ageRating != null && item.ageLimit != null) {
    age = '${item.ageRating} ${item.ageLimit}+';
  } else if (item.ageRating != null) {
    age = item.ageRating!;
  } else if (item.ageLimit != null) {
    age = 'U/A ${item.ageLimit}+';
  }
  if (age.isNotEmpty) parts.add(age);
  return parts.join('   ·   ');
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(72, 72),
              painter: _BoltMarkPainter(),
            ),
            const SizedBox(height: 22),
            Text(title, textAlign: TextAlign.center, style: AppTextStyles.editorial.copyWith(fontSize: 24)),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!, textAlign: TextAlign.center, style: AppTextStyles.meta),
            ],
          ],
        ),
      ),
    );
  }
}

class _BoltMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.58, 4)
      ..lineTo(size.width * 0.28, size.height * 0.48)
      ..lineTo(size.width * 0.5, size.height * 0.48)
      ..lineTo(size.width * 0.38, size.height - 4)
      ..lineTo(size.width * 0.78, size.height * 0.42)
      ..lineTo(size.width * 0.54, size.height * 0.42)
      ..close();
    final paint = Paint()
      ..shader = AppColors.primaryGradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color? borderColor;
  final VoidCallback? onTap;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(color: borderColor ?? AppColors.colorHairline),
        ),
      ),
      child: child,
    );
    if (onTap == null) {
      return Padding(padding: margin, child: content);
    }
    return Padding(
      padding: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

class DetailAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool active;

  const DetailAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? AppColors.colorOrange : AppColors.colorHairline,
              ),
            ),
            child: Icon(
              icon,
              color: active ? AppColors.colorOrange : Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: active ? AppColors.colorOrange : AppColors.colorTextSecondary,
              fontSize: 9,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class DiagonalClipper extends CustomClipper<Path> {
  final double cut;

  const DiagonalClipper({this.cut = 18});

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(cut, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - cut, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant DiagonalClipper oldClipper) => oldClipper.cut != cut;
}

class _BoltCutClipper extends CustomClipper<Path> {
  const _BoltCutClipper();

  @override
  Path getClip(Size size) {
    const cut = 12.0;
    return Path()
      ..moveTo(cut, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - cut)
      ..lineTo(size.width - cut, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, cut)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class ChromeFrame extends StatelessWidget {
  final Widget child;
  final double inset;

  const ChromeFrame({super.key, required this.child, this.inset = 8});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ChromeFramePainter(),
      child: Padding(padding: EdgeInsets.all(inset), child: child),
    );
  }
}

class _ChromeFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFD9DDE3), Color(0xFF20B8FF), Color(0xFFD9DDE3)],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    const cut = 10.0;
    final path = Path()
      ..moveTo(cut, 2)
      ..lineTo(size.width - 2, 2)
      ..lineTo(size.width - 2, size.height - cut)
      ..lineTo(size.width - cut, size.height - 2)
      ..lineTo(2, size.height - 2)
      ..lineTo(2, cut)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PlayCoreButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;
  final String label;

  const PlayCoreButton({
    super.key,
    required this.onPressed,
    this.size = 84,
    this.label = 'WATCH NOW',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _EnergyRingPainter(),
              child: Center(
                child: Icon(Icons.play_arrow_rounded, color: AppColors.colorOrange, size: size * 0.42),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(label, style: AppTextStyles.eyebrow.copyWith(color: AppColors.colorOrange)),
        ],
      ),
    );
  }
}

class PlayReelButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;
  final String label;

  const PlayReelButton({
    super.key,
    required this.onPressed,
    this.size = 78,
    this.label = 'WATCH NOW',
  });

  @override
  Widget build(BuildContext context) {
    return PlayCoreButton(onPressed: onPressed, size: size, label: label);
  }
}

class _EnergyRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final orange = Paint()
      ..color = AppColors.colorOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final blue = Paint()
      ..color = AppColors.colorAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawCircle(c, size.width * 0.46, orange);
    canvas.drawCircle(c, size.width * 0.36, blue);
    for (int i = 0; i < 6; i++) {
      final a = (math.pi * 2 / 6) * i - math.pi / 2;
      final inner = Offset(c.dx + math.cos(a) * size.width * 0.36, c.dy + math.sin(a) * size.width * 0.36);
      final outer = Offset(c.dx + math.cos(a) * size.width * 0.46, c.dy + math.sin(a) * size.width * 0.46);
      canvas.drawLine(inner, outer, orange..strokeWidth = 1.4);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EnergyProgress extends StatelessWidget {
  final double value;

  const EnergyProgress({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 8),
      painter: _EnergyProgressPainter(value.clamp(0.0, 1.0)),
    );
  }
}

class _EnergyProgressPainter extends CustomPainter {
  final double value;
  _EnergyProgressPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final bg = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final fg = Paint()
      ..shader = AppColors.premiumGradient.createShader(Offset.zero & size)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), bg);
    canvas.drawLine(Offset(0, y), Offset(size.width * value, y), fg);
    if (value > 0) {
      canvas.drawCircle(
        Offset(size.width * value, y),
        3.6,
        Paint()..color = AppColors.colorElectric,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EnergyProgressPainter oldDelegate) => oldDelegate.value != value;
}

class VoltPageRoute<T> extends PageRouteBuilder<T> {
  VoltPageRoute({required Widget page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 520),
          reverseTransitionDuration: const Duration(milliseconds: 360),
          transitionsBuilder: (context, animation, secondary, child) {
            final fade = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero).animate(fade),
                child: child,
              ),
            );
          },
        );
}
