import 'dart:async';

import 'package:en_bubixo/features/level/level_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/auth_content.dart';
import '../../core/design_system.dart';
import '../../core/services/sound_service.dart';
import '../../shared/service_locator.dart';
import 'auth_validators.dart';
import 'cubit/auth_cubit.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import 'widgets/or_divider.dart';

/// Giriş ekranı: illüstrasyon, e-posta/şifre formu (48px, hairline kontur,
/// odakta macaw), yeşil BÜYÜK HARF CTA, VEYA ayırıcı, marka Google butonu
/// ve altta kayda yönlendiren satır.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.cubit});

  /// Test ve özel durumlar için enjekte edilebilir cubit; normal akışta
  /// `null` bırakılır ve ekran `sl()`'den kendi örneğini alır.
  final AuthCubit? cubit;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;
  String? _serverError;
  bool _navigated = false;

  /// Ekran kendi cubit'ini ilk kimlik komutunda `sl()`'den alır: yalnızca
  /// render edilen ekran (widget testleri) DI gerektirmez.
  AuthCubit? _ownedCubit;
  StreamSubscription<AuthState>? _authSubscription;

  AuthCubit get _cubit {
    final cubit = _ownedCubit ??= widget.cubit ?? sl<AuthCubit>();
    // Tek yönlendirme yolu dinleyici: OAuth'ta oturum komut dönmeden *sonra*
    // gelir, komuttan sonra okumak yetmez.
    _authSubscription ??= cubit.stream.listen(_onAuthState);
    return cubit;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    unawaited(_authSubscription?.cancel());
    _ownedCubit?.close();
    super.dispose();
  }

  void _onAuthState(AuthState state) {
    if (!mounted) return;

    switch (state) {
      case AuthSignedIn():
        if (_navigated) return;
        _navigated = true;
        setState(() => _submitting = false);
        _goToLevel();
      case AuthError(:final message):
        setState(() {
          _submitting = false;
          _serverError = message;
        });
        SoundService.instance.play(SoundEvent.wrong);
      case AuthBusy():
        setState(() => _submitting = true);
      case AuthSignedOut():
        // Oturum kendiliğinden düştü ya da OAuth tarayıcıda yarım kaldı.
        setState(() {
          _navigated = false;
          _submitting = false;
        });
      case AuthChecking():
      case AuthResetLinkSent():
        break;
    }
  }

  void _goToLevel() {
    SoundService.instance.play(SoundEvent.transition);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LevelScreen()),
    );
  }

  Future<void> _submit() async {
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      SoundService.instance.play(SoundEvent.wrong);
      return;
    }
    if (_submitting) return;

    setState(() => _serverError = null);
    await _cubit.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  Future<void> _signInWithGoogle() async {
    if (_submitting) return;
    SoundService.instance.play(SoundEvent.tap);
    setState(() => _serverError = null);
    await _cubit.signInWithGoogle();
  }

  void _openSignup() {
    SoundService.instance.play(SoundEvent.tap);
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SignupScreen()));
  }

  void _openForgotPassword() {
    SoundService.instance.play(SoundEvent.tap);
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
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const _BusyChip()
                          : Text(LoginContent.ctaLabel),
                    ),
                    if (_serverError != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _serverError!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.accentCardinal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    TextButton(
                      onPressed: _openForgotPassword,
                      child: Text(LoginContent.forgotLabel),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const OrDivider(),
                    const SizedBox(height: AppSpacing.base),
                    ElevatedButton(
                      style: AppTheme.googleButton,
                      onPressed: _submitting ? null : _signInWithGoogle,
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

/// CTA dolgu rengini bozmayan 18px bekleme göstergesi.
class _BusyChip extends StatelessWidget {
  const _BusyChip();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: AppColors.canvas,
      ),
    );
  }
}
