import 'package:bestwaytoproceed/models/way_data.dart';
import 'package:bestwaytoproceedanalyze/core/danger_class.dart';
import 'package:flutter/material.dart';

/// A widget that displays the danger level and related data.
///
/// The background color of the widget changes based on the danger level.
class DangerView extends StatelessWidget {
  /// The danger classification.
  final DangerClass dangerClass;

  /// The data related to the way being analyzed.
  final WayData wayData;

  /// Constructs a [DangerView] widget with the given [dangerClass] and [wayData].
  const DangerView(this.dangerClass, this.wayData, {super.key});

  /// Returns a color corresponding to the given [dangerClass].
  ///
  /// The color represents the severity of the danger, ranging from green (very safe)
  /// to red (extremely hazardous).
  Color getColorForDangerClass(DangerClass dangerClass) {
    switch (dangerClass) {
      case DangerClass.verySafe:
        return Colors.green.shade900;
      case DangerClass.safe:
        return Colors.green.shade700;
      case DangerClass.generallySafe:
        return Colors.green.shade500;
      case DangerClass.moderatelySafe:
        return Colors.green.shade300;
      case DangerClass.somewhatSafe:
        return Colors.yellow.shade300;
      case DangerClass.moderatelyUnsafe:
        return Colors.yellow.shade500;
      case DangerClass.unsafe:
        return Colors.orange.shade500;
      case DangerClass.veryUnsafe:
        return Colors.orange.shade700;
      case DangerClass.extremelyUnsafe:
        return Colors.red.shade700;
      case DangerClass.extremelyHazardous:
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Container(
      color: getColorForDangerClass(dangerClass),
      height: screenSize.height / 1.6,
      width: screenSize.width,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(dangerClass.name, style: Theme.of(context).textTheme.displayLarge),
            Text('Safety Percentage: ${wayData.safetyPercentage}', style: Theme.of(context).textTheme.displayMedium),
            Text('Proceed Phrase: ${wayData.proceedPhrase}', style: Theme.of(context).textTheme.displayMedium),
            Text('Road Type: ${wayData.roadType}', style: Theme.of(context).textTheme.displayMedium),
          ],
        ),
      ),
    );
  }
}
