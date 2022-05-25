import 'dart:developer';

import 'package:equatable/equatable.dart';


class Counter extends Equatable {
  static int maxCount = 108, maxRounds = 16;
  int _liveCount = 0;
  int _liveRounds = 0;

  Counter({required liveCount, required liveRounds}) {
    _liveCount  = liveCount;
    _liveRounds = liveRounds;
  }

  int get liveCount => _liveCount;

  // TODO: implement props
  @override
  List<Object?> get props => [
    _liveRounds,
    _liveCount
  ];
  void incrementCount() {
    log('livecount: $_liveCount \n liveRounds: $_liveRounds');
    _liveCount++;
    if(_liveCount == maxCount) {
      //TODO: vibrate for small time
      //TODO: add to shared preference
      //TODO: add to database
      _liveRounds++;
      _liveCount = 0;
    }
    if(_liveRounds == maxRounds) {
      //TODO: vibrate for more time
      //TODO: update database
      //TODO: update shared preferences
    }
  }
  void decrementCount() {
    log('livecount: $_liveCount \n liveRounds: $_liveRounds');
    if(_liveCount > 0) {
      _liveCount--;
      //TODO: delete last row from database
      //TODO: update shared preferences
    }
  }
  int get liveRounds => _liveRounds;
}


