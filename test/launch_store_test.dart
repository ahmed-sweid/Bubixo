import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:en_bubixo/core/data/launch_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('boş cihaz kaydında ilk akış tamamlanmamış sayılır', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferencesLaunchStore store = SharedPreferencesLaunchStore(
      await SharedPreferences.getInstance(),
    );

    expect(await store.isIntroCompleted(), isFalse);
  });

  test('markIntroCompleted bir daha okunduğunda true döner', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferencesLaunchStore store = SharedPreferencesLaunchStore(
      await SharedPreferences.getInstance(),
    );

    await store.markIntroCompleted();

    expect(await store.isIntroCompleted(), isTrue);
  });

  test('LaunchStore.init çağrılmamış ortam sessizdir', () async {
    // `init` yalnız main()den çağrılır; testler onu çağırmadığı için
    // [LaunchStore.current] varsayılanında kalır ve diske dokunmaz.
    expect(await LaunchStore.current.isIntroCompleted(), isFalse);
    await LaunchStore.current.markIntroCompleted();
    expect(await LaunchStore.current.isIntroCompleted(), isFalse);
  });

  test('LaunchStore.init gerçek depoyu kurar', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await LaunchStore.init();

    expect(await LaunchStore.current.isIntroCompleted(), isFalse);
    await LaunchStore.current.markIntroCompleted();
    expect(await LaunchStore.current.isIntroCompleted(), isTrue);
  });
}
