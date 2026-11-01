import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/auth_content.dart';
import '../../core/design_system.dart';
import '../../core/services/sound_service.dart';
import '../../shared/service_locator.dart';
import 'auth_validators.dart';
import 'cubit/auth_cubit.dart';

/// Şifre sıfırlama ekranı: e-posta formu, gönderim sonrası "mesaj gönderildi"
/// illüstrasyonlu onay durumu.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.cubit});

  final AuthCubit? cubit;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isSent = false;
  bool _submitting = false;
  String? _serverError;
  String _sentEmail = '';

  AuthCubit? _ownedCubit;

  AuthCubit get _cubit => _ownedCubit ??= widget.cubit ?? sl<AuthCubit>();

  @override
  void dispose() {
    _emailController.dispose();
    _ownedCubit?.close();
    super.dispose();
  }

  Future<void> _sendLink() async {
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      SoundService.instance.play(SoundEvent.wrong);
      return;
    }
    if (_submitting) return;

    final String email = _emailController.text.trim();
    setState(() {
      _submitting = true;
      _serverError = null;
    });
    // GoTrue kullanıcı listesini sızdırmamak için adres kayıtlı olmasa da
    // başarı döner; ekran bu yüzden her durumda "kontrol et" sayfasına geçer.
    await _cubit.sendPasswordResetLink(email: email);

    final AuthState state = _cubit.state;
    if (!mounted) return;
    setState(() => _submitting = false);

    if (state is AuthResetLinkSent) {
      SoundService.instance.play(SoundEvent.correct);
      setState(() {
        _sentEmail = state.email;
        _isSent = true;
      });
    } else if (state is AuthError) {
      setState(() => _serverError = state.message);
      SoundService.instance.play(SoundEvent.wrong);
    }
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
              child: _isSent ? _buildSent() : _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Image.asset(
                ForgotPasswordContent.formImageAsset,
                fit: BoxFit.contain,
                height: 220,
                semanticLabel: ForgotPasswordContent.title,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            ForgotPasswordContent.title,
            style: AppTypography.headingMd.copyWith(
              color: AppColors.inkDisplay,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            ForgotPasswordContent.subtitle,
            style: AppTypography.bodyLg.copyWith(color: AppColors.bodyMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          TextFormField(
            controller: _emailController,
            validator: AuthValidators.email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _sendLink(),
            style: AppTypography.bodyLg.copyWith(color: AppColors.body),
            decoration: const InputDecoration(
              labelText: AuthContent.emailLabel,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: _submitting ? null : _sendLink,
            child: Text(ForgotPasswordContent.ctaLabel),
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
        ],
      ),
    );
  }

  Widget _buildSent() {
    final List<String> descriptionParts = ForgotPasswordContent.sentDescription
        .split('{email}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Image.asset(
              ForgotPasswordContent.sentImageAsset,
              fit: BoxFit.contain,
              height: 220,
              semanticLabel: ForgotPasswordContent.sentTitle,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          ForgotPasswordContent.sentTitle,
          style: AppTypography.headingMd.copyWith(color: AppColors.inkDisplay),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: descriptionParts.first),
              TextSpan(
                text: _sentEmail,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.bodyStrong,
                ),
              ),
              TextSpan(text: descriptionParts.last),
            ],
          ),
          style: AppTypography.bodyLg.copyWith(color: AppColors.bodyMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        ElevatedButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: Text(ForgotPasswordContent.backToLoginLabel),
        ),
      ],
    );
  }
}
