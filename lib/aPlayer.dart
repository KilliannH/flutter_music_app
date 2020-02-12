import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_music_app/services/dataService.dart';

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;


class APlayer extends StatefulWidget {

  final filename;

  APlayer(this.filename);

  @override
  State<StatefulWidget> createState() {
    return APlayerState();
  }
}

enum PlayerStates {STOPPED, LOADED, PLAYING, PAUSED}

class APlayerState extends State<APlayer> {

  Future<String> prepareUrl(String filename) async {
    var value = await rootBundle.loadString('assets/config.json');

    final config = jsonDecode(value);

    return '${config['api_host']}:${config['api_port']}${config['api_endpoint']}' + '/stream/' + filename;
  }

  var currentState = PlayerStates.STOPPED;

  AudioPlayer audioPlayer = AudioPlayer();

  play() async {

    final url = await prepareUrl(widget.filename);
    print(url);
    if(currentState == PlayerStates.STOPPED) {
      AudioPlayer.logEnabled = true;
      int result = await audioPlayer.play(url);
      if (result == 1) {
        print('success');
        currentState = PlayerStates.PLAYING;
        // success
      }
    }
  }

  resume() async {
    if(currentState == PlayerStates.PAUSED) {
      int result = await audioPlayer.resume();
      if(result == 1) {
        print('success');
        currentState = PlayerStates.PLAYING;
      }
    }
  }

  pause() async {
    if(currentState == PlayerStates.PLAYING) {
      int result = await audioPlayer.pause();
      if (result == 1) {
        print('success');
        // success
        currentState = PlayerStates.PAUSED;
      }
    }
  }

  void _togglePlay() {
    if(currentState == PlayerStates.STOPPED) {
      setState(() {
        play();
        playerIcons[1] = Icon(
          Icons.pause,
          color: Colors.black38,
          size: 30,
        );
      });
    } else if(currentState == PlayerStates.PLAYING) {
      setState(() {
        pause();
        playerIcons[1] = Icon(
          Icons.play_arrow,
          color: Colors.black38,
          size: 30,
        );
      });
    } else if(currentState == PlayerStates.PAUSED) {
      setState(() {
        resume();
        playerIcons[1] = Icon(
          Icons.pause,
          color: Colors.black38,
          size: 30,
        );
      });
    }
  }
  
  var playerIcons = [
    Icon(
      Icons.skip_previous,
      color: Colors.black38,
      size: 30,
    ),
    Icon(
      Icons.play_arrow,
      color: Colors.black38,
      size: 30,
    ),
    Icon(
      Icons.skip_next,
      color: Colors.black38,
      size: 30,
    )
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        height: 50,
        margin: EdgeInsets.only(bottom: 7),
        // margin: EdgeInsets.all(10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: playerIcons.map((item) {
              return Padding(
                  padding: EdgeInsets.all(10.0),
                  child: InkWell(
                      customBorder: new CircleBorder(),
                      onTap: () {
                        _togglePlay();
                      },
                      splashColor: Colors.black12,
                      child: item
                  )
              );
            }).toList()
        )
    );
  }
}