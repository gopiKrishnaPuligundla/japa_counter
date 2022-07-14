import 'package:equatable/equatable.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:japa_counter/utils/shared_prefs.dart';


class Counter extends Equatable {
  static int? maxCount = 108, maxRounds = 16;
  int liveCount = 0;
  int liveRounds = 0;

  // Counter({ required liveCount, required liveRounds }) {
  Counter({required this.liveCount, required this.liveRounds } ) {
    // this.liveCount = liveCount;
    // this.liveRounds = liveRounds;

    SharedPrefs.instance.setInt('liveCount', liveCount);
    if (liveCount == maxCount) {
      Vibrate.feedback(FeedbackType.success);
      //TODO: add to database
      liveRounds++;
      SharedPrefs.instance.setInt('liveRounds', liveRounds);
      liveCount = 0;
    }
    if (liveRounds == maxRounds) {
      Vibrate.feedback(FeedbackType.heavy);
      liveRounds = 0;
      liveCount  = 0;
      SharedPrefs.instance.setInt('liveRounds', liveRounds);
      SharedPrefs.instance.setInt('liveCount', liveCount);
      //TODO: update database
    }
  }

  // TODO: implement props
  @override
  List<Object?> get props => [liveRounds, liveCount];

/*
  int get liveCount => liveCount;

  void incrementCount() async {
    print('maxCount : $maxCount maxRounds: $maxRounds');
    print('livecount: $liveCount \n liveRounds: $liveRounds');
    liveCount++;
    if (liveCount == maxCount) {
      Vibrate.feedback(FeedbackType.success);
      SharedPrefs.instance.setInt('liveCount', liveCount);
      //TODO: add to database
      liveRounds++;
      SharedPrefs.instance.setInt('liveRounds', liveRounds);
      liveCount = 0;
    }
    if (liveRounds == maxRounds) {
      Vibrate.feedback(FeedbackType.heavy);
      liveRounds = 0;
      liveCount  = 0;
      SharedPrefs.instance.setInt('liveRounds', liveRounds);
      SharedPrefs.instance.setInt('liveCount', liveCount);
      //TODO: update database
    }
  }

  void decrementCount() async {
    print('maxCount : $maxCount maxRounds: $maxRounds');
    print('livecount: $liveCount \n liveRounds: $liveRounds');
    if (liveCount > 0) {
      liveCount--;
      SharedPrefs.instance.setInt('liveCount', liveCount);
      //TODO: delete last row from database
    }
  }
  */

  Counter copyWith({
    int? liveCount,
    int? liveRounds,
  }) {
    return Counter(
      liveCount: liveCount ?? this.liveCount,
      liveRounds: liveRounds ?? this.liveRounds,
    );
  }
}
