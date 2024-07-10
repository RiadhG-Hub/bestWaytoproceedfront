import 'package:bestwaytoproceedfront/features/danger_detector/presentation/manager/analyze_manager_bloc.dart';
import 'package:bestwaytoproceedfront/features/danger_detector/presentation/widgets/danger_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:volume_key_board/volume_key_board.dart';

/// A [StatelessWidget] that represents the home screen of the application.
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    VolumeKeyBoard.instance.addListener((VolumeKey event) {
      if (event == VolumeKey.up) {
        context.read<AnalyzeManagerBloc>().add(TakePictureStartAnalyze());
      } else if (event == VolumeKey.down) {
        context.read<AnalyzeManagerBloc>().add(TakePictureStartAnalyze());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    final cameraController = AnalyzeManagerBloc.controller;
    if (cameraController != null) {
      cameraController.dispose();
    }
    VolumeKeyBoard.instance.removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        Image.asset(
          'assets/sidewalk.png',
          height: screenSize.height,
          width: screenSize.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: BlocBuilder<AnalyzeManagerBloc, AnalyzeManagerState>(
              builder: (context, state) {
                if (state is TakePictureStartAnalyzeLoading) {
                  // Displays a loading message while the image is being analyzed.
                  return LoadingAnimationWidget.threeRotatingDots(
                    color: Colors.white,
                    size: 200,
                  );
                }
                if (state is TakePictureStartAnalyzeFailed) {
                  // Displays an error message if the analysis fails.
                  return Text('Error: ${state.message}');
                }
                if (state is TakePictureStartAnalyzeSuccess) {
                  // Displays the danger view with the analysis results.
                  return DangerView(state.dangerClass, state.wayData);
                }
                // Displays the current state if it doesn't match any specific case.
                return LoadingAnimationWidget.beat(
                  color: Colors.white,
                  size: 200,
                );
              },
              buildWhen: (oldState, newState) {
                // Rebuilds the widget only when the state changes.
                return oldState != newState;
              },
            ),
          ),
        ),
      ],
    );
  }
}
