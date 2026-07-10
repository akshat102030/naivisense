import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/assessments/data/assessment_domains.dart';
import 'package:naivisense/features/assessments/widget/behavioral_item_card.dart';
import 'package:naivisense/features/assessments/widget/score.dart';
import 'package:naivisense/features/assessments/widget/sensory_item_card.dart';
import 'package:naivisense/features/assessments/widget/standard_itemcard.dart';

class DomainPage extends StatelessWidget {
  final AssessmentDomain domain;
  final Map<String, dynamic> data;
  final void Function(String key, dynamic val) onChanged;

  const DomainPage({
    super.key,
    required this.domain,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    print("========== DOMAIN PAGE ==========");
    print("STEP 1 : DomainPage build started");
    print("Domain : ${domain.title}");
    print("Type   : ${domain.type}");
    print("Items  : ${domain.items.length}");

    final r = Responsive(context);

    print("STEP 2 : Responsive created");

    return LayoutBuilder(
      builder: (context, constraints) {
        print("STEP 3 : LayoutBuilder");

        final cardMaxWidth = r.isMobile ? double.infinity : 560.0;

        print("STEP 4 : cardMaxWidth = $cardMaxWidth");

        Widget wrapCard(Widget child) {
          print("STEP 5 : wrapCard called");

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: cardMaxWidth),
              child: child,
            ),
          );
        }

        print("STEP 6 : About to return ListView");

        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            r.horizontalPadding,
            r.verticalPadding,
            r.horizontalPadding,
            r.h(10, tablet: 12, desktop: 14),
          ),
          children: [
            //---------------- HEADER ----------------
            Builder(
              builder: (_) {
                print("STEP 7 : Header");
                return wrapCard(
                  Container(
                    padding: r.allPadding(16, tablet: 18, desktop: 20),
                    decoration: BoxDecoration(
                      color: domain.color.withValues(alpha: 0.1),
                      borderRadius: r.borderRadius(14, tablet: 16, desktop: 18),
                      border: Border.all(
                        color: domain.color.withValues(alpha: 0.25),
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, headerConstraints) {
                        print("STEP 8 : Header LayoutBuilder");

                        final compact = headerConstraints.maxWidth < 360;

                        print("Compact = $compact");

                        final iconChip = Container(
                          padding: r.allPadding(10, tablet: 12, desktop: 14),
                          decoration: BoxDecoration(
                            color: domain.color.withValues(alpha: 0.15),
                            borderRadius: r.borderRadius(
                              10,
                              tablet: 12,
                              desktop: 14,
                            ),
                          ),
                          child: Icon(
                            domain.icon,
                            color: domain.color,
                            size: r.icon(22, tablet: 24, desktop: 26),
                          ),
                        );

                        final textBlock = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              domain.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: domain.color,
                                    fontSize: r.sp(18, tablet: 20, desktop: 22),
                                  ),
                            ),
                            Text(
                              '${domain.items.length} items',
                              style: TextStyle(
                                fontSize: r.sp(12, tablet: 13, desktop: 14),
                                color: domain.color.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        );

                        print("STEP 9 : Header widgets created");

                        if (compact) {
                          print("STEP 10 : Returning compact header");

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [iconChip, r.gapH(12), textBlock],
                          );
                        }

                        print("STEP 11 : Returning normal header");

                        return Row(
                          children: [
                            iconChip,
                            r.gapW(14),
                            Expanded(child: textBlock),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),

            if (domain.type == DomainType.standard) ...[
              Builder(
                builder: (_) {
                  print("STEP 12 : Standard Domain");
                  return r.gapH(12);
                },
              ),

              Builder(
                builder: (_) {
                  print("STEP 13 : ScoreLegend");
                  return wrapCard(ScoreLegend(color: domain.color));
                },
              ),

              Builder(
                builder: (_) {
                  print("STEP 14 : Gap");
                  return r.gapH(12);
                },
              ),

              ...domain.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                print("STEP 15 : Creating card $index -> ${item.key}");

                return wrapCard(
                  Builder(
                    builder: (_) {
                      print("STEP 16 : Building StandardItemCard ${item.key}");

                      return StandardItemCard(
                        item: item,
                        data: data[item.key] as Map<String, dynamic>? ?? {},
                        color: domain.color,
                        onChanged: (value) {
                          print("STEP 17 : ${item.key} changed");

                          onChanged(item.key, value);
                        },
                      );
                    },
                  ),
                );
              }),
            ],

            if (domain.type == DomainType.behavioral) ...[
              Builder(
                builder: (_) {
                  print("STEP 18 : Behavioral Domain");
                  return r.gapH(12);
                },
              ),

              ...domain.items.asMap().entries.map((entry) {
                final item = entry.value;

                print("STEP 19 : Behavioral ${item.key}");

                return wrapCard(
                  BehavioralItemCard(
                    item: item,
                    data: data[item.key] as Map<String, dynamic>? ?? {},
                    onChanged: (val) {
                      print("STEP 20 : Behavioral changed ${item.key}");
                      onChanged(item.key, val);
                    },
                  ),
                );
              }),
            ],

            if (domain.type == DomainType.sensory) ...[
              Builder(
                builder: (_) {
                  print("STEP 21 : Sensory Domain");
                  return r.gapH(12);
                },
              ),

              wrapCard(
                Padding(
                  padding: EdgeInsets.only(
                    bottom: r.h(12, tablet: 14, desktop: 16),
                  ),
                  child: Text(
                    'For each sensory modality, select whether the child is Seeking, Avoiding, or Typical, then rate the severity.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: r.sp(12, tablet: 13, desktop: 14),
                    ),
                  ),
                ),
              ),

              ...domain.items.asMap().entries.map((entry) {
                final item = entry.value;

                print("STEP 22 : Sensory ${item.key}");

                return wrapCard(
                  SensoryItemCard(
                    item: item,
                    data: data[item.key] as Map<String, dynamic>? ?? {},
                    color: domain.color,
                    onChanged: (val) {
                      print("STEP 23 : Sensory changed ${item.key}");
                      onChanged(item.key, val);
                    },
                  ),
                );
              }),
            ],

            Builder(
              builder: (_) {
                print("STEP 24 : Bottom Spacer");
                return SizedBox(height: r.h(96, tablet: 110, desktop: 120));
              },
            ),
          ],
        );
      },
    );
  }
}
