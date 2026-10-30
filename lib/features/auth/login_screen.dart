import 'package:en_bubixo/features/level/level_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/auth_content.dart';
import '../../core/design_system.dart';
import 'auth_validators.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import 'widgets/or_divider.dart';

/// Giriş ekranı: illüstrasyon, e-posta/şifre formu (48px, hairline kontur,
/// odakta macaw), yeşil BÜYÜK HARF CTA, VEYA ayırıcı, marka Google butonu
/// ve altta kayda yönlendiren satır.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToLevel() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LevelScreen()),
    );
  }

  void _submit() {
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    _goToLevel();
  }

  void _openSignup() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SignupScreen()));
  }

  void _openForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Image.asset(
                          LoginContent.imageAsset,
                          fit: BoxFit.contain,
                          height: 220,
                          semanticLabel: LoginContent.title,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      LoginContent.title,
                      style: AppTypography.headingMd.copyWith(
                        color: AppColors.inkDisplay,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      LoginContent.subtitle,
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.bodyMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TextFormField(
                      controller: _emailController,
                      validator: AuthValidators.email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.body,
                      ),
                      decoration: InputDecoration(
                        labelText: AuthContent.emailLabel,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    TextFormField(
                      controller: _passwordController,
                      validator: AuthValidators.password,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.body,
                      ),
                      decoration: InputDecoration(
                        labelText: AuthContent.passwordLabel,
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword ? Iconsax.eye : Iconsax.eye_slash,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(LoginContent.ctaLabel),
                    ),
                    TextButton(
                      onPressed: _openForgotPassword,
                      child: Text(LoginContent.forgotLabel),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const OrDivider(),
                    const SizedBox(height: AppSpacing.base),
                    ElevatedButton(
                      style: AppTheme.googleButton,
                      onPressed: _goToLevel,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              LoginContent.googleIconAsset,
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(LoginContent.googleCtaLabel),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextButton(
                      onPressed: _openSignup,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: LoginContent.signupPromptLabel,
                              style: AppTypography.labelUppercaseSm.copyWith(
                                color: AppColors.bodyMuted,
                              ),
                            ),
                            TextSpan(text: LoginContent.signupCtaLabel),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
