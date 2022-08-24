import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'model/counter_model.dart';
import 'bloc/counter_bloc.dart';

class CounterWidget extends StatelessWidget {
  const CounterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //print("COMING HERE");

    return BlocBuilder<CounterBloc, CounterState>(
      builder: (context, state) {
        return Text(
          '${state.counter.liveRounds} x ${state.counter.liveCount}',
          style: Theme
              .of(context)
              .textTheme
              .headline4,
        );
      },
    );
  }
}
