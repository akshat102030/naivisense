import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/child.dart';
import '../providers/parent_provider.dart';

class RaiseAlertScreen extends ConsumerStatefulWidget {
  final ChildModel child;
  const RaiseAlertScreen({super.key, required this.child});

  @override
  ConsumerState<RaiseAlertScreen> createState() => _RaiseAlertScreenState();
}

class _RaiseAlertScreenState extends ConsumerState<RaiseAlertScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _descCtr  = TextEditingController();

  String _alertType = 'behavioral';
  String _severity  = 'medium';

  static const _alertTypes = [
    ('behavioral',  Icons.psychology_outlined,   'Behavioral'),
    ('medical',     Icons.local_hospital_outlined,'Medical'),
    ('emotional',   Icons.favorite_border,        'Emotional'),
    ('academic',    Icons.menu_book_outlined,      'Academic'),
    ('social',      Icons.group_outlined,          'Social'),
    ('other',       Icons.more_horiz,              'Other'),
  ];

  static const _severities = [
    ('low',      'Low',      AppColors.mintGreen),
    ('medium',   'Medium',   AppColors.warmYellow),
    ('high',     'High',     AppColors.softCoral),
    ('critical', 'Critical', Color(0xFFB00020)),
  ];

  @override
  void dispose() {
    _descCtr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(alertProvider.notifier).submit({
      'childId':     widget.child.id,
      'type':        _alertType,
      'severity':    _severity,
      'description': _descCtr.text.trim(),
    });

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alert raised successfully'),
          backgroundColor: AppColors.mintGreen,
        ),
      );
      context.pop();
    } else {
      final err = ref.read(alertProvider).error ?? 'Failed to raise alert';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.softCoral),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final alertState = ref.watch(alertProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Raise Alert — ${widget.child.name}'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoBanner(),
              const SizedBox(height: 24),
              _sectionLabel(context, 'Alert Type'),
              const SizedBox(height: 12),
              _buildAlertTypeGrid(),
              const SizedBox(height: 24),
              _sectionLabel(context, 'Severity Level'),
              const SizedBox(height: 12),
              _buildSeverityRow(),
              const SizedBox(height: 24),
              _sectionLabel(context, 'Description'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtr,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Describe what happened, when it started, '
                      'any patterns you noticed…',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().length < 10)
                        ? 'Please provide at least 10 characters'
                        : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: alertState.loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.softCoral,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: alertState.loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notification_important_outlined),
                            SizedBox(width: 8),
                            Text('Submit Alert',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline,
              color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Alerts are sent directly to ${widget.child.name}\'s therapy team. '
              'For medical emergencies, please call emergency services immediately.',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.primaryBlue, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTypeGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.15,
      children: _alertTypes.map((t) {
        final (val, icon, label) = t;
        final selected = _alertType == val;
        return GestureDetector(
          onTap: () => setState(() => _alertType = val),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primaryBlue.withValues(alpha: 0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? AppColors.primaryBlue
                    : AppColors.divider,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    color: selected
                        ? AppColors.primaryBlue
                        : AppColors.textSecondary,
                    size: 26),
                const SizedBox(height: 6),
                Text(label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: selected
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                    )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeverityRow() {
    return Row(
      children: _severities.map((s) {
        final (val, label, color) = s;
        final selected = _severity == val;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _severity = val),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(
                  right: val == 'critical' ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.12)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? color : AppColors.divider,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(height: 6),
                  Text(label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: selected ? color : AppColors.textSecondary,
                      )),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Text(text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w600));
  }
}
