import 'dart:async';
import 'dart:developer';

import 'package:bestwaytoproceed/bestwaytoproceed.dart';
import 'package:bestwaytoproceedfront/features/danger_detector/presentation/manager/analyze_manager_bloc.dart';
import 'package:bestwaytoproceedfront/features/danger_detector/presentation/pages/home.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibration/vibration.dart';

import 'firebase_options.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //_cameras = await availableCameras();
  runApp(BlocProvider(
    create: (context) => AnalyzeManagerBloc(),
    child: const MaterialApp(home: Home()),
  ));
}

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  late ImageComparison _comparator;
  static const int takePictureEach = 15;
  Timer? timer;

  Future<void> startTimer() async {
    try {
      controller = CameraController(_cameras[0], ResolutionPreset.max);
      await controller.initialize();
      // timer ??= Timer.periodic(const Duration(seconds: takePictureEach), (timer) async {
      log('timer cycle start');
      log('controller is not equal to null');
      log('take a picture and wait for the result');
      final XFile imageResult = await controller.takePicture();
      log("image result done");
      log('waiting for the ai response');
      final result = await _comparator.compareImages(images: imageResult);
      log('the ai result is: $result');
      final bool? hasAmplitudeControl = await Vibration.hasAmplitudeControl();
      if (hasAmplitudeControl != null && hasAmplitudeControl) {
        log("here");
        Vibration.vibrate(
            amplitude: (100 - (result!.safetyPercentage ?? 0).toInt()).toInt(),
            duration: (100 - (result!.safetyPercentage ?? 0).toInt()).toInt(),
            pattern: [500, 1000, 500, 2000],
            intensities: [1, 255]);
      } else {
        Vibration.vibrate(
            duration: (100 - (result!.safetyPercentage ?? 0).toInt()).toInt(),
            pattern: [500, 1000, 500, 2000],
            intensities: [1, 255]);
      }
      controller.dispose();

      assert(result != null, 'the result should be different to null');
      //  });
    } catch (e, s) {
      log('error: $e, stack: $s');
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    const apiKey = "AIzaSyA2sQyyq3cYUqakisqqzkrTENm7GWu8w7g";
    _comparator = ImageComparison(apiKey);

    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }

      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        actions: [
          MaterialButton(
            onPressed: () {
              // if (timer!.isActive) {
              //   timer!.cancel();
              // } else {
              startTimer();
              // }
            },
            child: const Text('ok'),
          )
        ],
      ),
      body: (!controller.value.isInitialized)
          ? const Center(
              child: Text('Loading'),
            )
          : const Center(
              child: Text('Capturing now'),
            ),
    ));
  }
}
