import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japa_counter/helper/object_box.dart';
import 'package:japa_counter/main.dart';
import 'package:japa_counter/quotes_feature/quotes_model.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({Key? key}) : super(key: key);

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  final now = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Text("My Quotes"),
              ),
              Tab(
                icon: Text("Images"),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CustomQuotes(),
            /*if(kIsWeb) {
          const Text("routing working");
        } else {*/
            Image(
              image: NetworkImage(
                  "http://harekrishnacalendar.com/wp-content/uploads/2012/09/Srila-Prabhupada-Quotes-For-Month-July-07.png"),
            ),
            //}
          ],
        ),
      ),
    );
  }
}

class CustomQuotes extends ConsumerWidget {
  const CustomQuotes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ObjectBox objectBox = ref.watch(objectBoxProvider);
    List<Quote> quotes = objectBox.getAllQuotes();
    debugPrint("quotes : ($quotes.length)");
    return ListView.builder(
      itemCount: quotes.length,
      itemBuilder: (BuildContext context, int index) {
        return Dismissible(
          key: UniqueKey(),
          child: Text(quotes != null ? quotes[index].quoteStr : 'Error'),
          // child:Text(quotes != null ? quotes[index]: 'Error'),
          onDismissed: (direction) {
            quotes[index] != null ? objectBox.deleteQuote(quotes[index].id): null;
          },
        );
      },
    );
    // final AsyncValue List<Quote> quotes = ref.watch(objectBoxProvider);
    // final ObjectBoxNotifier obn = ref.watch(OBNProvider);
    // List<Quote>? quotes = obn.getAllQuotes();
    // var quotes = ["HareKrishna", "HareRama"];
  }
}
