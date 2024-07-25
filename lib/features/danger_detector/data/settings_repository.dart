import 'package:shared_preferences/shared_preferences.dart';

/// A repository class to handle the storage and retrieval of app settings using SharedPreferences.
class SettingsRepository {
  /// Retrieves the minimum shake count from SharedPreferences.
  /// Returns 5 if not found.
  Future<int> getMinimumShakeCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('minimumShakeCount') ?? 5;
  }

  /// Saves the minimum shake count to SharedPreferences.
  ///
  /// [value] is the minimum shake count to be saved.
  Future<void> setMinimumShakeCount(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('minimumShakeCount', value);
  }

  /// Retrieves the shake threshold gravity from SharedPreferences.
  /// Returns 1.3 if not found.
  Future<double> getShakeThresholdGravity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('shakeThresholdGravity') ?? 1.3;
  }

  /// Saves the shake threshold gravity to SharedPreferences.
  ///
  /// [value] is the shake threshold gravity to be saved.
  Future<void> setShakeThresholdGravity(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('shakeThresholdGravity', value);
  }

  /// Retrieves the shake count reset time from SharedPreferences.
  /// Returns 3000 milliseconds if not found.
  Future<int> getShakeCountResetTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('shakeCountResetTime') ?? 3000;
  }

  /// Saves the shake count reset time to SharedPreferences.
  ///
  /// [value] is the shake count reset time in milliseconds to be saved.
  Future<void> setShakeCountResetTime(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('shakeCountResetTime', value);
  }

  /// Retrieves the status of the shake detector activation from SharedPreferences.
  /// Returns true if not found.
  Future<bool> getIsShakeDetectorActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isShakeDetectorActive') ?? true;
  }

  /// Saves the status of the shake detector activation to SharedPreferences.
  ///
  /// [value] is the boolean value indicating if the shake detector is active.
  Future<void> setIsShakeDetectorActive(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isShakeDetectorActive', value);
  }

  /// Retrieves the status of the analyze result saving from SharedPreferences.
  /// Returns true if not found.
  Future<bool> getIsSaveAnalyzeResultActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isSaveAnalyzeResultActive') ?? true;
  }

  /// Saves the status of the analyze result saving to SharedPreferences.
  ///
  /// [value] is the boolean value indicating if the analyze result saving is active.
  Future<void> setIsSaveAnalyzeResultActive(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSaveAnalyzeResultActive', value);
  }

  Future<bool> getIsFetchLocationActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('IsFetchLocationActive') ?? true;
  }

  /// Saves the status of the analyze result saving to SharedPreferences.
  ///
  /// [value] is the boolean value indicating if the analyze result saving is active.
  Future<void> setIsFetchLocationActive(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('IsFetchLocationActive', value);
  }
}
