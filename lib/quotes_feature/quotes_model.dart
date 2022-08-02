import 'package:objectbox/objectbox.dart';

@Entity()
class Quote {
  int id;
  String quoteStr;
  String name;

  Quote({
   this.id = 0,
    required this.quoteStr,
    required this.name
  });
}