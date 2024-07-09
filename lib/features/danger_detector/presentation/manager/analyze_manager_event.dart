part of 'analyze_manager_bloc.dart';

@immutable
sealed class AnalyzeManagerEvent {}

class TakePictureStartAnalyze extends AnalyzeManagerEvent {}
