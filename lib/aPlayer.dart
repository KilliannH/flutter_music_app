import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_app/mySchedule.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dart:convert';

import 'models/song.dart';

class APlayer extends StatefulWidget {

  APlayer();

  @override
  State<StatefulWidget> createState() {
    return APlayerState();
  }
}

class APlayerState extends State<APlayer> {

  AudioPlayer audioPlayer = AudioPlayer();

  AudioPlayerState playerState;

  Song songLoaded;
  List<Widget> widgetArr = [];

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

  Future<String> prepareUrl(String filename) async {
    var value = await rootBundle.loadString('assets/config.json');

    final config = jsonDecode(value);

    return '${config['api_host']}:${config['api_port']}${config['api_endpoint']}' + '/stream/' + filename;
  }

  Future<int> pause() async {
    int result = await audioPlayer.pause();
    if(result == 1) {
      print('pause success');
      setState(() {
        playerIcons[1] = Icon(
          Icons.play_arrow,
          color: Colors.black38,
          size: 30,
        );
      });
      return 1;
    } else {
      return 0;
    }
  }

  Future<int> resume() async {
    int result = await audioPlayer.resume();
    if(result == 1) {
      print('resume success');
      setState(() {
        playerIcons[1] = Icon(
          Icons.pause,
          color: Colors.black38,
          size: 30,
        );
      });
      return 1;
    } else {
      return 0;
    }
  }

  Future<int> _loadPlayer(Song song) async {
    final url = await prepareUrl(song.filename);

    int result = await audioPlayer.play(url);
    if (result == 1) {
      print('play success');
      setState(() {
        playerIcons[1] = Icon(
          Icons.pause,
          color: Colors.black38,
          size: 30,
        );
      });
      return 1;
      // success
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {

    final schedule = Provider.of<MySchedule>(context);

    audioPlayer.onPlayerStateChanged.listen((AudioPlayerState s) {
        print('Current player state: $s');
        setState(() => playerState = s);
    });

    if(schedule.selectedSong != null) {
      widgetArr = [
        Text(schedule.selectedSong.filename),
        Padding(
            padding: EdgeInsets.all(10.0),
            child: InkWell(
                customBorder: new CircleBorder(),
                onTap: () {},
                splashColor: Colors.black12,
                child: playerIcons[0]
            )
        ),
        Padding(
            padding: EdgeInsets.all(10.0),
            child: InkWell(
                customBorder: new CircleBorder(),
                onTap: () {
                  if(playerState == AudioPlayerState.PLAYING) {
                    pause();
                  } else if(playerState == AudioPlayerState.PAUSED) {
                    resume();
                  }
                },
                splashColor: Colors.black12,
                child: playerIcons[1]
            )
        ),
        Padding(
            padding: EdgeInsets.all(10.0),
            child: InkWell(
                customBorder: new CircleBorder(),
                onTap: () {},
                splashColor: Colors.black12,
                child: playerIcons[2]
            )
        ),
      ];
      if(songLoaded == null) {
        songLoaded = schedule.selectedSong;
        _loadPlayer(songLoaded);
      } else if (songLoaded != schedule.selectedSong) {
        songLoaded = schedule.selectedSong;
        _loadPlayer(songLoaded);
      }

    } else {
      widgetArr = [Text('No song selected')];
    }
    // TODO: implement build
    return Container(
        height: 50,
        margin: EdgeInsets.only(bottom: 7),
        // margin: EdgeInsets.all(10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,

            // todo : render children if selectedSong not null else render 'no song selected'
            children: widgetArr,
        )
    );
  }
}