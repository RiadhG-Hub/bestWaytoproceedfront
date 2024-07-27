import 'dart:async';

import 'package:bestwaytoproceedfront/features/danger_detector/presentation/manager/analyze_manager_bloc.dart';
import 'package:bestwaytoproceedfront/features/danger_detector/presentation/pages/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
//import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shake/shake.dart';

import 'firebase_options.dart';

/// The entry point of the application.
Future<void> main() async {
  // Ensure Flutter binding is initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from the .env file.
  await dotenv.load(fileName: ".env");

  // Initialize Firebase.
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform());

  // Initialize the ManagerService singleton.
  final ManagerService managerService = ManagerService();

  // Start the application with a BlocProvider for the AnalyzeManagerBloc.
  // await SentryFlutter.init((options) {
  //   options.dsn = managerService.sentryDns;
  //   // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
  //   // We recommend adjusting this value in production.
  //   options.tracesSampleRate = 1.0;
  //   // The sampling rate for profiling is relative to tracesSampleRate
  //   // Setting to 1.0 will profile 100% of sampled transactions:
  //   // Note: Profiling alpha is available for iOS and macOS since SDK version 7.12.0
  //   options.profilesSampleRate = 1.0;
  // },
  //appRunner: () =>
  runApp(BlocProvider(
    create: (context) => AnalyzeManagerBloc(
      flutterTts: managerService.flutterTts,
      apiKey: managerService.apiKey,
    ),
    child: const MaterialApp(home: Home()),
  ));

  //));
}

/// A singleton service manager for handling TTS and API key.
class ManagerService {
  final FlutterTts flutterTts;
  final String apiKey;
  final String sentryDns;
  late final ShakeDetector detector;
  // The single instance of ManagerService.
  static final ManagerService _instance = ManagerService._internal();

  /// Factory constructor to return the same instance of ManagerService.
  factory ManagerService() {
    return _instance;
  }

  /// Internal constructor to initialize [flutterTts] and [apiKey].
  ManagerService._internal()
      : flutterTts = FlutterTts()..awaitSpeakCompletion(true),
        apiKey = dotenv.get('GEMINI_API_KEY'),
        sentryDns = dotenv.get("SENTRY_DNS"),
        detector = ShakeDetector.waitForStart(onPhoneShake: () {
          // Do stuff on phone shake
        }) {
    assert(apiKey.isNotEmpty, 'Missing GEMINI_API_KEY in .env');
  }
}
