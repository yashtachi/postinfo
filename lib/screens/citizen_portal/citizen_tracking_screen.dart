import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CitizenTrackingScreen extends StatefulWidget {
  @override
  _CitizenTrackingScreenState createState() => _CitizenTrackingScreenState();
}

class _CitizenTrackingScreenState extends State<CitizenTrackingScreen> {
  final trackingIdController = TextEditingController();
  String? serviceStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Citizen Tracking Portal')),
      body: Column(
        children: [
          TextField(
            controller: trackingIdController,
            decoration: InputDecoration(labelText: 'Enter Tracking ID'),
          ),
          ElevatedButton(
            onPressed: () async {
              final doc = await FirebaseFirestore.instance
                  .collection('service_tracking')
                  .doc(trackingIdController.text)
                  .get();

              setState(() {
                serviceStatus = doc.exists
                    ? doc['service_status']
                    : 'Tracking ID not found';
              });
            },
            child: Text('Track Service'),
          ),
          if (serviceStatus != null) Text('Service Status: $serviceStatus'),
        ],
      ),
    );
  }
}
