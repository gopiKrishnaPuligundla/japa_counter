import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:japa_counter/counter_widget/counter_widget.dart';
import 'counter_widget/model/counter_model.dart';
import 'counter_widget/bloc/counter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Japa Counter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CounterPage(),
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  BlocProvider<CounterBloc>(
      create: (_) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Japa Counter"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FloatingActionButton(
                onPressed: () =>
                    context.read<CounterBloc>().add(IncrementCounter()),
                tooltip: 'Increment',
                child: const Icon(Icons.add),
              ),
              const SizedBox(width: 60.0, child: Divider()),
              FloatingActionButton(
                onPressed: () =>
                    context.read<CounterBloc>().add(DecrementCounter()),
                tooltip: 'Decrement',
                child: const Icon(Icons.remove),
              ),
              const CounterWidget(),
            ],
          ),
        ),
      ),
// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
