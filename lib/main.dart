import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:japa_counter/counter_widget/counter_widget.dart';
import 'package:japa_counter/quotes_screen.dart';
import 'package:japa_counter/vaishnav_calendar_screen.dart';
import 'package:japa_counter/utils/shared_prefs.dart';
import 'package:volume_key_board/volume_key_board.dart';
import 'counter_observer.dart';
import 'counter_form.dart';
import 'counter_widget/bloc/counter_bloc.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  // Required for async calls in `main`
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPrefs instance.
  await SharedPrefs.init();
  
  // Set global BlocObserver
  Bloc.observer = CounterObserver();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        /*pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const CounterPage(),
        ),*/
        builder: (context, state) => const CounterPage(),
        //),
        routes: [
          GoRoute(
            path: 'quotes',
            /*pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const QuotesScreen(),
            ),*/
            builder: (context, state) => const QuotesScreen(),
          ),
        ],
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: Scaffold(
            body: Center(
          child: Text(
            state.error.toString(),
          ),
        ))),
    initialLocation: '/',
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
      debugShowCheckedModeBanner: false,
      title: 'Japa Counter',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  State<CounterPage> createState() => _CounterPageState();
}

enum Menu { resetBeads, resetRounds, resetBoth }

class _CounterPageState extends State<CounterPage> {
  @override
  void initState() {
    super.initState();
    // Start listening for volume button presses
    VolumeKeyBoard.instance.addListener((VolumeKey event) {
      if (mounted && context.read<CounterBloc>() != null) {
        if (event == VolumeKey.up) {
          // Volume Up button pressed - increment counter
          context.read<CounterBloc>().add(IncrementCounter());
        } else if (event == VolumeKey.down) {
          // Volume Down button pressed - decrement counter
          context.read<CounterBloc>().add(DecrementCounter());
        }
      }
    });
  }

  @override
  void dispose() {
    // Stop listening for volume button presses
    VolumeKeyBoard.instance.removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterBloc>(
      create: (_) => CounterBloc(),
      child: Builder(
        builder: (context) => DefaultTabController(
          length: 3,
          child: Scaffold(
            drawer: Drawer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    onTap: () => _showAboutUs(context),
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
                  InkWell(
                    onTap: () => GoRouter.of(context).go('/quotes'),
                    child: const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text(
                        'Prabhupada Quotes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const ListTile(
                    leading: Icon(Icons.calendar_month),
                    title: Text(
                      'Vaishnav Calendar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            appBar: AppBar(
              actions: [
                PopupMenuButton<Menu>(onSelected: (Menu item) {
                  switch (item) {
                    case Menu.resetBeads:
                      context.read<CounterBloc>().add(ResetBeads());
                      break;
                    case Menu.resetRounds:
                      context.read<CounterBloc>().add(ResetRounds());
                      break;
                    case Menu.resetBoth:
                      context.read<CounterBloc>().add(ResetCounters());
                      break;
                  }
                }, itemBuilder: (context) {
                  return [
                    const PopupMenuItem(
                      value: Menu.resetBeads,
                      child: Text('ResetBeads'),
                    ),
                    const PopupMenuItem(
                      value: Menu.resetRounds,
                      child: Text('ResetRounds'),
                    ),
                    const PopupMenuItem(
                      value: Menu.resetBoth,
                      child: Text('ResetBoth'),
                    ),
                  ];
                }),
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(
                    icon: Text("Counter"),
                  ),
                  Tab(
                    icon: Text("Settings"),
                  ),
                  Tab(
                    icon: Text("Calendar"),
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
                        heroTag: const ValueKey("1"),
                        onPressed: () =>
                            context.read<CounterBloc>().add(IncrementCounter()),
                        tooltip: 'Increment',
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(width: 60.0, child: Divider()),
                      FloatingActionButton(
                        heroTag: const ValueKey("2"),
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
                const VaishnavCalendarScreen(),
              ],
            ),
          ),
        ),
      ),
// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _showAboutUs(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text("ISL collaboration"),
        );
      },
    );
  }
}
