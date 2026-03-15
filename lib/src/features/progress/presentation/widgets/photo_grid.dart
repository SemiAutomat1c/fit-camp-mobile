import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/progress_log.dart';
import '../providers/progress_provider.dart';
import 'delete_log_confirm_dialog.dart';

/// Masonry grid of progress photos, most recent first.
///
/// Uses [MasonryGridView] so portrait and landscape photos render at their
/// natural aspect ratio without cropping or letter-boxing.
///
/// Each thumbnail is wrapped in a [Hero] and taps navigate to the full-screen
/// [PhotoViewerScreen] via `/progress/photo/:logId`.
///
/// Long-pressing a photo shows a delete confirmation dialog.
class PhotoGrid extends ConsumerWidget {
  const PhotoGrid({super.key, required this.logs});

  final List<ProgressLog> logs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final withPhotos = logs
        .where((l) => l.photoUrl != null && l.photoUrl!.isNotEmpty)
        .toList();

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

    return MasonryGridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 3,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      itemCount: withPhotos.length,
      itemBuilder: (context, index) {
        final log = withPhotos[index];
        return _PhotoCell(log: log);
      },
    );
  }
}

class _PhotoCell extends ConsumerWidget {
  const _PhotoCell({required this.log});

  final ProgressLog log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heroTag = 'photo_${log.id}';
    final dateLabel = DateFormat('MMM d').format(log.date);

    return GestureDetector(
      onTap: () => context.push(
        '/progress/photo/${log.id}',
        extra: {'imageUrl': log.photoUrl!, 'heroTag': heroTag},
      ),
      onLongPress: () async {
        final confirmed = await showDeleteLogConfirmDialog(context);
        if (confirmed && context.mounted) {
          await ref
              .read(progressLogsNotifierProvider.notifier)
              .deleteLog(log.id);
        }
      },
      child: Hero(
        tag: heroTag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: log.photoUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: AppColors.surface,
                  highlightColor: AppColors.elevated,
                  child: Container(
                    height: 100,
                    color: AppColors.surface,
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 100,
                  color: AppColors.surface,
                  child: const Icon(
                      Icons.broken_image, color: AppColors.textMuted),
                ),
              ),
              // Date label with gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xB3000000), // black 70%
                      ],
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
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
      ),
    );
  }
}
