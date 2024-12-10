import 'package:flutter/material.dart';

class WaterController with ChangeNotifier {
  int waterCounter = 0;
  final int waterGoal = 3500;

  void addWater() {
    waterCounter += 250;
    if (waterCounter > waterGoal) {
      waterCounter = waterGoal;
    }
    notifyListeners();
  }

  void removeWater() {
    waterCounter -= 250;
    if (waterCounter < 0) {
      waterCounter = 0;
    }
    notifyListeners();
  }

  void resetDailyWater() {
    waterCounter = 0;
    notifyListeners();
  }
}
