part of 'analyze_manager_bloc.dart';

/// Base class for all states related to the [AnalyzeManagerBloc].
///
/// This class is marked as sealed to prevent external extensions.
@immutable
sealed class AnalyzeManagerState {}

/// State indicating the initial state of the [AnalyzeManagerBloc].
final class AnalyzeManagerInitial extends AnalyzeManagerState {}

/// State indicating that the process of taking a picture and analyzing it is loading.
class TakePictureStartAnalyzeLoading extends AnalyzeManagerState {}

/// State indicating that the picture has been successfully taken and analyzed.
///
/// Contains the [dangerClass] and [wayData] resulting from the analysis.
class TakePictureStartAnalyzeSuccess extends AnalyzeManagerState {
  /// The danger classification result from the analysis.
  final DangerClass dangerClass;

  /// The analyzed data of the way.
  final WayData wayData;

  /// Constructs an instance of [TakePictureStartAnalyzeSuccess] with the provided [dangerClass] and [wayData].
  TakePictureStartAnalyzeSuccess(this.dangerClass, this.wayData);
}

/// State indicating that the process of taking a picture and analyzing it has failed.
///
/// Contains the [message] describing the error.
class TakePictureStartAnalyzeFailed extends AnalyzeManagerState {
  /// The error message.
  final String message;

  /// Constructs an instance of [TakePictureStartAnalyzeFailed] with the provided [message].
  TakePictureStartAnalyzeFailed(this.message);
}
