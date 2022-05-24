import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'model/counter_model.dart';
import 'bloc/counter_bloc.dart';

class CounterWidget extends StatelessWidget {
  const CounterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Counter counter = context.select((CounterBloc bloc) => bloc.state.counter);
    int liveRounds = counter.liveRounds;
    int liveCount = counter.liveCount;

    return Text(
            '$liveRounds x $liveCount',
            style: Theme.of(context).textTheme.headline4,
    );
  }
}
