import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dart:convert';
import '../models/song.dart';

class PlayerSchedule with ChangeNotifier {
  Song _selectedSong;

  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioPlayerState _playerState;

  Song get selectedSong => _selectedSong;
  AudioPlayerState get playerState => _playerState;
  AudioPlayer get audioPlayer => _audioPlayer;

  void setSelectedSong(newSong) {
    this._selectedSong = newSong;
    _loadPlayer(_selectedSong);
    notifyListeners();
  }

  Future<int> _loadPlayer(Song song) async {
    _audioPlayer.onPlayerStateChanged.listen((AudioPlayerState s) {
      print('Current player state: $s');
      _playerState = s;
    });
    final url = await prepareUrl(song.filename);

    int result = await audioPlayer.play(url);
    if (result == 1) {
      print('play success');
      return 1;
      // success
    } else {
      return 0;
    }
  }

  Future<String> prepareUrl(String filename) async {
    var value = await rootBundle.loadString('assets/config.json');

    final config = jsonDecode(value);

    return '${config['api_host']}:${config['api_port']}${config['api_endpoint']}' + '/stream/' + filename;
  }

  Future<int> pause() async {
    int result = await audioPlayer.pause();
    if(result == 1) {
      print('pause success');
      return 1;
    } else {
      return 0;
    }
  }

  Future<int> resume() async {
    int result = await audioPlayer.resume();
    if(result == 1) {
      print('resume success');
      return 1;
    } else {
      print('error');
      return 0;
    }
  }
}