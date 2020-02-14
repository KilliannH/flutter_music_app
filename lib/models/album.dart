class Album {

  final String title;
  final String artist;
  final List<dynamic> songs;
  final String img;

  Album(this.title, this.artist, this.songs, this.img);

  factory Album.fromJson(dynamic json) {
    return Album(json['title'] as String, json['artist'] as String, json['songs'] as List<dynamic>, json['img'] as String);
  }
}