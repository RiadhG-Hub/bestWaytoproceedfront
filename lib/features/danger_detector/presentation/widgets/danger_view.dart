import 'package:bestwaytoproceed/models/way_data.dart';
import 'package:bestwaytoproceedanalyze/core/danger_class.dart';
import 'package:flutter/material.dart';

class DangerView extends StatelessWidget {
  final DangerClass dangerClass;
  final WayData wayData;

  const DangerView(this.dangerClass, this.wayData, {super.key});

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
            Text(dangerClass.name),
            Text(wayData.safetyPercentage.toString()),
            Text(wayData.proceedPhrase.toString()),
            Text(wayData.roadType.toString()),
          ],
        ),
      ),
    );
  }
}
