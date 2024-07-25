import 'package:bestwaytoproceedfront/features/danger_detector/data/settings_repository.dart';
import 'package:bloc/bloc.dart';

import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository;

  SettingsBloc(this.settingsRepository)
      : super(SettingsState(
          minimumShakeCount: 5,
          shakeThresholdGravity: 1.3,
          shakeCountResetTime: 3000,
          isShakeDetectorActive: true,
          isSaveAnalyzeResultActive: true,
          isFetchLocationActive: true,
        )) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateShakeDetectorActive>(_onUpdateShakeDetectorActive);
    // Add other update handlers similarly for the remaining settings.
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    final minimumShakeCount = await settingsRepository.getMinimumShakeCount();
    final shakeThresholdGravity = await settingsRepository.getShakeThresholdGravity();
    final shakeCountResetTime = await settingsRepository.getShakeCountResetTime();
    final isShakeDetectorActive = await settingsRepository.getIsShakeDetectorActive();
    final isSaveAnalyzeResultActive = await settingsRepository.getIsSaveAnalyzeResultActive();
    final isFetchLocationActive = await settingsRepository.getIsFetchLocationActive();

    emit(SettingsState(
      minimumShakeCount: minimumShakeCount,
      shakeThresholdGravity: shakeThresholdGravity,
      shakeCountResetTime: shakeCountResetTime,
      isShakeDetectorActive: isShakeDetectorActive,
      isSaveAnalyzeResultActive: isSaveAnalyzeResultActive,
      isFetchLocationActive: isFetchLocationActive,
    ));
  }

  void _onUpdateShakeDetectorActive(UpdateShakeDetectorActive event, Emitter<SettingsState> emit) {
    settingsRepository.setIsShakeDetectorActive(event.isActive);
    emit(state.copyWith(isShakeDetectorActive: event.isActive));
  }

// Add other update methods similarly for the remaining settings.
}
