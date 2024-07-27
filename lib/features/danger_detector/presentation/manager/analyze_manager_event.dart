part of 'analyze_manager_bloc.dart';

/// Base class for all events related to the [AnalyzeManagerBloc].
///
/// This class is marked as sealed to prevent external extensions.
@immutable
sealed class AnalyzeManagerEvent {}

/// Event to start the process of taking a picture and analyzing it.
///
/// This event triggers the sequence of actions to capture an image,
/// send it for analysis, and process the result.
class TakePictureStartAnalyze extends AnalyzeManagerEvent {
  final bool isSaveAnalyzeResultActive;
  final bool isFetchLocationActive;
  final bool isQuickResultActive;

  TakePictureStartAnalyze(this.isSaveAnalyzeResultActive,
      this.isFetchLocationActive, this.isQuickResultActive);
}

class ExtractObject extends AnalyzeManagerEvent {}

class AlternativeRoute extends AnalyzeManagerEvent {}
