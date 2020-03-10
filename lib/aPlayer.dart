import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dart:convert';
import './models/song.dart';

// --todo : REINSTALL PREVIOUS PLAYER

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
    this.play();
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

  skipPrevious() { }

  skipNext() { }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(alignment: Alignment.topCenter,
        padding: new EdgeInsets.all(16.0),
        child: new Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
              padding: EdgeInsets.only(top: 40),
              child:Text(widget.song.title, style: TextStyle(fontSize: 24),)
          ),
          Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text(widget.song.artist, style: TextStyle(fontSize: 18),)),
          Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Image(image: NetworkImage(
              widget.song.albumImg),
              width: 200,
              height: 200
            ),
          ),
          duration == null
              ? new Container()
              : new Row(mainAxisSize: MainAxisSize.min, children: [
                new Text(
                position != null
                    ? "${positionText ?? ''} / ${durationText ?? ''}"
                    : duration != null ? durationText : '',
                style: new TextStyle(fontSize: 16.0), textAlign: TextAlign.left,)
          ]),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: new Row(mainAxisSize: MainAxisSize.min, children: [
              new IconButton(
                  onPressed: () => isPlaying ? stop() : skipPrevious(),
                  iconSize: 40,
                  icon: new Icon(Icons.skip_previous),
              ),
              new IconButton(
                  onPressed: isPlaying ? () => pause() : () => play(),
                  iconSize: 40,
                  icon: new Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              ),
              new IconButton(
                  onPressed: () => skipNext(),
                  iconSize: 40,
                  icon: new Icon(Icons.skip_next),
              ),
            ]),
          ),
        ]));
  }
}