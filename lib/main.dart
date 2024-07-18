import 'dart:async';

import 'package:bestwaytoproceedfront/features/danger_detector/presentation/manager/analyze_manager_bloc.dart';
import 'package:bestwaytoproceedfront/features/danger_detector/presentation/pages/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'firebase_options.dart';

/// The entry point of the application.
Future<void> main() async {
  // Ensure Flutter binding is initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from the .env file.
  await dotenv.load(fileName: ".env");

  // Initialize Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform());

  // Initialize the ManagerService singleton.
  final ManagerService managerService = ManagerService();

  // Start the application with a BlocProvider for the AnalyzeManagerBloc.
  runApp(BlocProvider(
    create: (context) => AnalyzeManagerBloc(
      flutterTts: managerService.flutterTts,
      apiKey: managerService.apiKey,
    ),
    child: const MaterialApp(home: Home()),
  ));
}

/// A singleton service manager for handling TTS and API key.
class ManagerService {
  final FlutterTts flutterTts;
  final String apiKey;

  // The single instance of ManagerService.
  static final ManagerService _instance = ManagerService._internal();

  /// Factory constructor to return the same instance of ManagerService.
  factory ManagerService() {
    return _instance;
  }

  /// Internal constructor to initialize [flutterTts] and [apiKey].
  ManagerService._internal()
      : flutterTts = FlutterTts(),
        apiKey = dotenv.get('GEMINI_API_KEY') {
    assert(apiKey.isNotEmpty, 'Missing GEMINI_API_KEY in .env');
  }
}
