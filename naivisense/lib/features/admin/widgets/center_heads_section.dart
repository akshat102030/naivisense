// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:naivisense/core/utils/responsive.dart';
// import 'package:naivisense/data/models/admin_overview.dart';

// import '../../../../shared/widgets/state_widgets.dart' as sw;
// import 'admin_admin_card.dart';

// class AdminsSection extends StatelessWidget {
//   final AsyncValue<List<AdminOverview>> admins;

//   const AdminsSection({super.key, required this.admins});

//   @override
//   Widget build(BuildContext context) {
//     final r = Responsive(context);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Admins',
//           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//             fontSize: r.sp(24, tablet: 26, desktop: 28),
//           ),
//         ),

//         r.gapH(12, tablet: 16, desktop: 20),

//         admins.when(
//           loading: () => const sw.LoadingWidget(),
//           error: (e, _) => sw.ErrorWidget(message: e.toString()),
//           data: (list) {
//             if (list.isEmpty) {
//               return const sw.EmptyWidget(
//                 message: 'No admins registered yet',
//                 icon: Icons.admin_panel_settings_outlined,
//               );
//             }

//             return MasonryGridView.count(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               crossAxisCount: r.isDesktop
//                   ? 3
//                   : r.isTablet
//                   ? 2
//                   : 1,
//               mainAxisSpacing: r.h(18),
//               crossAxisSpacing: r.w(18),
//               itemCount: list.length,
//               itemBuilder: (context, index) {
//                 return AdminAdminCard(admin: list[index]);
//               },
//             );
//           },
//         ),
//       ],
//     );
//   }
// }
