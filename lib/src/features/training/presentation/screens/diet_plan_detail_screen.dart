import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/diet_plan.dart';
import '../widgets/meal_timeline_card.dart';
import '../widgets/plan_detail_widgets.dart';

class DietPlanDetailScreen extends StatelessWidget {
  const DietPlanDetailScreen({super.key, required this.plan});

  final DietPlan plan;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy').format(plan.createdAt);
    final subtitle = plan.trainerName ?? plan.memberName;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          plan.name,
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Active badge
          Align(
            alignment: Alignment.centerLeft,
            child: PlanActiveBadge(isActive: plan.isActive),
          ),
          const SizedBox(height: 12),
          // Description
          if (plan.description != null && plan.description!.isNotEmpty) ...[
            Text(
              plan.description!,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
          ],
          // Trainer / Member
          if (subtitle != null && subtitle.isNotEmpty) ...[
            PlanMetaRow(
              icon: Icons.person_outline_rounded,
              text: subtitle,
            ),
            const SizedBox(height: 6),
          ],
          // Created date
          PlanMetaRow(
            icon: Icons.calendar_today_outlined,
            text: dateStr,
          ),
          const SizedBox(height: 24),
          // Section heading
          Text(
            'Meals',
            style:
                AppTextStyles.heading4.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          // Timeline meals
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: plan.meals.length,
            itemBuilder: (context, index) {
              return MealTimelineCard(
                meal: plan.meals[index],
                isLast: index == plan.meals.length - 1,
              );
            },
          ),
        ],
      ),
    );
  }
}

