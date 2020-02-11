class Song {

  final String title;
  final String artist;
  final String album;
  final String albumImg;
  final String filename;

  Song(this.title, this.artist, this.album, this.albumImg, this.filename);

  factory Song.fromJson(dynamic json) {
    return Song(json['title'] as String, json['artist'] as String, json['album'] as String, json['album_img'] as String, json['filename'] as String);
  }
}