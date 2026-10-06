import 'dart:convert';
import 'dart:io';

void main() async {
  final apiKey = const String.fromEnvironment('API_KEY');
  final url = Uri.parse('https://places.googleapis.com/v1/places:searchText?key=$apiKey');
  final headers = {
    'Content-Type': 'application/json',
    'X-Goog-FieldMask': 'places.id,places.displayName,places.formattedAddress,places.location,places.photos,places.types'
  };
  
  final payload = {
    "textQuery": "Varshini boys hostel",
    "locationBias": {
      "circle": {
        "center": {
          "latitude": 17.000, // Roughly Rajamahendravaram
          "longitude": 81.766
        },
        "radius": 3000.0
      }
    }
  };

  final request = await HttpClient().postUrl(url);
  headers.forEach((k, v) => request.headers.add(k, v));
  request.write(json.encode(payload));
  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  
  print('Status: ${response.statusCode}');
  print('Response: $responseBody');
}
