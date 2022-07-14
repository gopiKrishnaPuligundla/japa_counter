import 'package:flutter/material.dart';

class ResetForm extends StatefulWidget {
  const ResetForm({Key? key}) : super(key: key);

  @override
  State<ResetForm> createState() => _ResetFormState();
}

class _ResetFormState extends State<ResetForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController roundsCtl = TextEditingController(text: '108');
  TextEditingController countCtl = TextEditingController(text: '16');

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10.0),
          TextFormField(
            keyboardType: TextInputType.number,
            controller: countCtl,
            // initialValue: "16",
            decoration: InputDecoration(
                labelText: 'Rounds',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                )),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter no of Rounds';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 10.0,
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            controller: roundsCtl,
            //initialValue: "108",
            decoration: InputDecoration(
                labelText: 'Beads',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                )),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter no of Beads';
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
                  },
                  child: const Text('Update'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')),
                      );
                      countCtl.value = const TextEditingValue(text:"108");
                      roundsCtl.value = const TextEditingValue(text:"16");
                    }
                  },
                  child: const Text('Reset'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
