import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:en_bubixo/core/constants/sound_content.dart';

/// `AssetSource` yolları `assets/` önekinden sonrasıdır; paket anahtarı ise
/// önekle birlikte yazılır. Tablodaki her dosyanın gerçekten pakete girdiğini
/// bu test doğrular.
void main() {
  testWidgets('Ses tablosundaki her asset pakette bulunur', (_) async {
    final List<String> missing = <String>[];
    for (final List<String> assets in SoundContent.files.values) {
      for (final String asset in assets) {
        try {
          await rootBundle.load('assets/$asset');
        } on FlutterError {
          missing.add(asset);
        }
      }
    }
    expect(missing, isEmpty);
  });

  testWidgets('Her ses olayı en az bir dosyaya bağlı', (_) async {
    for (final SoundEvent event in SoundEvent.values) {
      expect(SoundContent.assetsFor(event), isNotEmpty, reason: '$event');
    }
  });
}
