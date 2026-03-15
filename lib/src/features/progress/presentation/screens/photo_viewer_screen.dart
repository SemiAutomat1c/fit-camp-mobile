import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../shared/theme/app_colors.dart';

/// Full-screen pinch-to-zoom photo viewer.
///
/// Receives arguments via GoRouter extra map:
/// ```dart
/// context.push('/progress/photo/$logId', extra: {
///   'imageUrl': log.photoUrl,
///   'heroTag': 'photo_$logId',
/// });
/// ```
class PhotoViewerScreen extends ConsumerWidget {
  const PhotoViewerScreen({
    super.key,
    required this.imageUrl,
    this.heroTag,
  });

  final String imageUrl;
  final String? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoView = PhotoView(
      imageProvider: CachedNetworkImageProvider(imageUrl),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 4,
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      loadingBuilder: (context, event) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(Icons.broken_image, color: AppColors.textMuted, size: 64),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withAlpha(128),
              ),
              icon: const Icon(Icons.close, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
      body: heroTag != null
          ? Hero(
              tag: heroTag!,
              child: photoView,
            )
          : photoView,
    );
  }
}
