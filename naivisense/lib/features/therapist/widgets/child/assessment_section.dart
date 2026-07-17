import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/assessment.dart';
import 'package:naivisense/data/models/child.dart';
import 'package:naivisense/features/assessments/screens/assessment_result_screen.dart';
import 'package:naivisense/features/assessments/screens/assessment_wizard_screen.dart';
import 'package:naivisense/features/therapist/widgets/child/assessment_history_row.dart';
import 'package:naivisense/features/therapist/widgets/child/assessment_type_button.dart';
import 'package:naivisense/features/therapist/widgets/child/section_title.dart';

class AssessmentSection extends ConsumerWidget {
  final ChildModel child;
  final AsyncValue<dynamic> assessments;

  const AssessmentSection({
    super.key,
    required this.child,
    required this.assessments,
  });

  void _startAssessment(
    BuildContext context,
    String type, {
    AssessmentModel? previousAssessment,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssessmentWizardScreen(
          child: child,
          assessmentType: type,
          previousAssessment: previousAssessment,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive(context);

    final list =
        ((assessments.valueOrNull as List?) ?? []).cast<AssessmentModel>()
          ..sort((a, b) {
            final aDate =
                a.updatedAt ??
                a.createdAt ??
                DateTime.fromMillisecondsSinceEpoch(0);

            final bDate =
                b.updatedAt ??
                b.createdAt ??
                DateTime.fromMillisecondsSinceEpoch(0);

            return bDate.compareTo(aDate);
          });

    final latestAssessment = list.isNotEmpty ? list.first : null;

    return ProfileCard(
      title: 'Assessments',
      icon: Icons.assignment_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: responsive.w(12),
            runSpacing: responsive.h(12),
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              SizedBox(
                width: responsive.isMobile ? double.infinity : 220,
                child: Column(
                  children: [
                    AssessmentTypeButton(
                      label: list.isEmpty
                          ? 'Initial Assessment'
                          : 'Monthly Reassessment',
                      icon: list.isEmpty ? Icons.play_arrow : Icons.refresh,
                      color: AppColors.primaryBlue,
                      onTap: () => _startAssessment(
                        context,
                        list.isEmpty ? 'initial' : 'monthly',
                        previousAssessment: latestAssessment,
                      ),
                    ),

                    if (latestAssessment?.hasLatest == true) ...[
                      SizedBox(height: responsive.h(12)),

                      AssessmentTypeButton(
                        label: 'Latest Assessment',
                        icon: Icons.history,
                        color: const Color(0xFF2ECC71),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AssessmentResultScreen(
                                assessment: latestAssessment!,
                                child: child,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(
                width: responsive.isMobile ? double.infinity : 220,
                child: AssessmentTypeButton(
                  label: 'Quarterly Review',
                  icon: Icons.bar_chart_outlined,
                  color: const Color(0xFF9B59B6),
                  onTap: () => _startAssessment(
                    context,
                    'quarterly',
                    previousAssessment: latestAssessment,
                  ),
                ),
              ),
            ],
          ),

          if (list.isNotEmpty) ...[
            responsive.gapH(18, tablet: 24, desktop: 32),

            const Divider(),

            responsive.gapH(10, tablet: 12, desktop: 16),

            Text(
              'Assessment History',
              style: Theme.of(context).textTheme.titleSmall,
            ),

            responsive.gapH(10, tablet: 12, desktop: 16),

            ...list.take(5).map((assessment) {
              final initialOnlyAssessment = AssessmentModel(
                id: assessment.id,
                childId: assessment.childId,
                initial: assessment.initial,
                latest: null,
                createdAt: assessment.createdAt,
                updatedAt: assessment.updatedAt,
              );

              return Padding(
                padding: EdgeInsets.only(bottom: responsive.h(10)),
                child: AssessmentHistoryRow(
                  assessment: initialOnlyAssessment,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AssessmentResultScreen(
                          assessment: initialOnlyAssessment,
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
