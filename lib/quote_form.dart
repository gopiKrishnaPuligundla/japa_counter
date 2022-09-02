import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:japa_counter/main.dart';
import 'package:japa_counter/quotes_feature/quotes_model.dart';

import 'helper/object_box.dart';

class QuoteForm extends ConsumerStatefulWidget {
  const QuoteForm({Key? key}) : super(key: key);

  @override
  //State<QuoteForm> createState() => _QuoteFormState();
  _QuoteFormState createState() => _QuoteFormState();
}

class _QuoteFormState extends ConsumerState<QuoteForm> {
  String dropDownValue = 'Prabhupada';
  final _formKey = GlobalKey<FormState>();
  TextEditingController quotesCtl = TextEditingController(text: '');
  // TextEditingController countCtl = TextEditingController(text: '16');

  @override
  Widget build(BuildContext context) {
    Quote quote;

    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10.0),
            Row(
              children: [
                DropdownButton(
                  value: dropDownValue,
                  hint: const Text('whose Quote'),
                  icon: const Icon(Icons.arrow_downward),
                  onChanged: (String? newValue) {
                    debugPrint("newValue:$newValue");
                    setState(() {
                      dropDownValue = newValue!;
                    });
                  },
                  items: <String>['Prabhupada', 'Krishna', 'Misc']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                ElevatedButton(
                  onPressed: () {
                    GoRouter.of(context).push('/person_form');
                  },
                  child: const Icon(Icons.add),
                )
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            TextFormField(
              controller: quotesCtl,
              //initialValue: "108",
              decoration: InputDecoration(
                  labelText: 'Quote',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  )),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some info';
                }
                return null;
              },
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing Data')),
                        );
                      }
                      quote = Quote(quoteStr: quotesCtl.text, name: dropDownValue);
                      debugPrint("quote: ${quotesCtl.text}. name: $dropDownValue");
                      //ref.read(OBNProvider.notifier).addQuote(quote);
                      ObjectBox objectBox = ref.read(objectBoxProvider);
                      objectBox.insertQuote(quote);
                      debugPrint("quote Added");
                      //show_obn_entries(ref.read(OBNProvider).objectBox!);
                    },
                    child: const Text('Update'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
