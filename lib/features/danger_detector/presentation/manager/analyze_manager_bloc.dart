import 'dart:developer' as developer;

import 'package:bestwaytoproceed/bestwaytoproceed.dart';
import 'package:bestwaytoproceed/models/way_data.dart';
import 'package:bestwaytoproceedanalyze/bestwaytoproceedanalyze.dart';
import 'package:bestwaytoproceedanalyze/core/danger_class.dart';
import 'package:bestwaytoproceedfront/features/danger_detector/data/locator_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';
import 'package:vibration/vibration.dart';

part 'analyze_manager_event.dart';
part 'analyze_manager_state.dart';

/// Bloc for managing analysis tasks such as taking pictures, analyzing images, and handling detected objects.
///
/// This Bloc utilizes various packages to interact with the camera, perform image analysis, provide
/// text-to-speech feedback, and handle vibration alerts based on the analysis results.
class AnalyzeManagerBloc
    extends Bloc<AnalyzeManagerEvent, AnalyzeManagerState> {
  final FlutterTts flutterTts; // Text-to-speech instance
  final String apiKey; // API key for image comparison
  late final ImageComparison comparator; // Image comparison instance
  List<CameraDescription> cameras = []; // List of available cameras
  CameraController? controller; // Controller for the camera

  WayData? _latestAnalyzeResult; // Latest analysis result

  /// Constructor for initializing the Bloc with required dependencies.
  AnalyzeManagerBloc({required this.flutterTts, required this.apiKey})
      : super(AnalyzeManagerInitial()) {
    comparator = ImageComparison(apiKey);
    on<AnalyzeManagerEvent>((event, emit) async {
      if (event is TakePictureStartAnalyze) {
        await _handleTakePictureStartAnalyze(
            emit,
            event.isSaveAnalyzeResultActive,
            event.isFetchLocationActive,
            event.isQuickResultActive);
      }
      if (event is ExtractObject) {
        await _handleExtractObject(emit);
      }

      if (event is AlternativeRoute) {
        await _handleAlternativeRoute(emit);
      }
    });
  }

  /// Handles the extraction of objects from the latest analysis result and provides feedback to the user.
  ///
  /// This method emits different states based on the presence of objects in the latest analysis result and
  /// handles potential errors. It also uses text-to-speech to communicate results or errors to the user.
  ///
  /// [emit] The function used to emit states to the [AnalyzeManagerState].
  Future<void> _handleExtractObject(Emitter<AnalyzeManagerState> emit) async {
    try {
      // Check if there is a result available from the latest analysis
      if (_latestAnalyzeResult != null) {
        emit(ExtractObjectLoading());
        if (_latestAnalyzeResult!.details != null) {
          await _speak(texts: [_latestAnalyzeResult!.details!]);
          emit(ExtractObjectSuccess());
          return;
        }

        // Check if any objects were detected
        if ((_latestAnalyzeResult!.objects ?? []).isEmpty) {
          await _speak(texts: ["No objects detected"]);
          emit(ExtractObjectSuccess());
          return;
        }

        // Join detected objects with "and" for a readable announcement
        final detectedObjects =
            (_latestAnalyzeResult!.objects ?? []).toSet().join(" and ");

        // Announce the detected objects
        await _speak(texts: ["The objects detected are $detectedObjects"]);
        emit(ExtractObjectSuccess());
        return;
      } else {
        // Prompt the user to take a picture first if no result is available
        await _speak(
            texts: ["You should take a picture first to activate this option"]);
        emit(ExtractObjectFailed("No analysis result available"));
        return;
      }
    } catch (error) {
      // Handle any errors that occur during the process
      await _speak(
          texts: ['Sorry, an internal error occurred. Please try again.']);
      emit(ExtractObjectFailed('Error: $error'));
      return;
    }
  }

  Future<void> _handleAlternativeRoute(
      Emitter<AnalyzeManagerState> emit) async {
    try {
      // Check if there is a result available from the latest analysis
      if (_latestAnalyzeResult != null) {
        emit(ExtractObjectLoading());

        await _speak(texts: [_latestAnalyzeResult!.alternativeRoute!]);
        emit(ExtractObjectSuccess());
        return;
      } else {
        // Prompt the user to take a picture first if no result is available
        await _speak(
            texts: ["You should take a picture first to activate this option"]);
        emit(ExtractObjectFailed("No analysis result available"));
        return;
      }
    } catch (error) {
      // Handle any errors that occur during the process
      await _speak(
          texts: ['Sorry, an internal error occurred. Please try again.']);
      emit(ExtractObjectFailed('Error: $error'));
      return;
    }
  }

  /// Handles the process of taking a picture and starting the analysis.
  ///
  /// This method initializes the camera if needed, takes a picture, sends the image for analysis,
  /// and provides feedback based on the analysis result.
  ///
  /// [emit] The function used to emit states to the [AnalyzeManagerState].
  Future<void> _handleTakePictureStartAnalyze(Emitter<AnalyzeManagerState> emit,
      bool saveResult, bool captLocation, bool? quickAnalyse) async {
    try {
      Position? positionResult;
      emit(TakePictureStartAnalyzeLoading());
      await _initializeCameraIfNeeded();
      final XFile imageResult = await _takePicture();
      _speak(texts: ['analyse in progress']);
      if (captLocation) {
        positionResult = await LocatorRepository.determinePosition();
      }
      final WayData? result =
          await _analyzeImage(imageResult, positionResult, quickAnalyse);
      assert(result != null, 'result should not be null');
      await _vibrateBasedOnResult(result!);
      await _speakAnalysisResult(result, saveResult);
      await _disposeCameraControllerIfNeeded();
      _latestAnalyzeResult = result;
      emit(TakePictureStartAnalyzeSuccess(
          (result.safetyPercentage ?? 0).dangerClass, result));
      return;
    } catch (e) {
      await _disposeCameraControllerIfNeeded();
      _speak(texts: ['Sorry, an internal error occurred. Please try again.']);
      emit(TakePictureStartAnalyzeFailed('Error: $e'));
    }
  }

  /// Initializes the camera if it hasn't been initialized already.
  Future<void> _initializeCameraIfNeeded() async {
    if (cameras.isEmpty) {
      cameras = await availableCameras();
    }
    if (controller == null) {
      controller = CameraController(
        cameras[0],
        ResolutionPreset.low,
      );
      await controller!.initialize();
    }
  }

  /// Takes a picture using the camera controller.
  ///
  /// Logs the process and returns the taken picture as an [XFile].
  Future<XFile> _takePicture() async {
    developer.log('Taking picture...');
    final XFile imageResult = await controller!.takePicture();
    developer.log("Picture taken successfully");
    return imageResult;
  }

  /// Disposes the camera controller if it is initialized.
  Future<void> _disposeCameraControllerIfNeeded() async {
    if (controller != null) {
      await controller!.dispose();
      controller = null;
    }
  }

  /// Analyzes the given image using the comparator.
  ///
  /// Sends the image to the AI for analysis and returns the result.
  ///
  /// [imageResult] The image to be analyzed.
  Future<WayData?> _analyzeImage(
      XFile imageResult, Position? position, bool? quickAnalyse) async {
    developer.log('Sending image to AI for analysis...');
    final WayData? result = await comparator.analyzeImage(
        image: imageResult,
        position:
            "latitude:${position?.latitude} longitude:${position?.longitude}",
        quickAnalyse: quickAnalyse);
    developer.log('AI analysis result: $result');
    return result;
  }

  /// Vibrates the device based on the analysis result.
  ///
  /// The vibration pattern and duration are determined by the safety percentage.
  ///
  /// [result] The analysis result containing the safety percentage.
  Future<void> _vibrateBasedOnResult(WayData result) async {
    final int safetyPercentage = result.safetyPercentage?.toInt() ?? 0;
    final int vibrationDuration = _calculateVibrationDuration(safetyPercentage);

    const List<int> vibrationPattern = [500, 1000, 500, 2000];
    const List<int> vibrationIntensities = [1, 255];

    Vibration.vibrate(
      duration: vibrationDuration,
      pattern: vibrationPattern,
      intensities: vibrationIntensities,
    );
  }

  /// Calculates the vibration duration based on the safety percentage.
  ///
  /// [safetyPercentage] The safety percentage of the analysis result.
  int _calculateVibrationDuration(int safetyPercentage) {
    return 400 - (safetyPercentage * 4);
  }

  /// Speaks the provided texts using text-to-speech.
  ///
  /// [texts] The list of texts to be spoken.
  Future<void> _speak({required List<String> texts}) async {
    for (var text in texts) {
      await flutterTts.speak(text);
    }
  }

  /// Speaks the analysis result using text-to-speech.
  ///
  /// [result] The analysis result to be spoken.
  Future<void> _speakAnalysisResult(WayData result, bool saveData) async {
    final BestWayAnalyze bestWayAnalyze = BestWayAnalyze(
      result,
    );
    final analyzeResult = await bestWayAnalyze.analyze(saveData: saveData);
    await _speak(texts: [
      "${analyzeResult.name} you are in ${(result.roadType ?? "unknown road")} ${result.proceedPhrase ?? ""}"
    ]);
  }
}
