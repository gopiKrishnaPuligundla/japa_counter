import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:japa_counter/counter_widget/counter_widget.dart';
import 'package:japa_counter/quotes_screen.dart';
import 'package:japa_counter/vaishnav_calendar_screen.dart';
import 'package:japa_counter/home_screen.dart';
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
      child: const HomeScreen(),
    );
  }


}
