import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:japa_counter/counter_widget/counter_widget.dart';
import 'package:japa_counter/quote_form.dart';
import 'package:japa_counter/quotes_feature/quotes_model.dart';
import 'package:japa_counter/quotes_screen.dart';
import 'package:japa_counter/utils/shared_prefs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'PersonForm.dart';
import 'counter_observer.dart';
import 'counter_form.dart';
import 'counter_widget/bloc/counter_bloc.dart';
import 'helper/object_box.dart';

// import 'package:flutter/foundation.dart' show kIsWeb;
final objectBoxProvider = Provider<ObjectBox>((ref) => throw UnimplementedError());
/*final objectBoxProvider = FutureProvider<ObjectBox>((ref)  {
    print("objectBoxProvider");
    return ObjectBox.init();
});

//final quotesAllProvider = StateNotifierProvider<AsyncValue<List<Quote>>>((ref) async {
final OBNProvider = ChangeNotifierProvider<ObjectBoxNotifier>((ref) {
    ObjectBox? ob = ref.read(objectBoxProvider).value;

    print("Hello");
    print("ob: $ob");
    //return ob?.getAllQuotes();
    return ObjectBoxNotifier(objectBox: ob);
} );*/

// ObjectBox? objectBox ;
void main() async {

  // Required for async calls in `main`
  //objectBox = await ObjectBox.init();
  WidgetsFlutterBinding.ensureInitialized();
  ObjectBox objectBox = await ObjectBox.init();
  // Initialize SharedPrefs instance.
  await SharedPrefs.init();
  BlocOverrides.runZoned(
    () => runApp(
        ProviderScope(
            overrides: [objectBoxProvider.overrideWithValue(objectBox)],
        child: MyApp()
    ),
    ),
    // () => runApp(MyApp()),
    blocObserver: CounterObserver(),
  );
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
          GoRoute(
            path: 'quotes_form',
            /*pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const QuotesScreen(),
            ),*/
            builder: (context, state) => const QuoteForm(),
          ),
          GoRoute(
            path: 'person_form',
            /*pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const QuotesScreen(),
            ),*/
            builder: (context, state) => const PersonForm(),
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
                  InkWell(
                    onTap: () => GoRouter.of(context).go('/quotes_form'),
                    child: const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text(
                        'Add Quotes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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

void show_obn_entries(ObjectBox objectBox) {
  Quote elem;
  var a = objectBox.getAllQuotes();
  for (elem in a) {
    debugPrint(
        "quotes in db id" + elem.id.toString() + " " + elem.quoteStr + " " +
            elem.name);
  }
}