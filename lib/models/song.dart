import 'dart:io';

class Song {

  String title;
  String artist;
  String album;
  String album_img;
  String filename;

  Song(this.title, this.artist, this.album, this.album_img, this.filename);

  factory Song.fromJson(dynamic json) {
    return Song(json['title'] as String, json['artist'] as String, json['album'] as String, json['album_img'] as String, json['filename'] as String);
  }
}