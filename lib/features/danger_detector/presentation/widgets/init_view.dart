import 'package:flutter/material.dart';

class InitView extends StatelessWidget {
  const InitView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt,
            size: 100,
            color: Colors.green,
          ),
          SizedBox(height: 20),
          Text(
            'Application Ready',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Press volume up to take and analyze a picture.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Press volume down to detect objects in the taken picture.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
