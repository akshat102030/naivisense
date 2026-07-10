import 'package:flutter/material.dart';
import 'package:naivisense/data/models/user.dart';
import 'package:naivisense/shared/widgets/app_card.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
class ParentAdminCard extends StatelessWidget {
  final UserModel parent;

  const ParentAdminCard({super.key, required this.parent});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: r.avatar(22, tablet: 24, desktop: 26),
            backgroundColor: AppColors.parentGradient.colors.first.withValues(
              alpha: 0.15,
            ),
            child: Text(
              parent.name.isNotEmpty ? parent.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: AppColors.parentGradient.colors.first,
                fontWeight: FontWeight.w700,
                fontSize: r.sp(16, tablet: 17, desktop: 18),
              ),
            ),
          ),
          r.gapW(12, tablet: 14, desktop: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parent.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: r.sp(16, tablet: 17, desktop: 18),
                  ),
                ),
                Text(
                  parent.phone,
                  style: TextStyle(
                    fontSize: r.sp(12, tablet: 13, desktop: 14),
                    color: AppColors.textSecondary,
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
              color: AppColors.parentGradient.colors.first.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(
                r.radius(20, tablet: 22, desktop: 24),
              ),
              border: Border.all(
                color: AppColors.parentGradient.colors.first.withValues(
                  alpha: 0.3,
                ),
              ),
            ),
            child: Text(
              'Parent',
              style: TextStyle(
                fontSize: r.sp(10, tablet: 11, desktop: 12),
                fontWeight: FontWeight.w600,
                color: AppColors.parentGradient.colors.first,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
