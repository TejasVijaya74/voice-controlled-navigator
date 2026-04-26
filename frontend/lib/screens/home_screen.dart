import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/vision_service.dart';
import '../services/navigation_service.dart';

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  HomeScreen({required this.cameras});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController _controller;
  final VisionService _vision = VisionService();
  final NavigationService _nav = NavigationService();

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) return;
      _vision.startDetectionLoop(_controller); // Start YOLO detection
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SafeStride AI")),
      body: Column(
        children: [
          if (_controller.value.isInitialized)
            AspectRatio(aspectRatio: 1, child: CameraPreview(_controller)),
          ElevatedButton(
            onPressed: () { /* Add Voice Input Logic here */ },
            child: Text("Speak Destination"),
          ),
        ],
      ),
    );
  }
}
import 'package:speech_to_text/speech_to_text.dart' as stt; // Add this import
import 'package:geolocator/geolocator.dart'; // Add this import

// Inside _HomeScreenState class, add these variables:
final stt.SpeechToText _speech = stt.SpeechToText();
bool _isListening = false;

// Add this function inside _HomeScreenState:
void _listen() async {
  if (!_isListening) {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (val) async {
        if (val.finalResult) {
          setState(() => _isListening = false);
          String destination = val.recognizedWords;
          
          // 1. Get Current GPS
          Position pos = await Geolocator.getCurrentPosition();
          
          // 2. Geocode & Get Route
          var destCoords = await _vision.api.geocode(destination);
          var routeData = await _vision.api.getRoute(
            pos.latitude, pos.longitude, 
            destCoords['lat'], destCoords['lng']
          );

          // 3. Start Navigation
          _nav.updateRoute(routeData['steps']);
          // Start a listener for the GPS loop
          Geolocator.getPositionStream().listen((pos) => _nav.checkLocation(pos));
        }
      });
    }
  } else {
    setState(() => _isListening = false);
    _speech.stop();
  }
}

// Update your ElevatedButton in the build method:
ElevatedButton(
  onPressed: _listen,
  style: ElevatedButton.styleFrom(backgroundColor: _isListening ? Colors.red : Colors.blue),
  child: Text(_isListening ? "Listening..." : "Speak Destination"),
),
