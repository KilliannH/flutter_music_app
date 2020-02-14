import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_app/schedules/playerSchedule.dart';
import 'package:provider/provider.dart';

class APlayer extends StatefulWidget {

  APlayer();

  @override
  State<StatefulWidget> createState() {
    return APlayerState();
  }
}

class APlayerState extends State<APlayer> {


  PlayerSchedule schedule;

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

  _toggleIcon(playerState) {
    if(playerState == AudioPlayerState.PAUSED) {
        playerIcons[1] = Icon(
          Icons.play_arrow,
          color: Colors.black38,
          size: 30,
        );
    } else if (playerState == AudioPlayerState.PLAYING) {
        playerIcons[1] = Icon(
          Icons.pause,
          color: Colors.black38,
          size: 30,
        );
    }
  }

  @override
  Widget build(BuildContext context) {

    schedule = Provider.of<PlayerSchedule>(context);

    if(schedule.selectedSong != null) {
      _toggleIcon(schedule.playerState);
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
                  if(schedule.playerState == AudioPlayerState.PLAYING) {
                    schedule.pause();
                    setState(() {
                      _toggleIcon(schedule.playerState);
                    });
                  } else if(schedule.playerState == AudioPlayerState.PAUSED) {
                    schedule.resume();
                    setState(() {
                      _toggleIcon(schedule.playerState);
                    });
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