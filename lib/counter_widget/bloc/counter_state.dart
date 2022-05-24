part of 'counter_bloc.dart';

class CounterState extends Equatable {
  final Counter counter;

  const CounterState({required this.counter });

  @override
  List<Object> get props => [counter];
}