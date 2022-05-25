import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../model/counter_model.dart';

part 'counter_event.dart';
part 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  //TODO: need to get current counter values (round, count) from shared preferences
  CounterBloc() : super(CounterState(counter: Counter(liveCount: 0, liveRounds: 0))) {
    on<IncrementCounter>(increment);
    on<DecrementCounter>(decrement);
  }

  void increment(IncrementCounter event, Emitter<CounterState> emit) {
    // print("increment");
    // state.counter.incrementCount();
    emit(CounterState(counter:Counter(liveCount:state.counter.liveCount + 1,
        liveRounds: state.counter.liveRounds)));
  }
  void decrement(DecrementCounter event, Emitter<CounterState> emit) {
    // print("decrement");
    //state.counter.decrementCount();
    if (state.counter.liveCount > 0) {
      emit(CounterState(counter: Counter(liveCount: state.counter.liveCount - 1,
          liveRounds: state.counter.liveRounds)));
    }
  }
}
