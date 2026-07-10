import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:naivisense/data/models/child.dart';
import 'package:naivisense/shared/widgets/app_card.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class ChildAdminCard extends StatelessWidget {
  final ChildModel child;

  const ChildAdminCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final (sevLabel, sevColor) = switch (child.severity) {
      'mild' => ('Mild', AppColors.mintGreen),
      'moderate' => ('Moderate', AppColors.warmYellow),
      'severe' => ('Severe', AppColors.softCoral),
      _ => ('—', AppColors.textSecondary),
    };

    String shortIdOrFallback(String id, String fallback) {
      if (id.isEmpty) return fallback;
      return id.length <= 8 ? id : id.substring(0, 8);
    }

    return AppCard(
      onTap: () => context.push('/center-head/child/${child.id}', extra: child),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: r.avatar(24, tablet: 26, desktop: 28),
                backgroundColor: AppColors.centerHeadGradient.colors.first
                    .withValues(alpha: 0.15),
                child: Text(
                  child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: AppColors.centerHeadGradient.colors.first,
                    fontWeight: FontWeight.w700,
                    fontSize: r.sp(18, tablet: 20, desktop: 22),
                  ),
                ),
              ),
              r.gapW(12, tablet: 14, desktop: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: r.sp(16, tablet: 17, desktop: 18),
                      ),
                    ),
                    Text(
                      '${child.ageYears} yrs  •  ${child.diagnosis.join(', ')}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: r.sp(12, tablet: 13, desktop: 14),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.w(10, tablet: 12, desktop: 14),
                  vertical: r.h(4, tablet: 5, desktop: 6),
                ),
                decoration: BoxDecoration(
                  color: sevColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    r.radius(20, tablet: 22, desktop: 24),
                  ),
                  border: Border.all(color: sevColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  sevLabel,
                  style: TextStyle(
                    fontSize: r.sp(11, tablet: 12, desktop: 13),
                    fontWeight: FontWeight.w600,
                    color: sevColor,
                  ),
                ),
              ),
            ],
          ),

          r.gapH(10, tablet: 12, desktop: 14),

          if (child.therapists.isEmpty)
            Row(
              children: [
                Icon(
                  Icons.person_outlined,
                  size: r.icon(14, tablet: 15, desktop: 16),
                  color: AppColors.textSecondary,
                ),
                r.gapW(5),
                Text(
                  'Not assigned',
                  style: TextStyle(
                    fontSize: r.sp(12, tablet: 13, desktop: 14),
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: r.icon(12, tablet: 13, desktop: 14),
                  color: AppColors.textSecondary,
                ),
                r.gapW(2),
                Text(
                  'View Report',
                  style: TextStyle(
                    fontSize: r.sp(12, tablet: 13, desktop: 14),
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...child.therapists.map(
                  (t) => Padding(
                    padding: EdgeInsets.only(
                      bottom: r.h(3, tablet: 4, desktop: 5),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outlined,
                          size: r.icon(13, tablet: 14, desktop: 15),
                          color: AppColors.textSecondary,
                        ),
                        r.gapW(4),
                        Expanded(
                          child: Text(
                            '${t.therapistName ?? shortIdOrFallback(t.therapistId, 'Unassigned therapist')}'
                            '${t.therapyType.isNotEmpty ? "  ·  ${t.therapyType}" : ""}',
                            style: TextStyle(
                              fontSize: r.sp(12, tablet: 13, desktop: 14),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_forward_ios,
                        size: r.icon(12, tablet: 13, desktop: 14),
                        color: AppColors.textSecondary,
                      ),
                      r.gapW(2),
                      Text(
                        'View Report',
                        style: TextStyle(
                          fontSize: r.sp(12, tablet: 13, desktop: 14),
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
