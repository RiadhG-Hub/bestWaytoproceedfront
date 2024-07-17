import 'dart:async';

import 'package:bestwaytoproceedfront/features/danger_detector/presentation/manager/analyze_manager_bloc.dart';
import 'package:bestwaytoproceedfront/features/danger_detector/presentation/pages/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'firebase_options.dart';

Future<void> main() async {
  const String _geminiApiKey = "geminiApiKey";
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform(),
  );

  //_cameras = await availableCameras();
  ManagerService.apiKey = dotenv.get(_geminiApiKey);
  runApp(BlocProvider(
    create: (context) => ManagerService.analyzeManagerBloc,
    child: const MaterialApp(home: Home()),
  ));
}

class ManagerService {
  static String? _apiKey;
  static final FlutterTts _flutterTts = FlutterTts();
  static String get apiKey {
    assert(_apiKey != null, "api key not defined");
    return _apiKey!;
  }

  static set apiKey(String value) {
    _apiKey = value;
  }

  static final AnalyzeManagerBloc analyzeManagerBloc = AnalyzeManagerBloc(
    flutterTts: _flutterTts,
    apiKey: apiKey,
  );

  static ManagerService? _instance;

  factory ManagerService() {
    _instance ??= ManagerService._internalConstructor();
    return _instance!;
  }

  ManagerService._internalConstructor();
}
