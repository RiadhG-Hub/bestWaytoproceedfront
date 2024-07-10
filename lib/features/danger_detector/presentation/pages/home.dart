import 'package:bestwaytoproceedfront/features/danger_detector/presentation/manager/analyze_manager_bloc.dart';
import 'package:bestwaytoproceedfront/features/danger_detector/presentation/widgets/danger_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A [StatelessWidget] that represents the home screen of the application.
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          MaterialButton(
            onPressed: () {
              // Dispatches an event to start the image analysis process.
              context.read<AnalyzeManagerBloc>().add(TakePictureStartAnalyze());
            },
            child: const Text('Analyze Image'),
          )
        ],
      ),
      body: Center(
        child: BlocBuilder<AnalyzeManagerBloc, AnalyzeManagerState>(
          builder: (context, state) {
            if (state is TakePictureStartAnalyzeLoading) {
              // Displays a loading message while the image is being analyzed.
              return const Text('Loading...');
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
            return Text('State: ${state.toString()}');
          },
          buildWhen: (oldState, newState) {
            // Rebuilds the widget only when the state changes.
            return oldState != newState;
          },
        ),
      ),
    );
  }
}
