import 'dart:math';

import 'package:audioplayers/audioplayers.dart';

import '../constants/sound_content.dart';

export '../constants/sound_content.dart' show SoundEvent;

/// Uygulamanın tek ses efektı kapısı: `SoundService.instance.play(SoundEvent.correct)`.
///
/// [init] yalnızca `main()`den çağrılır; testler başlatmadığı için sessiz kalır
/// ve eklenti kanalı olmayan ortamda hata üretmez.
class SoundService {
  SoundService._();

  static final SoundService instance = SoundService._();

  static final Random _random = Random();

  bool _initialized = false;
  final Map<SoundEvent, AudioPlayer> _players = <SoundEvent, AudioPlayer>{};

  /// Profil ayarındaki "Ses efektleri" anahtarı.
  bool enabled = true;

  /// Kısa UI sesleri arka planda rahatsız etmesin diye sabit alçak seviye.
  double volume = 0.6;

  void init({bool? soundEffectsEnabled}) {
    _initialized = true;
    enabled = soundEffectsEnabled ?? enabled;
  }

  Future<void> play(SoundEvent event) async {
    if (!_initialized || !enabled) return;
    final List<String> assets = SoundContent.assetsFor(event);
    if (assets.isEmpty) return;

    final AudioPlayer player = _players.putIfAbsent(
      event,
      () => AudioPlayer()..setReleaseMode(ReleaseMode.stop),
    );
    try {
      await player.play(
        AssetSource(assets[_random.nextInt(assets.length)]),
        volume: volume,
      );
    } on Exception {
      // Ses tek başına akışı bozmamalı: asset eksikse ya da platform sesi
      // meşgulse olay sessizce geçilir.
    }
  }

  Future<void> dispose() async {
    _initialized = false;
    for (final AudioPlayer player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}
