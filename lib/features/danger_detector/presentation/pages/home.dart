import 'package:bestwaytoproceedfront/features/danger_detector/presentation/manager/analyze_manager_bloc.dart';
import 'package:bestwaytoproceedfront/features/danger_detector/presentation/widgets/danger_view.dart';
import 'package:bestwaytoproceedfront/features/danger_detector/presentation/widgets/init_view.dart';
import 'package:bestwaytoproceedfront/features/danger_detector/presentation/widgets/loading_view.dart';
import 'package:bestwaytoproceedfront/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shake/shake.dart';
import 'package:volume_key_board/volume_key_board.dart';

import '../widgets/error_view.dart';

/// A [StatefulWidget] that represents the home screen of the application.
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ManagerService _managerService = ManagerService();
  late final ShakeDetector _shakeDetector;
  late final AnalyzeManagerBloc _analyzeManagerBloc = AnalyzeManagerBloc(
    flutterTts: _managerService.flutterTts,
    apiKey: _managerService.apiKey,
  );

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  /// Initializes the shake detector and sets up volume key listener.
  void _initialize() {
    _managerService.flutterTts.speak(
        "Press volume up to take and analyze a picture. Press volume down to detect objects in the taken picture.");
    _setupVolumeKeyListener();
    _setupShakeListener();
  }

  /// Sets up the shake detector to start analyzing when the phone is shaken.
  void _setupShakeListener() {
    _shakeDetector = ShakeDetector.autoStart(
        onPhoneShake: () {
          if (_analyzeManagerBloc.state is! TakePictureStartAnalyzeLoading) {
            _analyzeManagerBloc.add(TakePictureStartAnalyze());
          }
        },
        minimumShakeCount: 5,
        shakeThresholdGravity: 1.3);
  }

  /// Sets up the volume key listener to trigger actions based on volume key presses.
  void _setupVolumeKeyListener() {
    VolumeKeyBoard.instance.addListener((VolumeKey event) {
      if (_analyzeManagerBloc.state is! TakePictureStartAnalyzeLoading) {
        if (event == VolumeKey.up) {
          _analyzeManagerBloc.add(TakePictureStartAnalyze());
        } else if (event == VolumeKey.down) {
          _analyzeManagerBloc.add(ExtractObject());
        }
      }
    });
  }

  @override
  void dispose() {
    _analyzeManagerBloc.close();
    _shakeDetector.stopListening();
    VolumeKeyBoard.instance.removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<AnalyzeManagerBloc, AnalyzeManagerState>(
            bloc: _analyzeManagerBloc,
            buildWhen: (oldState, newState) => oldState != newState,
            builder: (context, state) {
              return _buildContent(state);
            },
          ),
        ],
      ),
    );
  }

  /// Builds the UI content based on the current state of [AnalyzeManagerBloc].
  Widget _buildContent(AnalyzeManagerState state) {
    if (state is TakePictureStartAnalyzeLoading) {
      return const LoadingView();
    } else if (state is TakePictureStartAnalyzeFailed) {
      return ErrorView(
        errorMessage: state.message,
        onRetry: () {
          _analyzeManagerBloc.add(TakePictureStartAnalyze());
        },
      );
    } else if (state is TakePictureStartAnalyzeSuccess) {
      return DangerView(state.dangerClass, state.wayData);
    } else {
      return const InitView();
    }
  }
}
