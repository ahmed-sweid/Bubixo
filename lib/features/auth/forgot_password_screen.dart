import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/auth_content.dart';
import '../../core/design_system.dart';
import 'auth_validators.dart';

/// Şifre sıfırlama ekranı: e-posta formu, gönderim sonrası "mesaj gönderildi"
/// illüstrasyonlu onay durumu. Gerçek e-posta gönderimi backend'e bağlanınca
/// [ForgotPasswordContent] akışı içindeki submit'e entegre edilir.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isSent = false;
  String _sentEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendLink() {
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    // TODO(backend): e-posta gönderim servisi buraya bağlanacak.
    setState(() {
      _sentEmail = _emailController.text.trim();
      _isSent = true;
    });
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
            onPressed: _sendLink,
            child: Text(ForgotPasswordContent.ctaLabel),
          ),
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
