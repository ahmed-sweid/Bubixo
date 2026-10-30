import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/profile_models.dart';

part 'profile_state.dart';

/// Profil sekmesinin durum yönetimi; veri katmanı bağlanınca kullanıcı,
/// ayarlar ve istatistikler bu cubit üzerinden yüklenecek.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({ProfileState initialState = const ProfileLoading()})
    : super(initialState);
}
