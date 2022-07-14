part of 'counter_bloc.dart';

@immutable
abstract class CounterEvent extends Equatable{
  const CounterEvent();

  @override
  List<Object> get props => [];
}
class IncrementCounter extends CounterEvent {}
class DecrementCounter extends CounterEvent {}
class ResetCounters  extends CounterEvent {}
class ResetBeads extends CounterEvent {}
class ResetRounds extends CounterEvent {}
