import 'package:bestwaytoproceed/models/way_data.dart';
import 'package:bestwaytoproceedanalyze/core/danger_class.dart';
import 'package:flutter/material.dart';

/// A widget that displays the danger level and related data with a sonar-like design.
///
/// The background color of the widget changes based on the danger level.
class DangerView extends StatefulWidget {
  /// The danger classification.
  final DangerClass dangerClass;

  /// The data related to the way being analyzed.
  final WayData wayData;

  /// Constructs a [DangerView] widget with the given [dangerClass] and [wayData].
  const DangerView(this.dangerClass, this.wayData, {super.key});

  @override
  DangerViewState createState() => DangerViewState();
}

class DangerViewState extends State<DangerView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.security,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Safety Percentage',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${widget.wayData.safetyPercentage}%',
              style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: getColorForDangerClass(widget.dangerClass)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Proceed Phrase',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            if (widget.wayData.proceedPhrase != null)
              Text(
                widget.wayData.proceedPhrase!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.black54,
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Road Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            if (widget.wayData.roadType != null)
              Text(
                widget.wayData.roadType!,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.black54,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
