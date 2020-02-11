import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class SongItem extends StatelessWidget {
  final String songTitle;
  final String songArtist;

  SongItem(this.songTitle, this.songArtist);

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        Image(
              image: NetworkImage('https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
              fit: BoxFit.contain,
            ),
        Container(
          margin: new EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  songTitle,
                ),
                Text(
                  songArtist,
                ),
            ],
          ),
        ),
      ],

    );
  }
}
