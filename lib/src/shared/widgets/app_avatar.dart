import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/models/app_user.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Avatar display sizes.
enum AppAvatarSize {
  /// 32 dp — used inside [ListTile] leading
  sm(32),

  /// 40 dp — standard list item avatar
  md(40),

  /// 56 dp — profile header, booking card
  lg(56),

  /// 80 dp — profile screen, booking confirm
  xl(80);

  const AppAvatarSize(this.dp);
  final double dp;
}

/// Circular avatar with an initials fallback.
///
/// When [imageUrl] is null or the image fails to load, displays the first two
/// initials of [name] on a `#39FF14` background in `#0A0A0A` text.
///
/// ```dart
/// AppAvatar(name: 'Ryan Deniega', size: AppAvatarSize.lg)
/// AppAvatar(name: 'Ryan Deniega', imageUrl: user.avatarUrl)
/// ```
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = AppAvatarSize.md,
  });

  final String name;
  final String? imageUrl;
  final AppAvatarSize size;

  String get _initials => AppUser.initialsFromName(name);

  double get _fontSize => switch (size) {
    AppAvatarSize.sm => 11,
    AppAvatarSize.md => 14,
    AppAvatarSize.lg => 18,
    AppAvatarSize.xl => 24,
  };

  @override
  Widget build(BuildContext context) {
    final diameter = size.dp;
    final url = imageUrl;

    if (url != null && url.isNotEmpty) {
      return _ImageAvatar(
        url: url,
        diameter: diameter,
        initials: _initials,
        fontSize: _fontSize,
      );
    }

    return _InitialsAvatar(
      initials: _initials,
      diameter: diameter,
      fontSize: _fontSize,
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({
    required this.initials,
    required this.diameter,
    required this.fontSize,
  });

  final String initials;
  final double diameter;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.label.copyWith(
          color: AppColors.background,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

class _ImageAvatar extends StatelessWidget {
  const _ImageAvatar({
    required this.url,
    required this.diameter,
    required this.initials,
    required this.fontSize,
  });

  final String url;
  final double diameter;
  final String initials;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) => Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      placeholder: (context, url) => _InitialsAvatar(
        initials: initials,
        diameter: diameter,
        fontSize: fontSize,
      ),
      errorWidget: (context, url, error) => _InitialsAvatar(
        initials: initials,
        diameter: diameter,
        fontSize: fontSize,
      ),
    );
  }
}
