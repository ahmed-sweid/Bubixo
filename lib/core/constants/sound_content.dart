/// Uygulama genelinde çalınan ses efektlerinin olay → dosya eşlemesi.
///
/// Yollar `assets/` öneki olmadan verilir; `audioplayers` kendi önekini ekler.
enum SoundEvent {
  tap,
  optionSelect,
  menuOpen,
  correct,
  wrong,
  sessionComplete,
  reward,
  memorize,
  transition,
  drag,
  goalReached,
  launch,
}

abstract final class SoundContent {
  /// Birden fazla dosya olan olaylarda rastgele seçim yapılır; böylece tekrar
  /// eden sesler tekdüze olmaz.
  static const Map<SoundEvent, List<String>> files = <SoundEvent, List<String>>{
    SoundEvent.tap: <String>[
      'sound_effects/UI_Click_Bubble-001.wav',
      'sound_effects/UI_Click_Bubble-002.wav',
    ],
    SoundEvent.optionSelect: <String>['sound_effects/UI_Click_Generic-004.wav'],
    SoundEvent.menuOpen: <String>[
      'sound_effects/UI_Menu_Button_Glitchy-001.wav',
    ],
    SoundEvent.correct: <String>[
      'sound_effects/UI_Confirm_Blips_Smooth-001.wav',
      'sound_effects/UI_Confirm_Blips_Smooth-003.wav',
      'sound_effects/UI_Confirm_Blips_Smooth-005.wav',
    ],
    SoundEvent.wrong: <String>[
      'sound_effects/UI_Deny_Bleep-001.wav',
      'sound_effects/UI_Deny_Bleep-002.wav',
      'sound_effects/UI_Click_Error_Pop-001.wav',
    ],
    SoundEvent.sessionComplete: <String>[
      'sound_effects/UI_Confirm_Cyber_Whoosh-003.wav',
      'sound_effects/UI_Confirm_SciFi_Long-001.wav',
    ],
    SoundEvent.reward: <String>['sound_effects/UI_Welcome_Modern-001.wav'],
    SoundEvent.memorize: <String>['sound_effects/UI_Whoosh_Magic.wav'],
    SoundEvent.transition: <String>['sound_effects/UI_Swoosh_Short-001.wav'],
    SoundEvent.drag: <String>[
      'sound_effects/UI_Slide_Transition_Short-001.wav',
    ],
    SoundEvent.goalReached: <String>['sound_effects/UI_Notif_Cute-001.wav'],
    SoundEvent.launch: <String>['sound_effects/UI_Pop_Classic-001.wav'],
  };

  static List<String> assetsFor(SoundEvent event) =>
      files[event] ?? const <String>[];
}
