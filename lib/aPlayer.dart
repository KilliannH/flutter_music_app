import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_music_app/playerScreen.dart';
import 'dart:convert';

import 'models/song.dart';

enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }

class APlayer extends StatefulWidget {
  final Song currentSong;
  final PlayerMode mode;
  final List<Song> songList;

  APlayer({@required this.currentSong, this.mode = PlayerMode.MEDIA_PLAYER, this.songList});

  @override
  State<StatefulWidget> createState() {
    return _APlayerState(currentSong.filename, mode);
  }
}

class _APlayerState extends State<APlayer> {

  Song previousSong;
  Song nextSong;

  String url;
  String filename;

  PlayerMode mode;

  AudioPlayer _audioPlayer;
  AudioPlayerState _audioPlayerState;
  Duration _duration;
  Duration _position;

  PlayerState _playerState = PlayerState.stopped;
  PlayingRouteState _playingRouteState = PlayingRouteState.speakers;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  get _isPlaying => _playerState == PlayerState.playing;
  get _isPaused => _playerState == PlayerState.paused;
  get _durationText => _duration?.toString()?.split('.')?.first ?? '';
  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  get _isPlayingThroughEarpiece =>
      _playingRouteState == PlayingRouteState.earpiece;

  _APlayerState(this.filename, this.mode);

  @override
  void initState() {
    super.initState();
    for(var i = 0; i < widget.songList.length; i++) {
      if (widget.songList[i].id == widget.currentSong.id) {
        if (i > 0) {
          previousSong = widget.songList[i - 1];
        }

        if (i < widget.songList.length - 1) {
          nextSong = widget.songList[i + 1];
        }
      }
    }
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40.0),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Text(
                        _position != null
                            ? '${_positionText ?? ''} / ${_durationText ?? ''}'
                            : _duration != null ? _durationText : '',
                        style: TextStyle(fontSize: 15.0,), textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Slider(
                        onChanged: (v) {
                          final Position = v * _duration.inMilliseconds;
                          _audioPlayer
                              .seek(Duration(milliseconds: Position.round()));
                        },
                        value: (_position != null &&
                            _duration != null &&
                            _position.inMilliseconds > 0 &&
                            _position.inMilliseconds < _duration.inMilliseconds)
                            ? _position.inMilliseconds / _duration.inMilliseconds
                            : 0.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: _isPlaying || _isPaused ? () => _stop() : () => _skipPrevious(context),
                      iconSize: 50.0,
                      icon: Icon(Icons.skip_previous),
                      color: Colors.black45),
                  ClipOval(
                    child: Container(
                      color: Colors.lightBlue,
                      child: IconButton(
                                onPressed: _isPlaying ? () => _pause() : () => _play(),
                                iconSize: 50.0,
                                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                                  color: Colors.white
                            ),
                    ),
                  ),
                  IconButton(
                      onPressed: () => _skipNext(context),
                      iconSize: 50.0,
                      icon: Icon(Icons.skip_next),
                      color: Colors.black45),
                ],
              ),
            ),
      ]),
    ]);
  }

  _skipPrevious(context) => previousSong != null ? Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PlayerScreen(previousSong, widget.songList))) : null;

  _skipNext(context) => nextSong != null ? Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PlayerScreen(nextSong, widget.songList))) : null;

  Future<String> prepareUrl(String filename) async {
    var value = await rootBundle.loadString('assets/config.json');

    final config = jsonDecode(value);

    return '${config['api_host']}:${config['api_port']}${config['api_endpoint']}' + '/stream/' + filename;
  }

  void _initAudioPlayer() async {
    url = await prepareUrl(filename);
    _audioPlayer = AudioPlayer(mode: mode);

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);

      // TODO implemented for iOS, waiting for android impl
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        // (Optional) listen for notification updates in the background
        _audioPlayer.startHeadlessService();

        // set at least title to see the notification bar on ios.
        _audioPlayer.setNotification(
            title: 'App Name',
            artist: 'Artist or blank',
            albumTitle: 'Name or blank',
            imageUrl: 'url or blank',
            forwardSkipInterval: const Duration(seconds: 30), // default is 30s
            backwardSkipInterval: const Duration(seconds: 30), // default is 30s
            duration: duration,
            elapsedTime: Duration(seconds: 0));
      }
    });

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
          _position = p;
        }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
          _onComplete();
          setState(() {
            _position = _duration;
          });
        });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _audioPlayerState = state;
      });
    });

    _audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _audioPlayerState = state);
    });

    _playingRouteState = PlayingRouteState.speakers;

    _play();
  }

  Future<int> _play() async {
    final playPosition = (_position != null &&
        _duration != null &&
        _position.inMilliseconds > 0 &&
        _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    final result = await _audioPlayer.play(url, position: playPosition);
    if (result == 1) setState(() => _playerState = PlayerState.playing);

    // default playback rate is 1.0
    // this should be called after _audioPlayer.play() or _audioPlayer.resume()
    // this can also be called everytime the user wants to change playback rate in the UI
    _audioPlayer.setPlaybackRate(playbackRate: 1.0);

    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) setState(() => _playerState = PlayerState.paused);
    return result;
  }

  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration();
      });
    }
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
    _skipNext(this.context);
  }
}