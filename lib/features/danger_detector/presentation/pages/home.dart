import 'package:bestwaytoproceed/bestwaytoproceed.dart';
import 'package:bestwaytoproceedfront/features/danger_detector/presentation/manager/analyze_manager_bloc.dart';
import 'package:bestwaytoproceedfront/features/danger_detector/presentation/widgets/danger_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:volume_key_board/volume_key_board.dart';

/// A [StatefulWidget] that represents the home screen of the application.
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FlutterTts _flutterTts = FlutterTts();
  final ImageComparison _imageComparison = ImageComparison('');
  late final AnalyzeManagerBloc _analyzeManagerBloc;

  @override
  void initState() {
    super.initState();
    _analyzeManagerBloc = AnalyzeManagerBloc(flutterTts: _flutterTts, apiKey: "");
    _setupVolumeKeyListener();
  }

  @override
  void dispose() {
    _analyzeManagerBloc.close();
    VolumeKeyBoard.instance.removeListener();
    super.dispose();
  }

  void _setupVolumeKeyListener() {
    VolumeKeyBoard.instance.addListener((VolumeKey event) {
      if (event == VolumeKey.up || event == VolumeKey.down) {
        _analyzeManagerBloc.add(TakePictureStartAnalyze());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        _buildBackgroundImage(screenSize),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: BlocBuilder<AnalyzeManagerBloc, AnalyzeManagerState>(
              bloc: _analyzeManagerBloc,
              buildWhen: (oldState, newState) => oldState != newState,
              builder: (context, state) {
                return _buildContent(state);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(AnalyzeManagerState state) {
    if (state is TakePictureStartAnalyzeLoading) {
      return const CircularProgressIndicator();
    } else if (state is TakePictureStartAnalyzeFailed) {
      return _buildErrorMessage(state.message);
    } else if (state is TakePictureStartAnalyzeSuccess) {
      return DangerView(state.dangerClass, state.wayData);
    } else {
      return _buildInitialView();
    }
  }

// Existing helper methods for building UI elements are preserved
}
