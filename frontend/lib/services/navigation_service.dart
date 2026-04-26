import 'package:geolocator/geolocator.dart';
import 'package:flutter_tts/flutter_tts.dart';

class NavigationService {
  final FlutterTts tts = FlutterTts();
  List steps = [];
  int currentStepIndex = 0;

  void updateRoute(List newSteps) {
    steps = newSteps;
    currentStepIndex = 0;
  }

  void checkLocation(Position pos) {
    if (steps.isEmpty || currentStepIndex >= steps.length) return;

    var step = steps[currentStepIndex];
    double distance = Geolocator.distanceBetween(
      pos.latitude, pos.longitude, step['end_lat'], step['end_lng']
    );

    if (distance < 15) { // Within 15 meters of turn
      tts.speak(step['instruction']);
      currentStepIndex++;
    }
  }
}
