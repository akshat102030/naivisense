import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/data/models/user.dart';

import '../../../core/utils/responsive.dart';
import '../../../../shared/widgets/state_widgets.dart' as sw;
import 'parent_admin_card.dart';

class ParentsSection extends StatelessWidget {
  final AsyncValue<List<UserModel>> parents;

  const ParentsSection({super.key, required this.parents});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Parents',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: r.sp(24, tablet: 26, desktop: 28),
          ),
        ),

        r.gapH(12, tablet: 16, desktop: 20),

        parents.when(
          loading: () => const sw.LoadingWidget(),
          error: (e, _) => sw.ErrorWidget(message: e.toString()),
          data: (list) {
            if (list.isEmpty) {
              return const sw.EmptyWidget(
                message: 'No parents registered yet',
                icon: Icons.family_restroom,
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => r.gapH(8, tablet: 10, desktop: 12),
              itemBuilder: (_, i) => ParentAdminCard(parent: list[i]),
            );
          },
        ),
      ],
    );
  }
}
