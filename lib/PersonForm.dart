import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PersonForm extends StatefulWidget {
  const PersonForm({Key? key}) : super(key: key);

  @override
  State<PersonForm> createState() => _PersonFormState();
}

class _PersonFormState extends State<PersonForm> {

  String dropDownValue = 'Prabhupada';
  final _formKey = GlobalKey<FormState>();
  // TextEditingController roundsCtl = TextEditingController(text: '108');
  // TextEditingController countCtl = TextEditingController(text: '16');

  @override
  Widget build(BuildContext context) {


    return Form(
      key: _formKey,

      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10.0,
            ),
            TextFormField(
              // controller: roundsCtl,
              //initialValue: "108",
              decoration: InputDecoration(
                  labelText: 'Person',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  )),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Persons name';
                }
                return null;
              },
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  //todo: add to database
                  GoRouter.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
