import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl = dotenv.env['BACKEND_URL'] ?? "http://127.0.0.1:8000";


  // 1. Navigation Route
  Future<Map<String, dynamic>> getRoute(double startLat, double startLng, double endLat, double endLng) async {
    final response = await http.post(
      Uri.parse("$baseUrl/navigation/route"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "from_lat": startLat,
        "from_lng": startLng,
        "to_lat": endLat,
        "to_lng": endLng,
      }),
    );
    return jsonDecode(response.body);
  }

  // 2. YOLO Detection (Sends Image Bytes)
  Future<List<dynamic>> detectObstacles(Uint8List imageBytes) async {
    var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/detect"));
    request.files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: 'frame.jpg'));
    
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    var data = jsonDecode(response.body);
    return data['results'] ?? [];
  }
}
// ADD THIS INSIDE YOUR ApiService CLASS
Future<Map<String, dynamic>> geocode(String query) async {
  final response = await http.get(
    Uri.parse("$baseUrl/navigation/geocode?q=$query"),
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  throw Exception("Failed to geocode destination");
}
