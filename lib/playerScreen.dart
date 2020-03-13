import 'package:flutter/material.dart';
import 'package:flutter_music_app/services/cacheService.dart';

import 'aPlayer.dart';
import 'models/song.dart';

class PlayerScreen extends StatelessWidget {

  final Song selectedSong;
  final List<Song> songList;

  PlayerScreen(this.selectedSong, this.songList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: this._buildAppBar(context),
        body: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(top: 40),
                child:Text(selectedSong.title, style: TextStyle(fontSize: 24),)
            ),
            Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text(selectedSong.artist, style: TextStyle(fontSize: 18),)
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Image(image: NetworkImage(
                  selectedSong.albumImg),
                  width: 200,
                  height: 200
              ),
            ),
            APlayer(currentSong: this.selectedSong, songList: songList)
          ],
        )
    );
  }

  _buildAppBar(navContext) {
    return AppBar(title: Text('My Music'), actions: <Widget> [
      // overflow menu
      PopupMenuButton<Object>(
        onSelected: (value) {},
        itemBuilder: (BuildContext context) {
          var list = List<PopupMenuEntry<Object>>();
          list.add(PopupMenuItem<Object>(
            value: 1,
            child: Text('Add New'),
          ));
          return list;
        },
      ),
    ]);
  }

}