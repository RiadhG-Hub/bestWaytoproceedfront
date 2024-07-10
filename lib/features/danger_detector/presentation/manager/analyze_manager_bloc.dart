import 'dart:developer';

import 'package:bestwaytoproceed/bestwaytoproceed.dart';
import 'package:bestwaytoproceed/models/way_data.dart';
import 'package:bestwaytoproceedanalyze/bestwaytoproceedanalyze.dart';
import 'package:bestwaytoproceedanalyze/core/danger_class.dart';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:meta/meta.dart';
import 'package:vibration/vibration.dart';

part 'analyze_manager_event.dart';
part 'analyze_manager_state.dart';

/// The BLoC class responsible for managing the analysis process.
class AnalyzeManagerBloc extends Bloc<AnalyzeManagerEvent, AnalyzeManagerState> {
  /// API key for the generative AI model.
  static const apiKey = "AIzaSyA2sQyyq3cYUqakisqqzkrTENm7GWu8w7g";

  /// Instance of [ImageComparison] to handle image analysis.
  ImageComparison comparator = ImageComparison(apiKey);

  /// List of available camera descriptions.
  static List<CameraDescription> cameras = [];

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
          CameraController controller = CameraController(cameras[0], ResolutionPreset.max);
          await controller.initialize();

          log('Taking picture...');
          final XFile imageResult = await controller.takePicture();
          log("Picture taken successfully");

          log('Sending image to AI for analysis...');
          final result = await comparator.compareImages(image: imageResult);
          log('AI analysis result: $result');

          // Check for vibration control
          final bool? hasAmplitudeControl = await Vibration.hasAmplitudeControl();
          final int vibrationDuration = (100 - (result!.safetyPercentage ?? 0).toInt()).toInt();

          if (hasAmplitudeControl != null && hasAmplitudeControl) {
            log("Vibrating with amplitude control...");
            Vibration.vibrate(
                amplitude: vibrationDuration,
                duration: vibrationDuration,
                pattern: [500, 1000, 500, 2000],
                intensities: [1, 255]);
          } else {
            log("Vibrating without amplitude control...");
            Vibration.vibrate(duration: vibrationDuration, pattern: [500, 1000, 500, 2000], intensities: [1, 255]);
          }

          // Perform further analysis and save data if needed
          final BestWayAnalyze bestWayAnalyze = BestWayAnalyze(result);
          final analyzeResult = await bestWayAnalyze.analyze(saveData: true);

          // Dispose of the camera controller
          await controller.dispose();

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
