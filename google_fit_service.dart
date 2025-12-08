import 'package:flutter/services.dart';
import 'package:google_fit/google_fit.dart';

class GoogleFitService {
  static final GoogleFitService _instance = GoogleFitService._internal();
  factory GoogleFitService() => _instance;
  GoogleFitService._internal();
  
  final GoogleFit _googleFit = GoogleFit();
  bool _isAuthorized = false;
  
  Future<bool> authorize() async {
    try {
      _isAuthorized = await _googleFit.authorize();
      return _isAuthorized;
    } on PlatformException catch (e) {
      print('Authorization failed: ${e.message}');
      return false;
    }
  }
  
  Future<int> getTodaySteps() async {
    if (!_isAuthorized) {
      await authorize();
    }
    
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final steps = await _googleFit.getSteps(
        today,
        now,
      );
      
      return steps.fold(0, (sum, step) => sum + (step.value ?? 0));
    } catch (e) {
      print('Error getting steps: $e');
      return 0;
    }
  }
  
  Future<double> getCaloriesBurned() async {
    // Calculate based on steps and user weight
    final steps = await getTodaySteps();
    // Simplified formula: steps * 0.04 calories
    return steps * 0.04;
  }
}