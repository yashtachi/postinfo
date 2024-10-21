import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KPISubmissionForm extends StatefulWidget {
  @override
  _KPISubmissionFormState createState() => _KPISubmissionFormState();
}

class _KPISubmissionFormState extends State<KPISubmissionForm> {
  final _formKey = GlobalKey<FormState>();
  final officeIdController = TextEditingController();
  final deliveryTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Submit KPI Data')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: officeIdController,
              decoration: InputDecoration(labelText: 'Office ID'),
              validator: (value) {
                if (value!.isEmpty) return 'Please enter office ID';
                return null;
              },
            ),
            TextFormField(
              controller: deliveryTimeController,
              decoration: InputDecoration(labelText: 'Delivery Time (mins)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) return 'Please enter delivery time';
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  FirebaseFirestore.instance.collection('kpi_data').add({
                    'officeId': officeIdController.text,
                    'delivery_time': int.parse(deliveryTimeController.text),
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('KPI Data Submitted')));
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
