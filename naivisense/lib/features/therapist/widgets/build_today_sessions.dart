import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/core/utils/string_utils.dart';
import 'package:naivisense/data/models/child.dart';
import 'package:naivisense/data/models/session.dart';
import 'package:naivisense/features/therapist/providers/therapist_provider.dart';
import 'package:naivisense/features/therapist/screens/edit_session_screen.dart';
import 'package:naivisense/features/therapist/screens/session_notes_screen.dart';
import 'package:naivisense/features/therapist/widgets/session_card.dart';
import 'package:naivisense/shared/widgets/state_widgets.dart' as sw;

class TodaySessions extends ConsumerWidget {
  final AsyncValue<List<SessionModel>> sessions;
  final AsyncValue<List<ChildModel>> children;

  const TodaySessions({
    super.key,
    required this.sessions,
    required this.children,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Sessions",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: responsive.sp(20, tablet: 22, desktop: 24),
          ),
        ),

        responsive.gapH(12, tablet: 16, desktop: 20),

        sessions.when(
          loading: () => const sw.LoadingWidget(),

          error: (e, _) => sw.ErrorWidget(message: e.toString()),

          data: (list) {
            final now = DateTime.now();

            final today = list.where((session) {
              final date = session.scheduledAt;

              return date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;
            }).toList()..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

            if (today.isEmpty) {
              return const sw.EmptyWidget(
                message: 'No sessions today',
                icon: Icons.event_available,
              );
            }

            final childMap = {
              for (final child in (children.valueOrNull ?? []))
                child.id: child.name,
            };

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: today.length,

              separatorBuilder: (_, __) =>
                  responsive.gapH(8, tablet: 10, desktop: 12),

              itemBuilder: (context, index) {
                final session = today[index];

                final childName = childMap[session.childId] ?? 'Unknown Child';

                return SessionCard(
                  session: session,
                  childName: toTitleCase(childName),

                  onEdit: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditSessionScreen(session: session),
                      ),
                    );

                    ref.invalidate(therapistSessionsProvider);
                  },

                  onNotes: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SessionNotesScreen(
                          session: session,
                          childName: childName,
                        ),
                      ),
                    );

                    ref.invalidate(therapistSessionsProvider);
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
