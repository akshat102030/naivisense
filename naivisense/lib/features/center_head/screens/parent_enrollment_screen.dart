import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/parent_enrollment_provider.dart';

class ParentEnrollmentScreen extends ConsumerStatefulWidget {
  const ParentEnrollmentScreen({super.key});

  @override
  ConsumerState<ParentEnrollmentScreen> createState() =>
      _ParentEnrollmentScreenState();
}

class _ParentEnrollmentScreenState
    extends ConsumerState<ParentEnrollmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl     = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _showPassword  = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'name':     _nameCtrl.text.trim(),
      'phone':    _phoneCtrl.text.trim(),
      'password': _passwordCtrl.text,
    };
    if (_emailCtrl.text.trim().isNotEmpty) {
      data['email'] = _emailCtrl.text.trim();
    }

    final ok = await ref.read(parentEnrollmentProvider.notifier).submit(data);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parent registered successfully'),
          backgroundColor: AppColors.mintGreen,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(parentEnrollmentProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Register New Parent'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.parentGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.family_restroom,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Parent Account',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Create login credentials for the parent',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Name
              _SectionLabel(label: 'Full Name'),
              const SizedBox(height: 8),
              _buildField(
                controller: _nameCtrl,
                hint:       'Parent\'s full name',
                icon:       Icons.person_outline,
                validator: (v) =>
                    (v == null || v.trim().length < 2)
                        ? 'Name must be at least 2 characters'
                        : null,
              ),

              const SizedBox(height: 16),

              // Phone
              _SectionLabel(label: 'Phone Number'),
              const SizedBox(height: 8),
              _buildField(
                controller:  _phoneCtrl,
                hint:        'e.g. 9876543210',
                icon:        Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.trim().length < 10)
                        ? 'Enter a valid phone number'
                        : null,
              ),

              const SizedBox(height: 16),

              // Email
              _SectionLabel(label: 'Email Address (optional)'),
              const SizedBox(height: 8),
              _buildField(
                controller:   _emailCtrl,
                hint:         'parent@example.com',
                icon:         Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final emailReg = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  return emailReg.hasMatch(v.trim()) ? null : 'Enter a valid email';
                },
              ),

              const SizedBox(height: 16),

              // Password
              _SectionLabel(label: 'Password'),
              const SizedBox(height: 8),
              TextFormField(
                controller:     _passwordCtrl,
                obscureText:    !_showPassword,
                decoration: InputDecoration(
                  hintText:     'Minimum 6 characters',
                  prefixIcon:   const Icon(Icons.lock_outline,
                      color: AppColors.textSecondary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                  filled:           true,
                  fillColor:        AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:   BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.divider, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primaryBlue, width: 1.5),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.length < 6)
                        ? 'Password must be at least 6 characters'
                        : null,
              ),

              const SizedBox(height: 12),

              // Info note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: AppColors.primaryBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'The parent will use these credentials to log in and track their child\'s progress.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primaryBlue,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              if (state.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:        AppColors.softCoral.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.softCoral.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: AppColors.softCoral),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Submit button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: state.loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mintGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: state.loading
                      ? const SizedBox(
                          width:  22,
                          height: 22,
                          child:  CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text(
                          'Register Parent',
                          style: TextStyle(
                              fontSize:   16,
                              fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller:   controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText:   hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled:     true,
        fillColor:  AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: AppColors.primaryBlue, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: AppColors.textSecondary),
      );
}
