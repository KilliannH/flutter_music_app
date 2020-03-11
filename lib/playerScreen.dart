import 'package:flutter/material.dart';

import 'aPlayer.dart';
import 'models/song.dart';

class PlayerScreen extends StatelessWidget {

  final Song selectedSong;

  PlayerScreen(this.selectedSong);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: this._buildAppBar(context),
        body: APlayer(filename: this.selectedSong.filename)
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