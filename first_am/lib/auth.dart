import 'dart:convert';
import 'package:xml2json/xml2json.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

Future<Map> fetchAccessToken(String username, String senha) async {
  var data = {
    'username': username,
    'password': senha,
    'api_key': 'f62a2d2d3a59bc0a79c85e8f04e18b8b',
    'api_sig': '91b168fb5038ce65ea18c81122eb465f',
  };

  var apiSig = 'api_key${data['api_key']}methodauth.getMobileSessionpassword${data['password']}username${data['username']}${data['api_sig']}';

  // var url = Uri.parse('https://accounts.spotify.com/api/token');
  var sigmd5 = md5.convert(utf8.encode(apiSig)).toString();
  var url = 'https://ws.audioscrobbler.com/2.0/?method=auth.getMobileSession&username=${data['username']}&password=${data['password']}&api_key=f62a2d2d3a59bc0a79c85e8f04e18b8b&api_sig=${sigmd5}';

  var res = await http.post(Uri.parse(url));

  if (res.statusCode != 200) {
    throw Exception('http.post error: statusCode= ${res.statusCode}');
  } else {
    final converter = Xml2Json();
    var response = res.body;
    converter.parse(response);
    var jsonString = converter.toParker();
    return jsonDecode(jsonString);
  }
}