import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(),
      body:/*if(kIsWeb) {
          const Text("routing working");
        } else {*/
      const Image(
        image : NetworkImage(
            "http://harekrishnacalendar.com/wp-content/uploads/2012/09/Srila-Prabhupada-Quotes-For-Month-July-07.png"),
      ),
      //}
    );
  }
}
