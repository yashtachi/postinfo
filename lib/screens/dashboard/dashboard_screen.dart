import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('KPI Dashboard')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('kpi_data').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: Text('Office ID: ${doc['officeId']}'),
                subtitle: Text('Delivery Time: ${doc['delivery_time']} mins'),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
