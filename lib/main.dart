import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:japa_counter/counter_widget/counter_widget.dart';
import 'package:japa_counter/utils/shared_prefs.dart';
import 'counter_observer.dart';
import 'counter_widget/model/counter_model.dart';
import 'counter_form.dart';
import 'counter_widget/bloc/counter_bloc.dart';

void main() async {
  // Required for async calls in `main`
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPrefs instance.
  await SharedPrefs.init();
  BlocOverrides.runZoned(
    () => runApp(const MyApp()),
    blocObserver: CounterObserver(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Japa Counter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CounterPage(),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterBloc>(
      create: (_) => CounterBloc(),
      child: Builder(
        builder: (context) => DefaultTabController(
          length: 2,
          child: Scaffold(
            drawer: Drawer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  InkWell(onTap: () => _showAboutUs(context),
                    child: const ListTile(
                      leading: Icon(Icons.home),
                      title: Text(
                        'About Us',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const ListTile(
                    leading: Icon(Icons.phone),
                    title: Text(
                      'Contact',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  /*ListTile(
                    leading: Icon(Icons.home),
                    title: Text('About Us',
                      style: const TextStyle(fontWeight: FontWeight.bold),),),
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text('About Us',
                      style: const TextStyle(fontWeight: FontWeight.bold),),),*/
                ],
              ),
            ),
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => {},
                ),
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(
                    icon: Text("Counter"),
                  ),
                  Tab(
                    icon: Text("Settings"),
                  ),
                ],
              ),
              title: const Text("Japa Counter"),
            ),
            body: TabBarView(
              children: [
                Center(
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
                const ResetForm(),
              ],
            ),
          ),
        ),
      ),
// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _showAboutUs(BuildContext context) async {
    await showDialog(context: context,
        builder: (BuildContext context) {
          return const AlertDialog(title: Text("ISL collaboration"),
          );
        },);
  }
}

