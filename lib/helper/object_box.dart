import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../quotes_feature/quotes_model.dart';
import '../objectbox.g.dart';

class ObjectBox {
  late final Store _store;
  late final Box<Quote> _quoteBox;

  ObjectBox._init(this._store){
    _quoteBox = Box<Quote>(_store);
  }

  static Future<ObjectBox> init() async {
    final store = await openStore();

    return ObjectBox._init(store);
  }

  Quote? getQuote(int id) => _quoteBox.get(id);

  int insertQuote(Quote quote) => _quoteBox.put(quote);

  bool deleteQuote(int id) => _quoteBox.remove(id);

  List<Quote> getAllQuotes() => _quoteBox.getAll().toList();

}

class ObjectBoxNotifier extends ChangeNotifier {
    ObjectBox? objectBox;

    ObjectBoxNotifier({required this.objectBox}) ;

    void addQuote(Quote quote) {
        objectBox?.insertQuote(quote);
        notifyListeners();
    }

    void removeQuote(int id) {
        objectBox?.deleteQuote(id);
        notifyListeners();
    }

    List<Quote>? getAllQuotes() {
      debugPrint(" objectbox: $objectBox");
      return objectBox?.getAllQuotes();
    }
}