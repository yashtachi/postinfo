import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'citizen_portal/citizen_tracking_screen.dart';
import 'forms/kpi_submission_form.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DoP Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DashboardScreen()));
              },
              child: Text('View KPI Dashboard'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => KPISubmissionForm()));
              },
              child: Text('Submit KPI Data'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CitizenTrackingScreen()));
              },
              child: Text('Citizen Tracking'),
            ),
          ],
        ),
      ),
    );
  }
}
