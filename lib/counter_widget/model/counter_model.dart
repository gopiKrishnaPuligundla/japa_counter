import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:japa_counter/utils/shared_prefs.dart';

class Counter extends Equatable {
  static int? maxCount = 108, maxRounds = 16;
  int _liveCount = 0;
  int _liveRounds = 0;

  Counter({ required liveCount, required liveRounds }) {
    _liveCount = liveCount;
    _liveRounds = liveRounds;
    SharedPrefs.instance.setInt('liveCount', _liveCount);
    if (_liveCount == maxCount) {
      Vibrate.feedback(FeedbackType.success);
      //TODO: add to database
      _liveRounds++;
      SharedPrefs.instance.setInt('liveRounds', _liveRounds);
      _liveCount = 0;
    }
    if (_liveRounds == maxRounds) {
      Vibrate.feedback(FeedbackType.heavy);
      _liveRounds = 0;
      _liveCount  = 0;
      SharedPrefs.instance.setInt('liveRounds', _liveRounds);
      SharedPrefs.instance.setInt('liveCount', _liveCount);
      //TODO: update database
    }
  }

  int get liveCount => _liveCount;

  // TODO: implement props
  @override
  List<Object?> get props => [_liveRounds, _liveCount];
  void incrementCount() async {
    print('maxCount : $maxCount maxRounds: $maxRounds');
    print('livecount: $_liveCount \n liveRounds: $_liveRounds');
    _liveCount++;
    if (_liveCount == maxCount) {
      Vibrate.feedback(FeedbackType.success);
      SharedPrefs.instance.setInt('liveCount', _liveCount);
      //TODO: add to database
      _liveRounds++;
      SharedPrefs.instance.setInt('liveRounds', _liveRounds);
      _liveCount = 0;
    }
    if (_liveRounds == maxRounds) {
      Vibrate.feedback(FeedbackType.heavy);
      _liveRounds = 0;
      _liveCount  = 0;
      SharedPrefs.instance.setInt('liveRounds', _liveRounds);
      SharedPrefs.instance.setInt('liveCount', _liveCount);
      //TODO: update database
    }
  }

  void decrementCount() async {
    print('maxCount : $maxCount maxRounds: $maxRounds');
    print('livecount: $_liveCount \n liveRounds: $_liveRounds');
    if (_liveCount > 0) {
      _liveCount--;
      SharedPrefs.instance.setInt('liveCount', _liveCount);
      //TODO: delete last row from database
    }
  }

  int get liveRounds => _liveRounds;
}
