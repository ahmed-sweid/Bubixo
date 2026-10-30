import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/auth_content.dart';
import '../../core/design_system.dart';
import '../level/level_screen.dart';
import 'auth_validators.dart';

/// Kayıt ekranı: illüstrasyonsuz form (Duolingo'nun kayıt akışı gibi) —
/// başlık, e-posta/şifre alanları, yeşil HESAP OLUŞTUR CTA ve giriş ekranına
/// dönen satır.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    // TODO(backend): hesap oluşturma servisi buraya bağlanacak.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LevelScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Iconsax.arrow_left_2),
        ),
      ),
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
                          SignupContent.imageAsset,
                          fit: BoxFit.contain,
                          height: 220,
                          semanticLabel: SignupContent.title,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      SignupContent.title,
                      style: AppTypography.headingMd.copyWith(
                        color: AppColors.inkDisplay,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      SignupContent.subtitle,
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.bodyMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TextFormField(
                      controller: _nameController,
                      validator: AuthValidators.required,
                      keyboardType: TextInputType.name,
                      autofillHints: const [AutofillHints.name],
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.body,
                      ),
                      decoration: const InputDecoration(
                        labelText: AuthContent.nameLabel,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    TextFormField(
                      controller: _emailController,
                      validator: AuthValidators.email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.body,
                      ),
                      decoration: const InputDecoration(
                        labelText: AuthContent.emailLabel,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    TextFormField(
                      controller: _passwordController,
                      validator: AuthValidators.password,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.next,
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
                    const SizedBox(height: AppSpacing.base),
                    TextFormField(
                      controller: _passwordConfirmController,
                      validator: (String? value) =>
                          AuthValidators.passwordConfirm(
                            value,
                            _passwordController.text,
                          ),
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.body,
                      ),
                      decoration: InputDecoration(
                        labelText: AuthContent.passwordConfirmLabel,
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
                      child: Text(SignupContent.ctaLabel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: Text(SignupContent.existingAccountLabel),
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
