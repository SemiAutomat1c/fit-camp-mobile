import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/progress_log.dart';

/// 3-column grid of progress photos, most recent first.
///
/// Tapping a photo pushes a fullscreen viewer.
class PhotoGrid extends StatelessWidget {
  const PhotoGrid({super.key, required this.logs});

  final List<ProgressLog> logs;

  @override
  Widget build(BuildContext context) {
    final withPhotos =
        logs.where((l) => l.photoUrl != null && l.photoUrl!.isNotEmpty).toList();

    if (withPhotos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'No progress photos yet',
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: withPhotos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        final log = withPhotos[index];
        return _PhotoCell(log: log);
      },
    );
  }
}

class _PhotoCell extends StatelessWidget {
  const _PhotoCell({required this.log});

  final ProgressLog log;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('d MMM').format(log.date);

    return GestureDetector(
      onTap: () => _openFullscreen(context, log.photoUrl!),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: log.photoUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Shimmer.fromColors(
                baseColor: AppColors.surface,
                highlightColor: AppColors.elevated,
                child: Container(color: AppColors.surface),
              ),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surface,
                child: const Icon(Icons.broken_image, color: AppColors.textMuted),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                color: Colors.black.withAlpha(153),
                child: Text(
                  dateLabel,
                  style: AppTextStyles.label.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullscreen(BuildContext context, String url) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullscreenPhotoView(url: url),
      ),
    );
  }
}

class _FullscreenPhotoView extends StatelessWidget {
  const _FullscreenPhotoView({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            placeholder: (_, __) => const CircularProgressIndicator(
              color: AppColors.primary,
            ),
            errorWidget: (_, __, ___) => const Icon(
              Icons.broken_image,
              color: AppColors.textMuted,
              size: 64,
            ),
          ),
        ),
      ),
    );
  }
}
