import "package:http/http.dart" as http;
import "dart:convert";

Future<Map> serviceCountry(String country) async {
  final url =
      'http://ws.audioscrobbler.com/2.0/?method=geo.gettoptracks&country=$country&api_key=f62a2d2d3a59bc0a79c85e8f04e18b8b&format=json&limit=10';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
    // p
  }else{
    return {"statusCode": response.statusCode};
  }
}
