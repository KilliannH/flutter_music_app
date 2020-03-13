import 'dart:convert';
import 'dart:io';

import 'package:flutter_music_app/services/cacheService.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_music_app/models/song.dart';

class DataService {

  static Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/config.json');
  }

  static Future<List<Song>> getSongs() async {
      var value = await loadAsset();

      var config = jsonDecode(value);
      var client = http.Client();

      String apiUrl = '${config['api_host']}:${config['api_port']}${config['api_endpoint']}';
      String apiKey = config['api_key'];

      var response = await client.get(Uri.parse(apiUrl + '/songs'),
          headers: {
            HttpHeaders.authorizationHeader: apiKey
          });

      var songsJson = jsonDecode(response.body) as List;

      List<Song> songList = songsJson.map((songJson) => Song.fromJson(songJson)).toList();

      CacheService.songList = songList;
      return songList;
  }

}