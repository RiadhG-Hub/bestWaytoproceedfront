import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final int minimumShakeCount;
  final double shakeThresholdGravity;
  final int shakeCountResetTime;
  final bool isShakeDetectorActive;
  final bool isSaveAnalyzeResultActive;
  final bool isFetchLocationActive;

  const SettingsState({
    required this.minimumShakeCount,
    required this.shakeThresholdGravity,
    required this.shakeCountResetTime,
    required this.isShakeDetectorActive,
    required this.isSaveAnalyzeResultActive,
    required this.isFetchLocationActive,
  });

  @override
  List<Object> get props => [
        minimumShakeCount,
        shakeThresholdGravity,
        shakeCountResetTime,
        isShakeDetectorActive,
        isSaveAnalyzeResultActive,
        isFetchLocationActive,
      ];

  SettingsState copyWith({
    int? minimumShakeCount,
    double? shakeThresholdGravity,
    int? shakeCountResetTime,
    bool? isShakeDetectorActive,
    bool? isSaveAnalyzeResultActive,
    bool? isFetchLocationActive,
  }) {
    return SettingsState(
      minimumShakeCount: minimumShakeCount ?? this.minimumShakeCount,
      shakeThresholdGravity: shakeThresholdGravity ?? this.shakeThresholdGravity,
      shakeCountResetTime: shakeCountResetTime ?? this.shakeCountResetTime,
      isShakeDetectorActive: isShakeDetectorActive ?? this.isShakeDetectorActive,
      isSaveAnalyzeResultActive: isSaveAnalyzeResultActive ?? this.isSaveAnalyzeResultActive,
      isFetchLocationActive: isFetchLocationActive ?? this.isFetchLocationActive,
    );
  }
}
