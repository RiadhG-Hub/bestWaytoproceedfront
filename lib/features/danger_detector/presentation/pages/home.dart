import 'dart:async';

import 'package:bestwaytoproceedfront/features/danger_detector/data/settings_repository.dart';
import 'package:bestwaytoproceedfront/features/danger_detector/presentation/manager/analyze_manager_bloc.dart';
import 'package:bestwaytoproceedfront/features/danger_detector/presentation/widgets/danger_view.dart';
import 'package:bestwaytoproceedfront/features/danger_detector/presentation/widgets/error_view.dart';
import 'package:bestwaytoproceedfront/features/danger_detector/presentation/widgets/init_view.dart';
import 'package:bestwaytoproceedfront/features/danger_detector/presentation/widgets/loading_view.dart';
import 'package:bestwaytoproceedfront/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shake/shake.dart';
import 'package:volume_key_board/volume_key_board.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ManagerService _managerService = ManagerService();
  late ShakeDetector _shakeDetector;
  late final AnalyzeManagerBloc _analyzeManagerBloc = AnalyzeManagerBloc(
    flutterTts: _managerService.flutterTts,
    apiKey: _managerService.apiKey,
  );

  final SettingsRepository _settingsRepository = SettingsRepository();

  int _minimumShakeCount = 5;
  double _shakeThresholdGravity = 1.3;
  int _shakeCountResetTime = 3000;
  bool _isShakeDetectorActive = true;
  bool _isSaveAnalyzeResultActive = true;
  bool _isFetchLocationActive = true;
  bool _isQuickResultActive = false;

  int _volumeDownPressCount = 0;
  Timer? _volumeDownPressTimer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initialize();
  }

  Future<void> _loadSettings() async {
    _minimumShakeCount = await _settingsRepository.getMinimumShakeCount();
    _shakeThresholdGravity =
        await _settingsRepository.getShakeThresholdGravity();
    _shakeCountResetTime = await _settingsRepository.getShakeCountResetTime();
    _isShakeDetectorActive =
        await _settingsRepository.getIsShakeDetectorActive();
    _isSaveAnalyzeResultActive =
        await _settingsRepository.getIsSaveAnalyzeResultActive();
    _isFetchLocationActive =
        await _settingsRepository.getIsFetchLocationActive();
    _isQuickResultActive = await _settingsRepository.getIsQuickResultActive();
    setState(() {});
    _setupShakeListener();
  }

  void _initialize() {
    _managerService.flutterTts.speak(
        "Press volume up to take and analyze a picture. Press volume down to detect objects in the taken picture. Press volume down twice quickly to describe alternative way.");
    _setupVolumeKeyListener();
  }

  void _setupShakeListener() {
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: () {
        if (_analyzeManagerBloc.state is! TakePictureStartAnalyzeLoading) {
          _analyzeManagerBloc.add(TakePictureStartAnalyze(
              _isSaveAnalyzeResultActive,
              _isFetchLocationActive,
              _isQuickResultActive));
        }
      },
      minimumShakeCount: _minimumShakeCount,
      shakeThresholdGravity: _shakeThresholdGravity,
      shakeCountResetTime: _shakeCountResetTime,
    );
    if (!_isShakeDetectorActive) {
      _shakeDetector.stopListening();
    }
  }

  void _setupVolumeKeyListener() {
    VolumeKeyBoard.instance.addListener((VolumeKey event) {
      if (_analyzeManagerBloc.state is! TakePictureStartAnalyzeLoading) {
        if (event == VolumeKey.up) {
          _analyzeManagerBloc.add(TakePictureStartAnalyze(
              _isSaveAnalyzeResultActive,
              _isFetchLocationActive,
              _isQuickResultActive));
        } else if (event == VolumeKey.down) {
          _volumeDownPressCount++;

          if (_volumeDownPressCount == 1) {
            _volumeDownPressTimer =
                Timer(const Duration(milliseconds: 500), () {
              if (_volumeDownPressCount == 1) {
                _analyzeManagerBloc.add(ExtractObject());
              }
              _volumeDownPressCount = 0;
            });
          } else if (_volumeDownPressCount == 2) {
            _volumeDownPressTimer?.cancel();
            _analyzeManagerBloc.add(AlternativeRoute());
            _volumeDownPressCount = 0;
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _analyzeManagerBloc.close();
    _shakeDetector.stopListening();
    VolumeKeyBoard.instance.removeListener();
    _volumeDownPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      drawer: _buildDrawer(),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<AnalyzeManagerBloc, AnalyzeManagerState>(
            bloc: _analyzeManagerBloc,
            buildWhen: (oldState, newState) => oldState != newState,
            builder: (context, state) {
              return _buildContent(state);
            },
          ),
          MaterialButton(
            onPressed: () {
              _analyzeManagerBloc.add(TakePictureStartAnalyze(
                  _isSaveAnalyzeResultActive,
                  _isFetchLocationActive,
                  _isQuickResultActive));
            },
            child: const Text("click"),
          )
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text(
              'Enable Walk Detector',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            value: _isShakeDetectorActive,
            onChanged: (bool value) {
              setState(() {
                _isShakeDetectorActive = value;
                if (_isShakeDetectorActive) {
                  _shakeDetector.startListening();
                } else {
                  _shakeDetector.stopListening();
                }
                _settingsRepository.setIsShakeDetectorActive(value);
              });
            },
          ),
          ListTile(
            title: const Text('Minimum Shake Count'),
            trailing: DropdownButton<int>(
              value: _minimumShakeCount,
              items: (_isShakeDetectorActive
                      ? [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                      : <int>[])
                  .map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  _minimumShakeCount = newValue!;
                  _shakeDetector.stopListening();
                  _setupShakeListener();
                  _settingsRepository.setMinimumShakeCount(newValue);
                });
              },
            ),
          ),
          ListTile(
            title: const Text(
              'Shake Threshold Gravity',
            ),
            trailing: DropdownButton<double>(
              value: _shakeThresholdGravity,
              items: (_isShakeDetectorActive
                      ? [1.0, 1.1, 1.2, 1.3, 1.4, 1.5]
                      : <double>[])
                  .map((double value) {
                return DropdownMenuItem<double>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (double? newValue) {
                setState(() {
                  _shakeThresholdGravity = newValue!;
                  _shakeDetector.stopListening();
                  _setupShakeListener();
                  _settingsRepository.setShakeThresholdGravity(newValue);
                });
              },
            ),
          ),
          ListTile(
            title: const Text(
              'Shake Count ResetTime',
            ),
            trailing: DropdownButton<int>(
              value: _shakeCountResetTime,
              items: (_isShakeDetectorActive
                      ? [
                          1000,
                          2000,
                          3000,
                          4000,
                          5000,
                          6000,
                        ]
                      : <int>[])
                  .map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text("${value}ms"),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  _shakeCountResetTime = newValue!;
                  _shakeDetector.stopListening();
                  _setupShakeListener();
                  _settingsRepository.setShakeCountResetTime(newValue);
                });
              },
            ),
          ),
          SwitchListTile(
            title: const Text(
              'Store Analyze Result',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            subtitle: const Text(
                "Activating store analyze result might increase the time needed to complete image analysis."),
            value: _isSaveAnalyzeResultActive,
            onChanged: (bool value) {
              setState(() {
                _isSaveAnalyzeResultActive = value;
                _settingsRepository.setIsSaveAnalyzeResultActive(value);
              });
            },
          ),
          SwitchListTile(
            title: const Text(
              'Fetch location',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            subtitle: const Text(
                "Activating Fetch location might increase the time needed to complete image analysis."),
            value: _isFetchLocationActive,
            onChanged: (bool value) {
              setState(() {
                _isFetchLocationActive = value;
                _settingsRepository.setIsFetchLocationActive(value);
              });
            },
          ),
          SwitchListTile(
            title: const Text(
              'Quick Analysis Result ',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            subtitle: const Text("quick analysis result can affect accuracy  "),
            value: _isQuickResultActive,
            onChanged: (bool value) {
              setState(() {
                _isQuickResultActive = value;
                _settingsRepository.setIsQuickResultActive(value);
              });
            },
          ),
          ListTile(
            trailing: const Icon(Icons.restart_alt),
            title: const Text(
              'Reset Application Params',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _minimumShakeCount = 5;
                _shakeThresholdGravity = 1.3;
                _shakeCountResetTime = 3000;
                _isShakeDetectorActive = true;
                _isSaveAnalyzeResultActive = true;
                _isFetchLocationActive = true;
                _settingsRepository.setMinimumShakeCount(_minimumShakeCount);
                _settingsRepository
                    .setShakeThresholdGravity(_shakeThresholdGravity);
                _settingsRepository
                    .setShakeCountResetTime(_shakeCountResetTime);
                _settingsRepository
                    .setIsShakeDetectorActive(_isShakeDetectorActive);
                _settingsRepository
                    .setIsSaveAnalyzeResultActive(_isSaveAnalyzeResultActive);
                _settingsRepository
                    .setIsFetchLocationActive(_isFetchLocationActive);
                _setupShakeListener();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AnalyzeManagerState state) {
    if (state is TakePictureStartAnalyzeLoading) {
      return const LoadingView();
    } else if (state is TakePictureStartAnalyzeFailed) {
      return ErrorView(
        errorMessage: state.message,
        onRetry: () {
          _analyzeManagerBloc.add(TakePictureStartAnalyze(
              _isSaveAnalyzeResultActive,
              _isFetchLocationActive,
              _isQuickResultActive));
        },
      );
    } else if (state is TakePictureStartAnalyzeSuccess) {
      return DangerView(state.dangerClass, state.wayData);
    } else {
      return const InitView();
    }
  }
}
