import 'package:flutter/material.dart';
import 'package:naivisense/data/models/therapist_overview.dart';
import 'package:naivisense/shared/widgets/app_card.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'assigned_child_row.dart';
import 'specialty_chip.dart';

class TherapistAdminCard extends StatefulWidget {
  final TherapistOverview therapist;

  const TherapistAdminCard({super.key, required this.therapist});

  @override
  State<TherapistAdminCard> createState() => _TherapistAdminCardState();
}

class _TherapistAdminCardState extends State<TherapistAdminCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final t = widget.therapist;
    final specialties = [...t.specialties, ...t.therapyMethods];

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: EdgeInsets.all(r.w(16, tablet: 20, desktop: 24)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: r.avatar(24, tablet: 26, desktop: 28),
                    backgroundColor: AppColors.therapistGradient.colors.first
                        .withValues(alpha: 0.15),
                    child: Text(
                      t.name.isNotEmpty ? t.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: AppColors.therapistGradient.colors.first,
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
                          t.name,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: r.sp(16, tablet: 17, desktop: 18),
                              ),
                        ),
                        if (t.qualification.isNotEmpty)
                          Text(
                            t.qualification,
                            style: TextStyle(
                              fontSize: r.sp(12, tablet: 13, desktop: 14),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        Text(
                          '${t.yearsExperience > 0 ? '${t.yearsExperience} yrs exp' : 'Exp not set'}'
                          '  •  ${t.children.length} child${t.children.length == 1 ? '' : 'ren'}',
                          style: TextStyle(
                            fontSize: r.sp(12, tablet: 13, desktop: 14),
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: r.icon(24, tablet: 26, desktop: 28),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Specialties
          Padding(
            padding: EdgeInsets.fromLTRB(
              r.w(16, tablet: 20, desktop: 24),
              0,
              r.w(16, tablet: 20, desktop: 24),
              r.h(12, tablet: 14, desktop: 16),
            ),
            child: specialties.isEmpty
                ? Text(
                    'No specialties listed',
                    style: TextStyle(
                      fontSize: r.sp(11, tablet: 12, desktop: 13),
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Wrap(
                    spacing: r.w(6, tablet: 8, desktop: 10),
                    runSpacing: r.h(6, tablet: 8, desktop: 10),
                    children: specialties
                        .map((s) => SpecialtyChip(label: s))
                        .toList(),
                  ),
          ),

          if (_expanded && t.children.isNotEmpty) ...[
            Divider(
              height: 1,
              indent: r.w(16, tablet: 20, desktop: 24),
              endIndent: r.w(16, tablet: 20, desktop: 24),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                r.w(16, tablet: 20, desktop: 24),
                r.h(10, tablet: 12, desktop: 14),
                r.w(16, tablet: 20, desktop: 24),
                r.h(4, tablet: 6, desktop: 8),
              ),
              child: Text(
                'Assigned Children',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: r.sp(12, tablet: 13, desktop: 14),
                ),
              ),
            ),
            ...t.children.map(
              (c) => AssignedChildRow(child: c, showTherapyType: true),
            ),
            r.gapH(8, tablet: 10, desktop: 12),
          ],

          if (_expanded && t.children.isEmpty) ...[
            Divider(
              height: 1,
              indent: r.w(16, tablet: 20, desktop: 24),
              endIndent: r.w(16, tablet: 20, desktop: 24),
            ),
            Padding(
              padding: EdgeInsets.all(r.w(12, tablet: 14, desktop: 16)),
              child: Text(
                'No children assigned yet',
                style: TextStyle(
                  fontSize: r.sp(13, tablet: 14, desktop: 15),
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
