import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/assessments/data/assessment_domains.dart';

class StandardItemCard extends StatefulWidget {
  final AssessmentItem item;
  final Map<String, dynamic> data;
  final Color color;
  final void Function(Map<String, dynamic>) onChanged;

  const StandardItemCard({
    super.key,
    required this.item,
    required this.data,
    required this.color,
    required this.onChanged,
  });

  @override
  State<StandardItemCard> createState() => StandardItemCardState();
}

class StandardItemCardState extends State<StandardItemCard> {
  late int? _score;
  late TextEditingController _remarksCtrl;

  @override
  void initState() {
    super.initState();
    _score = widget.data['score'] as int?;
    _remarksCtrl = TextEditingController(
      text: widget.data['remarks'] as String? ?? '',
    );
  }

  @override
  void dispose() {
    _remarksCtrl.dispose();
    super.dispose();
  }

  void _notify() {
    final data = {'score': _score ?? 0, 'remarks': _remarksCtrl.text};

    debugPrint('_StandardItemCard: $data');

    widget.onChanged(data);
  }

  @override
  Widget build(BuildContext context) {
    print("========== STANDARD ITEM CARD ==========");
    print("CARD STEP 1 : build()");
    print("Item = ${widget.item.label}");

    final r = Responsive(context);

    print("CARD STEP 2 : Responsive created");

    return Card(
      margin: EdgeInsets.only(bottom: r.h(10, tablet: 12, desktop: 14)),
      shape: RoundedRectangleBorder(
        borderRadius: r.borderRadius(12, tablet: 14, desktop: 16),
      ),
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: r.allPadding(14, tablet: 16, desktop: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (_) {
                print("CARD STEP 3 : Title");

                return Text(
                  widget.item.label,
                  style: TextStyle(
                    fontSize: r.sp(14, tablet: 15, desktop: 16),
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),

            Builder(
              builder: (_) {
                print("CARD STEP 4 : Gap");
                return r.gapH(10);
              },
            ),

            Builder(
              builder: (_) {
                print("CARD STEP 5 : LayoutBuilder");

                return LayoutBuilder(
                  builder: (context, constraints) {
                    print("CARD STEP 6 : LayoutBuilder executed");
                    print("maxWidth = ${constraints.maxWidth}");

                    final compact = constraints.maxWidth < 360;

                    print("compact = $compact");

                    print("CARD STEP 7 : Generating chips");

                    final chips = List.generate(4, (i) {
                      print("Creating chip $i");

                      final selected = _score == i;

                      return Builder(
                        builder: (_) {
                          print("Building chip $i");

                          return GestureDetector(
                            onTap: () {
                              print("Tapped chip $i");

                              setState(() => _score = i);
                              _notify();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: r.w(44, tablet: 48, desktop: 52),
                              height: r.h(36, tablet: 40, desktop: 44),
                              decoration: BoxDecoration(
                                color: selected
                                    ? kScoreColors[i]
                                    : kScoreColors[i].withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  r.radius(8, tablet: 10, desktop: 12),
                                ),
                                border: Border.all(
                                  color: kScoreColors[i].withValues(
                                    alpha: selected ? 1 : 0.35,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$i',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: r.sp(15, tablet: 16, desktop: 17),
                                    color: selected
                                        ? Colors.white
                                        : kScoreColors[i],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    });

                    print("CARD STEP 8 : Chips generated");

                    if (compact) {
                      print("CARD STEP 9 : Returning compact layout");

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: r.w(8, tablet: 10, desktop: 12),
                            runSpacing: r.h(8, tablet: 10, desktop: 12),
                            children: chips,
                          ),
                          if (_score != null) ...[
                            r.gapH(8),
                            Text(
                              kScoreLabels[_score!],
                              style: TextStyle(
                                fontSize: r.sp(12, tablet: 13, desktop: 14),
                                color: kScoreColors[_score!],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      );
                    }

                    print("CARD STEP 10 : Returning normal layout");

                    return Row(
                      children: [
                        Wrap(
                          spacing: r.w(8, tablet: 10, desktop: 12),
                          children: chips,
                        ),
                        if (_score != null) ...[
                          r.gapW(10),
                          Expanded(
                            child: Text(
                              kScoreLabels[_score!],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: r.sp(12, tablet: 13, desktop: 14),
                                color: kScoreColors[_score!],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                );
              },
            ),

            Builder(
              builder: (_) {
                print("CARD STEP 11 : Gap before TextField");
                return r.gapH(10);
              },
            ),

            Builder(
              builder: (_) {
                print("CARD STEP 12 : TextField");

                return TextField(
                  controller: _remarksCtrl,
                  onChanged: (_) => _notify(),
                  style: TextStyle(fontSize: r.sp(12, tablet: 13, desktop: 14)),
                  decoration: InputDecoration(
                    hintText: 'Therapist remarks (optional)',
                    hintStyle: TextStyle(
                      fontSize: r.sp(12, tablet: 13, desktop: 14),
                      color: AppColors.textSecondary,
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: r.w(10, tablet: 12, desktop: 14),
                      vertical: r.h(8, tablet: 10, desktop: 12),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: r.borderRadius(8, tablet: 10, desktop: 12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
