import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateShakeDetectorActive extends SettingsEvent {
  final bool isActive;

  const UpdateShakeDetectorActive(this.isActive);

  @override
  List<Object> get props => [isActive];
}

// Add other update events similarly for the remaining settings.
