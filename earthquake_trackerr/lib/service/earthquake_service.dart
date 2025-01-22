import 'dart:convert';
import 'package:http/http.dart' as http;

// Sending user data to the server and returning the response body
Future<String> sendUserData(double latitude, double longitude, String timeRange,
    String fcmToken) async {
  // final url = Uri.parse('http://192.168.100.7:5000/api/earthquakes/location');
final url = Uri.parse(
      'https://earthquake-tracker-backend.vercel.app/api/earthquakes/location');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'latitude': latitude,
      'longitude': longitude,
      'timeRange': timeRange,
      'fcmToken': fcmToken,
    }),
  );

  if (response.statusCode == 200) {
    print('Data sent successfully!');
    return response.body; 
  } else {
    print('Failed to send data. Error: ${response.body}');
    return ''; 
  }
}
