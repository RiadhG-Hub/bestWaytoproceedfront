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

class AnalyzeManagerBloc extends Bloc<AnalyzeManagerEvent, AnalyzeManagerState> {
  static const apiKey = "AIzaSyA2sQyyq3cYUqakisqqzkrTENm7GWu8w7g";
  ImageComparison comparator = ImageComparison(apiKey);
  static List<CameraDescription> cameras = [];
  AnalyzeManagerBloc() : super(AnalyzeManagerInitial()) {
    on<AnalyzeManagerEvent>((event, emit) async {
      if (event is TakePictureStartAnalyze) {
        try {
          emit(TakePictureStartAnalyzeLoading());
          if (cameras.isEmpty) {
            cameras = await availableCameras();
          }
          CameraController controller = CameraController(cameras[0], ResolutionPreset.max);
          await controller.initialize();
          log('timer cycle start');
          log('controller is not equal to null');
          log('take a picture and wait for the result');
          final XFile imageResult = await controller.takePicture();
          log("image result done");
          log('waiting for the ai response');
          final result = await comparator.compareImages(images: imageResult);
          log('the ai result is: $result');
          final bool? hasAmplitudeControl = await Vibration.hasAmplitudeControl();
          if (hasAmplitudeControl != null && hasAmplitudeControl) {
            log("here");
            Vibration.vibrate(
                amplitude: (100 - (result!.safetyPercentage ?? 0).toInt()).toInt(),
                duration: (100 - (result.safetyPercentage ?? 0).toInt()).toInt(),
                pattern: [500, 1000, 500, 2000],
                intensities: [1, 255]);
          } else {
            Vibration.vibrate(
                duration: (100 - (result!.safetyPercentage ?? 0).toInt()).toInt(),
                pattern: [500, 1000, 500, 2000],
                intensities: [1, 255]);
          }
          final BestWayAnalyze bestWayAnalyze = BestWayAnalyze(result);
          final analyzeResult = await bestWayAnalyze.analyze(saveData: true);
          controller.dispose();

          emit(TakePictureStartAnalyzeSuccess(analyzeResult, result));
        } catch (e, s) {
          emit(TakePictureStartAnalyzeFailed('error : $e, stack: $s'));
        }
      }
    });
  }
}
