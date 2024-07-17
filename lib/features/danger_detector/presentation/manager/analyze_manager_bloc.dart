import 'dart:developer' as developer;

import 'package:bestwaytoproceed/bestwaytoproceed.dart';
import 'package:bestwaytoproceed/models/way_data.dart';
import 'package:bestwaytoproceedanalyze/bestwaytoproceedanalyze.dart';
import 'package:bestwaytoproceedanalyze/core/danger_class.dart';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:meta/meta.dart';
import 'package:vibration/vibration.dart';

part 'analyze_manager_event.dart';
part 'analyze_manager_state.dart';

class AnalyzeManagerBloc extends Bloc<AnalyzeManagerEvent, AnalyzeManagerState> {
  final FlutterTts flutterTts;
  final String apiKey;
  late final ImageComparison comparator;
  List<CameraDescription> cameras = [];
  CameraController? controller;

  AnalyzeManagerBloc({required this.flutterTts, required this.apiKey}) : super(AnalyzeManagerInitial()) {
    on<AnalyzeManagerEvent>((event, emit) async {
      if (event is TakePictureStartAnalyze) {
        await _handleTakePictureStartAnalyze(emit);
      }
    });
  }

  Future<void> _handleTakePictureStartAnalyze(Emitter<AnalyzeManagerState> emit) async {
    try {
      emit(TakePictureStartAnalyzeLoading());
      await _initializeCameraIfNeeded();
      final XFile imageResult = await _takePicture();

      final WayData? result = await _analyzeImage(imageResult);
      assert(result != null, 'result should not be null');
      await _vibrateBasedOnResult(result!);
      await _speakAnalysisResult(result);
      await _disposeCameraControllerIfNeeded();

      emit(TakePictureStartAnalyzeSuccess((result.safetyPercentage ?? 0).dangerClass, result));
    } catch (e, s) {
      await _disposeCameraControllerIfNeeded();
      emit(TakePictureStartAnalyzeFailed('Error: $e, Stacktrace: $s'));
    }
  }

  Future<void> _initializeCameraIfNeeded() async {
    if (cameras.isEmpty) {
      cameras = await availableCameras();
    }
    if (controller == null) {
      controller = CameraController(cameras[0], ResolutionPreset.low);
      await controller!.initialize();
    }
  }

  // Group camera related methods
  Future<XFile> _takePicture() async {
    developer.log('Taking picture...');
    final XFile imageResult = await controller!.takePicture();
    developer.log("Picture taken successfully");
    return imageResult;
  }

  Future<void> _disposeCameraControllerIfNeeded() async {
    if (controller != null) {
      await controller!.dispose();
      controller = null;
    }
  }

  // Group analysis related methods
  Future<WayData?> _analyzeImage(XFile imageResult) async {
    developer.log('Sending image to AI for analysis...');
    final WayData? result = await comparator.analyzeImage(imageResult);
    developer.log('AI analysis result: $result');
    return result;
  }

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
  int _calculateVibrationDuration(int safetyPercentage) {
    return 400 - (safetyPercentage * 4);
  }

  Future<void> _speak({required List<String> texts}) async {
    for (var text in texts) {
      await flutterTts.speak(text);
    }
  }

  Future<void> _speakAnalysisResult(WayData result) async {
    final BestWayAnalyze bestWayAnalyze = BestWayAnalyze(result);
    final analyzeResult = await bestWayAnalyze.analyze();
    await _speak(
        texts: [analyzeResult.name, analyzeResult.name + (result.proceedPhrase ?? "") + (result.roadType ?? "")]);
  }
}
