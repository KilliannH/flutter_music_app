import 'package:flutter/material.dart';

import 'package:flutter_music_app/services/dataService.dart';

import 'aPlayer.dart';

class AlbumRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: this._buildAppBar(context),
      body: FutureBuilder<dynamic>(
          future: DataService.getSongsByAlbum(),
          // a previously-obtained Future<dynamic> or null
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              List songs = snapshot.data;
              return Column(children: <Widget>[
                Expanded(child: this._buildSongList(songs)),
                Divider(
                  thickness: 1.5,
                  indent: 0,
                  endIndent: 0,
                ),
                APlayer(),
              ]);
            } else if (snapshot.hasError) {
              return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('Error: ${snapshot.error}'),
                    )
                  ]));
            } else {
              return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                    SizedBox(
                      child: CircularProgressIndicator(),
                      width: 60,
                      height: 60,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Awaiting result...'),
                    )
                  ]));
            }
          }),
    );
  }

  _buildAppBar(navContext) {
    return AppBar(title: Text('Albums'), actions: <Widget>[
      // overflow menu
      PopupMenuButton<Object>(
        onSelected: (value) {
          Navigator.push(
            navContext,
            MaterialPageRoute(builder: (context) => AlbumsRoute()),
          );
        },
        itemBuilder: (BuildContext context) {
          var list = List<PopupMenuEntry<Object>>();
          list.add(PopupMenuItem<Object>(
            value: 1,
            child: Text('Albums'),
          ));
          list.add(PopupMenuItem<Object>(
            value: 2,
            child: Text('Artists'),
          ));
          list.add(PopupMenuDivider());
          list.add(PopupMenuItem<Object>(
            value: 3,
            child: Text('Add'),
          ));
          return list;
        },
      ),
    ]);
  }

  _buildAlbumList(albums) {
    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(15),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      crossAxisCount: 2,
      children:
      albums.map<Widget>((album) {
        return Material(
            child: Ink.image(image: NetworkImage(album.img),
              child: InkWell(
                onTap: () {},
              ),
            ),
        );
      }).toList(),
    );
  }
}
