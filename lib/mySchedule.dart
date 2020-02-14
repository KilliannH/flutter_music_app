import 'package:flutter/cupertino.dart';

import 'models/song.dart';

class MySchedule with ChangeNotifier {
  Song _selectedSong;

  Song get selectedSong => _selectedSong;

  void setSelectedSong(newSong) {
    this._selectedSong = newSong;
    notifyListeners();
  }
}