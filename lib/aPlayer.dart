import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dart:convert';
import './models/song.dart';

typedef void OnError(Exception exception);

Future<String> prepareUrl(String filename) async {
  var value = await rootBundle.loadString('assets/config.json');

  final config = jsonDecode(value);

  return '${config['api_host']}:${config['api_port']}${config['api_endpoint']}' + '/stream/' + filename;
}

enum PlayerState { stopped, playing, paused }

class APlayer extends StatefulWidget {

  final Song song;
  APlayer(this.song);

  @override
  _APlayerState createState() => new _APlayerState();
}

class _APlayerState extends State<APlayer> {
  Duration duration;
  Duration position;

  AudioPlayer audioPlayer;

  var url;

  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;

  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration
          .toString()
          .split('.')
          .first : '';

  get positionText =>
      position != null ? position
          .toString()
          .split('.')
          .first : '';

  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }

  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
          if (s == AudioPlayerState.PLAYING) {
            setState(() => duration = audioPlayer.duration);
          } else if (s == AudioPlayerState.STOPPED) {
            onComplete();
            setState(() {
              position = duration;
            });
          }
        }, onError: (msg) {
          setState(() {
            playerState = PlayerState.stopped;
            duration = new Duration(seconds: 0);
            position = new Duration(seconds: 0);
          });
        });
  }

  Future play() async {
    url = await prepareUrl(widget.song.filename);
    await audioPlayer.play(url);
    setState(() {
      playerState = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = new Duration();
    });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: new EdgeInsets.all(16.0),
        child: new Column(mainAxisSize: MainAxisSize.min, children: [
          new Row(mainAxisSize: MainAxisSize.min, children: [
            new IconButton(
                onPressed: isPlaying ? null : () => play(),
                iconSize: 64.0,
                icon: new Icon(Icons.play_arrow),
                color: Colors.cyan),
            new IconButton(
                onPressed: isPlaying ? () => pause() : null,
                iconSize: 64.0,
                icon: new Icon(Icons.pause),
                color: Colors.cyan),
            new IconButton(
                onPressed: isPlaying || isPaused ? () => stop() : null,
                iconSize: 64.0,
                icon: new Icon(Icons.stop),
                color: Colors.cyan),
          ]),
          duration == null
              ? new Container()
              : new Slider(
              value: position?.inMilliseconds?.toDouble() ?? 0.0,
              onChanged: (double value) =>
                  audioPlayer.seek((value / 1000).roundToDouble()),
              min: 0.0,
              max: duration.inMilliseconds.toDouble()),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new IconButton(
                  onPressed: () => null,
                  icon: new Icon(Icons.headset_off),
                  color: Colors.cyan),
              new IconButton(
                  onPressed: () => null,
                  icon: new Icon(Icons.headset),
                  color: Colors.cyan),
            ],
          ),
          new Row(mainAxisSize: MainAxisSize.min, children: [
            new Padding(
                padding: new EdgeInsets.all(12.0),
                child: new Stack(children: [
                  new CircularProgressIndicator(
                      value: 1.0,
                      valueColor: new AlwaysStoppedAnimation(Colors.grey[300])),
                  new CircularProgressIndicator(
                    value: position != null && position.inMilliseconds > 0
                        ? (position?.inMilliseconds?.toDouble() ?? 0.0) /
                        (duration?.inMilliseconds?.toDouble() ?? 0.0)
                        : 0.0,
                    valueColor: new AlwaysStoppedAnimation(Colors.cyan),
                    backgroundColor: Colors.yellow,
                  ),
                ])),
            new Text(
                position != null
                    ? "${positionText ?? ''} / ${durationText ?? ''}"
                    : duration != null ? durationText : '',
                style: new TextStyle(fontSize: 24.0))
          ])
        ]));
  }
}