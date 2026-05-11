import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _phoneCtr = TextEditingController();
  final _passCtr  = TextEditingController();
  bool _obscure   = true;

  @override
  void dispose() {
    _phoneCtr.dispose();
    _passCtr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final phone = '+91${_phoneCtr.text.trim()}';
    await ref
        .read(authProvider.notifier)
        .login(phone, _passCtr.text);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final loading   = authState.isLoading ||
        (authState.valueOrNull?.loading ?? false);
    final error     = authState.valueOrNull?.error;

    ref.listen(authProvider, (_, next) {
      if (next.valueOrNull?.status == AuthStatus.authenticated) {
        final role = next.valueOrNull?.user?.role ?? '';
        switch (role) {
          case 'therapist':    context.go('/therapist');   break;
          case 'parent':       context.go('/parent');      break;
          case 'center_head':  context.go('/center-head'); break;
          default:             context.go('/login');
        }
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              _buildHeader(context),
              const SizedBox(height: 40),
              if (error != null) _buildError(context, error),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _phoneCtr,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        prefixText: '+91 ',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: Validators.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passCtr,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label:     'Sign In',
                      onPressed: _submit,
                      loading:   loading,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: AppColors.therapistGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.psychology, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 16),
        Text('NaiviSense',
            style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 4),
        Text('Therapy coordination platform',
            style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.softCoral.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softCoral.withValues(alpha:0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.softCoral, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.softCoral)),
          ),
        ],
      ),
    );
  }
}
