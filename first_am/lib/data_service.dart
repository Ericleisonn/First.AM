import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "dart:convert";

Future<Map> serviceCountry(String country) async {
  final url =
      'http://ws.audioscrobbler.com/2.0/?method=geo.gettoptracks&country=$country&api_key=f62a2d2d3a59bc0a79c85e8f04e18b8b&format=json&limit=10';

  dynamic response;
  await http.get(Uri.parse(url))
    .then((value) => response = value);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
    // p
  } else {
    return {"statusCode": response.statusCode};
  }
}

Future<Map> serviceArtists(String country) async {
  final url =
      'http://ws.audioscrobbler.com/2.0/?method=geo.gettopartists&country=$country&api_key=f62a2d2d3a59bc0a79c85e8f04e18b8b&format=json&limit=10';

  dynamic response;
  await http.get(Uri.parse(url))
    .then((value) => response = value);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return {"statusCode": response.statusCode};
  }
}

class DataService {
  final ValueNotifier<Map> stateNotifier = ValueNotifier({});

  void carregar() async {
    var tracks = [];
    var artists = [];

    await serviceCountry("brazil").then((res) => {
      tracks = res["tracks"]["track"]
    });

    await serviceArtists("brazil").then((res) => {
      artists = res["topartists"]["artist"]
    });

    stateNotifier.value = {"tracks": tracks, "artists": artists};
  }
}
