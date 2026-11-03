import 'package:en_bubixo/features/shell/home_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/level_content.dart';
import '../../core/data/launch_store.dart';
import '../../core/design_system.dart';
import '../../shared/service_locator.dart';
import '../common/states/app_error_view.dart';
import 'cubit/level_cubit.dart';
import 'data/models/level_models.dart';
import 'data/repositories/level_repository.dart';
import 'level_test_screen.dart';
import 'widgets/level_select_card.dart';

/// Seviye belirleme ekranı: ızgara sunucudaki `levels` kataloğundan çizilir;
/// veri katmanı yokken yerleşik CEFR basamakları durur. Kartlardan dokunarak
/// seçim yapılır, onay seçimi sunucuya yazar ve tanıtım yığınını siler.
/// Katalog çözülmemişken kartlar yerleşik listeden görünür; sunucu
/// yanıtlayınca ızgara kendi listesine döner.
class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1.0;
    } else {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  /// İlk akış yalnız yazma onaylandıktan sonra biter: bayrak yazılır ve
  /// tanıtım yığını (splash, onboarding, giriş) geri gelmeyecek şekilde
  /// silinir. Yazma reddedilirse ekranda kalınır ve hata butonun altında
  /// gösterilir — seviyesiz girmek sonradan düzeltilmesi gereken boşluk
  /// bırakır.
  Future<void> _confirm(BuildContext context, LevelCubit controller) async {
    final bool saved = await controller.saveSelected();
    if (!saved || !context.mounted) return;

    await LaunchStore.current.markIntroCompleted();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const HomeShell()),
      (Route<dynamic> route) => false,
    );
  }

  /// Testin verdiği bant onaylanınca sunucuda imzaya dönüşür; katalog o
  /// zaman yeniden okunur ve imza ilgili kartı önseçer. Böylece ekrandaki
  /// seçim her zaman sunucunun dediği banttır.
  Future<void> _openLevelTest(
    BuildContext context,
    LevelCubit controller,
  ) async {
    final bool? saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext _) => LevelTestScreen(
          onCompleted: () => Navigator.of(context).pop(true),
          onChooseManually: () => Navigator.of(context).pop(false),
        ),
      ),
    );
    if (saved == true) {
      await controller.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LevelCubit>(
      create: (_) => _cubitFromLocator(),
      child: BlocBuilder<LevelCubit, LevelState>(
        builder: (BuildContext context, LevelState state) {
          final LevelCubit controller = context.read<LevelCubit>();
          return Scaffold(
            backgroundColor: AppColors.canvas,
            body: SafeArea(
              child: switch (state) {
                LevelError(:final message) => AppErrorView(
                  message: message,
                  onRetry: controller.load,
                ),
                LevelReady() => _content(context, controller, state),
              },
            ),
          );
        },
      ),
    );
  }

  Widget _content(
    BuildContext context,
    LevelCubit controller,
    LevelReady ready,
  ) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      LevelContent.title,
                      style: AppTypography.headingMd.copyWith(
                        color: AppColors.inkDisplay,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      LevelContent.subtitle,
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.bodyMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ..._grid(controller, ready),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          ready.selectedLevelId == null || ready.isSaving
                          ? null
                          : () => _confirm(context, controller),
                      child: Text(LevelContent.chooseLabel),
                    ),
                  ),
                  if (ready.saveMessage != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      ready.saveMessage!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.accentCardinal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: ready.isSaving
                          ? null
                          : () => _openLevelTest(context, controller),
                      child: Text(LevelContent.testLabel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Izgara her satırda iki kart: katalog sunucudan geldiği için satır
  /// sayısı sabit değildir; tek kalan kart yarım genişlikte durur.
  List<Widget> _grid(LevelCubit controller, LevelReady ready) {
    final List<AppLevel> levels = ready.levels;
    return <Widget>[
      for (int row = 0; row * 2 < levels.length; row++)
        Padding(
          padding: EdgeInsets.only(
            bottom: (row + 1) * 2 < levels.length ? AppSpacing.base : 0,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _card(controller, ready, levels[row * 2], row * 2),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: row * 2 + 1 < levels.length
                    ? _card(controller, ready, levels[row * 2 + 1], row * 2 + 1)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
    ];
  }

  Widget _card(
    LevelCubit controller,
    LevelReady ready,
    AppLevel level,
    int position,
  ) => LevelSelectCard(
    level: level,
    position: position,
    selected: level.id == ready.selectedLevelId,
    entrance: _entrance,
    onSelected: () {
      HapticFeedback.selectionClick();
      controller.select(level.id);
    },
  );

  /// Veri katmanı kayıtlıysa (üretim) gerçek cubit; değilse yerleşik
  /// katalogla çizilen ekran — widget testleri ekranı tek başına render
  /// eder.
  LevelCubit _cubitFromLocator() {
    final LevelRepository? repository = slIfRegistered<LevelRepository>();
    return repository == null
        ? LevelCubit()
        : LevelCubit(repository: repository)..load();
  }
}
