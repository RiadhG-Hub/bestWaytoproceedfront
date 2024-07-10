import 'dart:developer';

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

/// The BLoC class responsible for managing the analysis process.
class AnalyzeManagerBloc extends Bloc<AnalyzeManagerEvent, AnalyzeManagerState> {
  FlutterTts flutterTts = FlutterTts();

  /// API key for the generative AI model.
  static const apiKey = "AIzaSyA2sQyyq3cYUqakisqqzkrTENm7GWu8w7g";

  /// Instance of [ImageComparison] to handle image analysis.
  ImageComparison comparator = ImageComparison(apiKey);

  /// List of available camera descriptions.
  static List<CameraDescription> cameras = [];
  static CameraController? controller;
  Future<void> _speak({required List<String> texts}) async {
    for (var text in texts) {
      await flutterTts.speak(text);
    }
  }

  /// Constructs an instance of [AnalyzeManagerBloc].
  AnalyzeManagerBloc() : super(AnalyzeManagerInitial()) {
    on<AnalyzeManagerEvent>((event, emit) async {
      if (event is TakePictureStartAnalyze) {
        try {
          emit(TakePictureStartAnalyzeLoading());

          // Initialize cameras if not already initialized
          if (cameras.isEmpty) {
            cameras = await availableCameras();
          }

          // Initialize the camera controller
          controller = CameraController(cameras[0], ResolutionPreset.low);
          await controller!.initialize();

          log('Taking picture...');
          final XFile imageResult = await controller!.takePicture();
          log("Picture taken successfully");

          log('Sending image to AI for analysis...');
          final result = await comparator.compareImages(image: imageResult);
          log('AI analysis result: $result');

          final int vibrationDuration = (100 - (result!.safetyPercentage ?? 0).toInt()).toInt();

          Vibration.vibrate(duration: vibrationDuration, pattern: [500, 1000, 500, 2000], intensities: [1, 255]);

          // Perform further analysis and save data if needed
          final BestWayAnalyze bestWayAnalyze = BestWayAnalyze(result);
          final analyzeResult = await bestWayAnalyze.analyze();
          _speak(texts: [analyzeResult.name, analyzeResult.name, result.proceedPhrase ?? "", result.roadType ?? ""]);
          // Dispose of the camera controller
          await controller!.dispose();

          // Emit success state with the analysis result
          emit(TakePictureStartAnalyzeSuccess(analyzeResult, result));
        } catch (e, s) {
          // Emit failure state with error details
          emit(TakePictureStartAnalyzeFailed('Error: $e, Stack: $s'));
        }
      }
    });
  }
}
