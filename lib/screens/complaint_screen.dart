import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ComplaintScreen extends StatefulWidget {
  @override
  _ComplaintScreenState createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _complaintController = TextEditingController();
  final _trackingNumberController = TextEditingController();

  String _selectedCategory = 'Delivery Delay';
  bool _isSubmitting = false;

  final List<String> _complaintCategories = [
    'Delivery Delay',
    'Damaged Package',
    'Lost Package',
    'Wrong Address',
    'Incorrect Tracking Information',
    'Other',
  ];

  void _submitComplaint() async {
    // Validate form before submission
    if (!_formKey.currentState!.validate()) return;

    // Set submitting state
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get current user
      User? user = FirebaseAuth.instance.currentUser;

      // Check if user is authenticated
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Prepare complaint data
      Map<String, dynamic> complaintData = {
        'userId': user.uid,
        'email': user.email,
        'category': _selectedCategory,
        'description': _complaintController.text.trim(),
        'trackingNumber': _trackingNumberController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Pending',
        'resolution': null,
      };

      // Submit complaint to Firestore
      await FirebaseFirestore.instance
          .collection('complaints')
          .add(complaintData);

      // Show success dialog
      _showSuccessDialog();
    } catch (e) {
      // Show error snackbar
      _showErrorSnackBar(e.toString());
    } finally {
      // Reset submitting state
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text('Complaint Submitted', style: TextStyle(color: Colors.green)),
        content: Text(
          'Your complaint has been successfully registered. Our team will investigate and respond within 3-5 business days.',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Submission Failed: $errorMessage'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'File a Complaint',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Complaint Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Complaint Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _complaintCategories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              SizedBox(height: 16),

              // Tracking Number Input
              TextFormField(
                controller: _trackingNumberController,
                decoration: InputDecoration(
                  labelText: 'Tracking Number (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.track_changes),
                ),
                validator: (value) {
                  // Optional validation for tracking number
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Enter a valid tracking number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Complaint Description
              TextFormField(
                controller: _complaintController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Describe Your Complaint',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a detailed description';
                  }
                  if (value.length < 20) {
                    return 'Description must be at least 20 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitComplaint,
                child: _isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Submit Complaint'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home),
                color: Colors.grey,
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/home'),
                tooltip: 'Home',
              ),
              IconButton(
                icon: Icon(Icons.track_changes),
                color: Colors.grey,
                onPressed: () => Navigator.of(context).pushNamed('/tracking'),
                tooltip: 'Track',
              ),
              SizedBox(width: 40), // Space for FAB
              IconButton(
                icon: Icon(Icons.dashboard),
                color: Colors.grey,
                onPressed: () => Navigator.of(context).pushNamed('/dashboard'),
                tooltip: 'Dashboard',
              ),
              IconButton(
                icon: Icon(Icons.person),
                color: Colors.grey,
                onPressed: () => Navigator.of(context).pushNamed('/profile'),
                tooltip: 'Profile',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        child: Icon(Icons.chat),
        onPressed: () => Navigator.of(context).pushNamed('/ai_chat'),
        tooltip: 'Chat with Assistant',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    _complaintController.dispose();
    _trackingNumberController.dispose();
    super.dispose();
  }
}
