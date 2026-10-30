import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/profile_content.dart';
import '../../core/design_system.dart';
import '../../core/models/profile_models.dart';
import '../auth/auth_validators.dart';
import 'widgets/identity_card.dart';

/// Profil bilgilerini (ad, e-posta, foto) düzenleyen alt sheet.
///
/// Değerler dışarıdan verilir; kaydetme ve fotoğraf değiştirme cubit'e
/// callback ile iletilir.
Future<void> showProfileEditSheet(
  BuildContext context, {
  required UserProfile profile,
  required ValueChanged<UserProfile> onSave,
  VoidCallback? onChangePhoto,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext _) => _ProfileEditSheet(
      profile: profile,
      onSave: onSave,
      onChangePhoto: onChangePhoto,
    ),
  );
}

class _ProfileEditSheet extends StatefulWidget {
  const _ProfileEditSheet({
    required this.profile,
    required this.onSave,
    this.onChangePhoto,
  });

  final UserProfile profile;
  final ValueChanged<UserProfile> onSave;
  final VoidCallback? onChangePhoto;

  @override
  State<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<_ProfileEditSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(
    text: widget.profile.name,
  );
  late final TextEditingController _emailController = TextEditingController(
    text: widget.profile.email,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    widget.onSave(
      widget.profile.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                ProfileContent.editSheetTitle,
                style: AppTypography.headingSm.copyWith(
                  color: AppColors.inkDisplay,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  ProfileAvatar(profile: widget.profile, size: 64),
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: widget.onChangePhoto,
                      icon: const Icon(Iconsax.image, size: 18),
                      label: const Text(ProfileContent.avatarChangeCtaLabel),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: ProfileContent.nameFieldLabel,
                ),
                validator: AuthValidators.required,
              ),
              const SizedBox(height: AppSpacing.base),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (String _) => _save(),
                decoration: const InputDecoration(
                  labelText: ProfileContent.emailFieldLabel,
                ),
                validator: AuthValidators.email,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: _save,
                child: const Text(ProfileContent.saveCtaLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
