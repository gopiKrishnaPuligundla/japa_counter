import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:japa_counter/utils/shared_prefs.dart';
import 'package:meta/meta.dart';

import '../model/counter_model.dart';

part 'counter_event.dart';
part 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  //TODO: need to get current counter values (round, count) from shared preferences

  CounterBloc() : super(CounterState(
      counter: Counter(
          liveCount: SharedPrefs.instance.getInt('liveCount') ?? 0,
          liveRounds: SharedPrefs.instance.getInt('liveRounds') ?? 0 ))) {

    Counter.maxCount = SharedPrefs.instance.getInt('maxCount') ?? 108;
    Counter.maxRounds = SharedPrefs.instance.getInt('maxRounds') ?? 16;
    on<IncrementCounter>(increment);
    on<DecrementCounter>(decrement);
    on<ResetCounters>(reset);
    on<ResetBeads>(resetBeads);
    on<ResetRounds>(resetRounds);
  }
  void reset(ResetCounters event, Emitter<CounterState> emit) {
    emit(CounterState(counter:Counter(liveCount: 0, liveRounds: 0)));
  }

  void resetBeads(ResetBeads event, Emitter<CounterState> emit) {
    emit(CounterState(counter:Counter(liveCount: 0, liveRounds: state.counter.liveRounds)));
  }

  void resetRounds(ResetRounds event, Emitter<CounterState> emit) {
    emit(CounterState(counter:Counter(liveCount: state.counter.liveCount, liveRounds: 0)));
  }

  void increment(IncrementCounter event, Emitter<CounterState> emit) {
    print("increment");
    // state.counter.incrementCount();
    emit(CounterState(counter:Counter(liveCount:state.counter.liveCount + 1,
        liveRounds: state.counter.liveRounds)));
  }

  void decrement(DecrementCounter event, Emitter<CounterState> emit) {
    print("decrement");
    //state.counter.decrementCount();
    if (state.counter.liveCount > 0) {
      emit(CounterState(counter: Counter(liveCount: state.counter.liveCount - 1,
          liveRounds: state.counter.liveRounds)));
    }
  }
}
