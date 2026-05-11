import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/session.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/rating_slider.dart';
import '../providers/therapist_provider.dart';

class SessionNotesScreen extends ConsumerStatefulWidget {
  final SessionModel session;
  final String childName;

  const SessionNotesScreen({
    super.key,
    required this.session,
    required this.childName,
  });

  @override
  ConsumerState<SessionNotesScreen> createState() => _SessionNotesScreenState();
}

class _SessionNotesScreenState extends ConsumerState<SessionNotesScreen> {
  String _mood            = 'calm';
  int _attentionScore     = 5;
  int _communicationScore = 5;
  int _motorScore         = 5;
  int _behaviorScore      = 5;
  final _activities       = <String>{};
  final _whatWorkedCtr    = TextEditingController();
  final _whatDidntCtr     = TextEditingController();
  final _homeworkCtr      = TextEditingController();

  static const _moodData = [
    {'key': 'sad',     'emoji': '😢', 'label': 'Sad',     'color': Color(0xFF5B8DEF)},
    {'key': 'calm',    'emoji': '😐', 'label': 'Calm',    'color': Color(0xFF4CD7A2)},
    {'key': 'happy',   'emoji': '🙂', 'label': 'Happy',   'color': Color(0xFFFFD56B)},
    {'key': 'excited', 'emoji': '😄', 'label': 'Excited', 'color': Color(0xFFFF9F43)},
  ];

  static const _activityOptions = [
    'Ball Play',
    'Sound Imitation',
    'Mirror Imitation',
    'Object Matching',
    'Puzzle Activity',
    'Pretend Play',
    'Drawing / Art',
    'Gross Motor',
    'Fine Motor',
    'Sorting / Stacking',
    'Music / Rhythm',
    'Social Story',
    'Turn Taking',
    'Flash Cards',
    'Sensory Play',
    'Breathing Exercise',
    'Role Play',
    'AAC Device',
  ];

  @override
  void dispose() {
    _whatWorkedCtr.dispose();
    _whatDidntCtr.dispose();
    _homeworkCtr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final payload = {
      'mood':                _mood,
      'attention_score':     _attentionScore,
      'communication_score': _communicationScore,
      'motor_score':         _motorScore,
      'behavior_score':      _behaviorScore,
      'activities':          _activities.toList(),
      if (_whatWorkedCtr.text.trim().isNotEmpty)
        'what_worked': _whatWorkedCtr.text.trim(),
      if (_whatDidntCtr.text.trim().isNotEmpty)
        'what_didnt_work': _whatDidntCtr.text.trim(),
      if (_homeworkCtr.text.trim().isNotEmpty)
        'homework': _homeworkCtr.text.trim(),
    };

    await ref
        .read(sessionNotesProvider.notifier)
        .submit(widget.session.id, payload);

    if (mounted && ref.read(sessionNotesProvider).success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session notes saved — AI snapshot rebuilding'),
          backgroundColor: AppColors.mintGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionNotesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Session Notes'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMoodSection(),
                  const SizedBox(height: 28),
                  _buildSkillScores(),
                  const SizedBox(height: 28),
                  _buildActivities(),
                  const SizedBox(height: 28),
                  _buildObservations(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(state.error!,
                  style: const TextStyle(color: AppColors.softCoral, fontSize: 13)),
            ),
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: AppButton(
              label:     'Save Notes',
              loading:   state.loading,
              onPressed: _submit,
              icon:      Icons.check_circle_outline,
            ),
          ),
        ],
      ),
    );
  }

  // ── Header card ───────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
            child: Text(
              widget.childName[0].toUpperCase(),
              style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.childName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16)),
                Text(
                  '${widget.session.typeLabel}  •  ${AppDateUtils.formatTime(widget.session.scheduledAt)}  •  ${widget.session.durationMin} min',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.mintGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.session.mode == 'online' ? 'Online' : 'In-Person',
              style: const TextStyle(
                  color: AppColors.mintGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section 1: Mood ───────────────────────────────────────────────────────
  Widget _buildMoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Child's Mood Today", Icons.emoji_emotions_outlined),
        const SizedBox(height: 16),
        Row(
          children: _moodData.map((m) {
            final key      = m['key'] as String;
            final emoji    = m['emoji'] as String;
            final label    = m['label'] as String;
            final color    = m['color'] as Color;
            final selected = _mood == key;

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _mood = key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withValues(alpha: 0.15)
                        : AppColors.surface,
                    border: Border.all(
                      color: selected ? color : AppColors.divider,
                      width: selected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(emoji,
                          style: TextStyle(
                              fontSize: selected ? 34 : 26)),
                      const SizedBox(height: 6),
                      Text(label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: selected
                                ? color
                                : AppColors.textSecondary,
                          )),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Section 2: Skill scores ───────────────────────────────────────────────
  Widget _buildSkillScores() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Skill Scores', Icons.bar_chart_outlined),
        const SizedBox(height: 16),
        RatingSlider(
          label:     'Attention & Focus',
          value:     _attentionScore,
          onChanged: (v) => setState(() => _attentionScore = v),
        ),
        const SizedBox(height: 12),
        RatingSlider(
          label:     'Communication',
          value:     _communicationScore,
          onChanged: (v) => setState(() => _communicationScore = v),
        ),
        const SizedBox(height: 12),
        RatingSlider(
          label:     'Motor Skills',
          value:     _motorScore,
          onChanged: (v) => setState(() => _motorScore = v),
        ),
        const SizedBox(height: 12),
        RatingSlider(
          label:     'Social Behavior',
          value:     _behaviorScore,
          onChanged: (v) => setState(() => _behaviorScore = v),
        ),
      ],
    );
  }

  // ── Section 3: Activities ─────────────────────────────────────────────────
  Widget _buildActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Activities Used', Icons.sports_handball_outlined),
        const SizedBox(height: 4),
        const Text(
          'Select all activities done in this session',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _activityOptions.map((act) {
            final sel = _activities.contains(act);
            return GestureDetector(
              onTap: () => setState(() {
                sel ? _activities.remove(act) : _activities.add(act);
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.primaryBlue.withValues(alpha: 0.1)
                      : AppColors.surface,
                  border: Border.all(
                    color: sel ? AppColors.primaryBlue : AppColors.divider,
                    width: sel ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  act,
                  style: TextStyle(
                    fontSize: 13,
                    color: sel
                        ? AppColors.primaryBlue
                        : AppColors.textSecondary,
                    fontWeight:
                        sel ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Section 4: Observations ───────────────────────────────────────────────
  Widget _buildObservations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Session Observations', Icons.notes_outlined),
        const SizedBox(height: 16),
        _observationField(
          controller: _whatWorkedCtr,
          label: 'What Worked Today',
          hint: 'Activities or approaches that led to positive responses...',
          icon: Icons.check_circle_outline,
          iconColor: AppColors.mintGreen,
        ),
        const SizedBox(height: 14),
        _observationField(
          controller: _whatDidntCtr,
          label: "What Didn't Work",
          hint: 'What caused disengagement, refusal, or meltdowns...',
          icon: Icons.cancel_outlined,
          iconColor: AppColors.softCoral,
        ),
        const SizedBox(height: 14),
        _observationField(
          controller: _homeworkCtr,
          label: 'Homework Assigned',
          hint: 'Activities to practice at home before next session...',
          icon: Icons.home_outlined,
          iconColor: AppColors.warmYellow,
        ),
      ],
    );
  }

  Widget _observationField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 20),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ],
    );
  }
}
