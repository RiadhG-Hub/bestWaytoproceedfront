part of 'analyze_manager_bloc.dart';

@immutable
sealed class AnalyzeManagerState {}

final class AnalyzeManagerInitial extends AnalyzeManagerState {}

class TakePictureStartAnalyzeLoading extends AnalyzeManagerState {}

class TakePictureStartAnalyzeSuccess extends AnalyzeManagerState {
  final DangerClass dangerClass;
  final WayData wayData;

  TakePictureStartAnalyzeSuccess(this.dangerClass, this.wayData);
}

class TakePictureStartAnalyzeFailed extends AnalyzeManagerState {
  final String message;

  TakePictureStartAnalyzeFailed(this.message);
}
