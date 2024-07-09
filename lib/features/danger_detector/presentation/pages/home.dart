import 'package:bestwaytoproceedfront/features/danger_detector/presentation/manager/analyze_manager_bloc.dart';
import 'package:bestwaytoproceedfront/features/danger_detector/presentation/widgets/danger_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          MaterialButton(
            onPressed: () {
              context.read<AnalyzeManagerBloc>().add(TakePictureStartAnalyze());
            },
            child: const Text('analyze image'),
          )
        ],
      ),
      body: Center(
        child: BlocBuilder<AnalyzeManagerBloc, AnalyzeManagerState>(builder: (context, state) {
          if (state is TakePictureStartAnalyzeLoading) {
            return const Text('Loading');
          }
          if (state is TakePictureStartAnalyzeFailed) {
            return Text(state.message);
          }
          if (state is TakePictureStartAnalyzeSuccess) {
            return DangerView(state.dangerClass, state.wayData);
          }
          return Text(state.toString());
        }, buildWhen: (
          oldState,
          newState,
        ) {
          return oldState != newState;
        }),
      ),
    );
  }
}
