import 'package:bestwaytoproceedfront/features/danger_detector/presentation/manager/analyze_manager_bloc.dart';
import 'package:bestwaytoproceedfront/features/danger_detector/presentation/widgets/danger_view.dart';
import 'package:bestwaytoproceedfront/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late final AnalyzeManagerBloc _analyzeManagerBloc = AnalyzeManagerBloc(
    flutterTts: _managerService.flutterTts,
    apiKey: _managerService.apiKey,
  );

  @override
  void initState() {
    super.initState();

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

    return Scaffold(
      appBar: AppBar(),
      //backgroundColor: Colors.transparent,
      body: BlocBuilder<AnalyzeManagerBloc, AnalyzeManagerState>(
        bloc: _analyzeManagerBloc,
        buildWhen: (oldState, newState) => oldState != newState,
        builder: (context, state) {
          return _buildContent(state);
        },
      ),
    );
  }

  Widget _buildContent(AnalyzeManagerState state) {
    if (state is TakePictureStartAnalyzeLoading) {
      return const CircularProgressIndicator();
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
      return const Text('init');
    }
  }

// Existing helper methods for building UI elements are preserved
}
