import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/inputs.dart';
import '../../core/widgets/vesper_logo.dart';
import 'sign_in_view_model.dart';

/// View: only widgets. Everything it shows comes from SignInViewModel.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit(SignInViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final signedIn = await viewModel.signIn(_email.text, _password.text);
    if (signedIn && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  void _showReset() {
    // The backend has no self-service reset; the coordinator sets a new temporary password
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset your password'),
        content: const Text('Ask your patrol coordinator to set a new temporary password for you.'),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignInViewModel>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const VesperLogo(height: 34),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
                decoration: BoxDecoration(color: AppColors.sky, borderRadius: BorderRadius.circular(14)),
                child: Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Sign In',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.navy, fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Sign in to see the alerts assigned to you',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.navy, fontSize: 13),
                        ),
                        const SizedBox(height: 22),
                        if (viewModel.error != null) ...[
                          _ErrorBanner(message: viewModel.error!),
                          const SizedBox(height: 16),
                        ],
                        VesperTextField(
                          label: 'Email',
                          controller: _email,
                          hint: 'you@example.org',
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          validator: viewModel.validateEmail,
                        ),
                        const SizedBox(height: 16),
                        VesperTextField(
                          label: 'Password',
                          controller: _password,
                          obscureText: viewModel.passwordHidden,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          validator: viewModel.validatePassword,
                          onSubmitted: (_) => _submit(viewModel),
                          suffix: IconButton(
                            tooltip: viewModel.passwordHidden ? 'Show password' : 'Hide password',
                            icon: Icon(
                              viewModel.passwordHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AppColors.white,
                            ),
                            onPressed: viewModel.togglePasswordVisibility,
                          ),
                        ),
                        const SizedBox(height: 26),
                        PrimaryButton(
                          label: 'Sign in',
                          busy: viewModel.busy,
                          onPressed: () => _submit(viewModel),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Text('Forgot password? ', style: TextStyle(color: AppColors.navy, fontSize: 13)),
                            GestureDetector(
                              onTap: _showReset,
                              child: const Text(
                                'Reset',
                                style: TextStyle(color: AppColors.navy, fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(8)),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
