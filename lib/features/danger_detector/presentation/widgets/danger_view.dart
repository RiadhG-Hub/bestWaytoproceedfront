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
  _DangerViewState createState() => _DangerViewState();
}

class _DangerViewState extends State<DangerView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      getColorForDangerClass(widget.dangerClass).withOpacity(0.3),
                      getColorForDangerClass(widget.dangerClass),
                    ],
                    stops: [0.7, 1.0],
                  ),
                ),
                height: 200,
                width: 200,
                child: Center(
                  child: RotationTransition(
                    turns: _controller,
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2.0,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 10,
                            child: Icon(
                              Icons.arrow_upward,
                              color: Colors.white.withOpacity(0.7),
                              size: 24,
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            child: Icon(
                              Icons.arrow_downward,
                              color: Colors.white.withOpacity(0.7),
                              size: 24,
                            ),
                          ),
                          Positioned(
                            left: 10,
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white.withOpacity(0.7),
                              size: 24,
                            ),
                          ),
                          Positioned(
                            right: 10,
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white.withOpacity(0.7),
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    widget.dangerClass.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(seconds: 2),
            child: Text(
              'Safety Percentage: ${widget.wayData.safetyPercentage}%',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(seconds: 2),
            child: Text(
              'Proceed Phrase: ${widget.wayData.proceedPhrase}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(seconds: 2),
            child: Text(
              'Road Type: ${widget.wayData.roadType}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
