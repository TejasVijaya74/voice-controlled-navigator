import 'package:camera/camera.dart';
import 'api_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VisionService {
  final ApiService api = ApiService();
  final FlutterTts tts = FlutterTts();
  bool isProcessing = false;

  void startDetectionLoop(CameraController controller) {
    // Take a picture every 2 seconds to avoid overloading the server
    Stream.periodic(Duration(seconds: 2)).listen((_) async {
      if (isProcessing || !controller.value.isInitialized) return;

      isProcessing = true;
      try {
        XFile file = await controller.takePicture();
        final bytes = await file.readAsBytes();
        final detections = await api.detectObstacles(bytes);

        for (var det in detections) {
          // If proximity is "very close", interrupt and warn!
          if (det['proximity'] == "very close") {
            tts.stop();
            tts.speak("Warning: ${det['alert_text']}");
          }
        }
      } catch (e) {
        print("Vision Error: $e");
      }
      isProcessing = false;
    });
  }
}
