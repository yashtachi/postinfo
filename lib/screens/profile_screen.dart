import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  // User profile data
  String _userName = 'Yash Kumar';
  String _userEmail = 'yash.kumar@example.com';
  String _userPhone = '+91 98765 43210';
  String _userAddress = '456 Jubilee Hills, Hyderabad, Telangana';
  String _userProfilePic = '';
  bool _isLoading = true;
  bool _isEditing = false;

  // Controllers for editable fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // In a real app, fetch from Firestore
        // For demo, we'll simulate a delay and use temporary data
        await Future.delayed(Duration(milliseconds: 800));

        // Try to get user data from Firestore if it exists
        try {
          DocumentSnapshot userDoc =
              await _firestore.collection('users').doc(currentUser.uid).get();

          if (userDoc.exists) {
            Map<String, dynamic> userData =
                userDoc.data() as Map<String, dynamic>;
            setState(() {
              _userName = userData['name'] ?? 'Yash Kumar';
              _userEmail = userData['email'] ??
                  currentUser.email ??
                  'yash.kumar@example.com';
              _userPhone = userData['phone'] ?? '+91 98765 43210';
              _userAddress = userData['address'] ??
                  '456 Jubilee Hills, Hyderabad, Telangana';
              _userProfilePic = userData['profilePic'] ?? '';
            });
          } else {
            // Create a new user document if it doesn't exist
            await _firestore.collection('users').doc(currentUser.uid).set({
              'name': _userName,
              'email': currentUser.email ?? _userEmail,
              'phone': _userPhone,
              'address': _userAddress,
              'profilePic': _userProfilePic,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        } catch (e) {
          print('Error accessing Firestore: $e');
          // Continue with default data
        }

        // Set up controllers with current values
        _nameController.text = _userName;
        _phoneController.text = _userPhone;
        _addressController.text = _userAddress;
      }
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Update local state
        setState(() {
          _userName = _nameController.text;
          _userPhone = _phoneController.text;
          _userAddress = _addressController.text;
        });

        // Update Firestore
        await _firestore.collection('users').doc(currentUser.uid).update({
          'name': _userName,
          'phone': _userPhone,
          'address': _userAddress,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));
      }
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error updating profile: $e'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      setState(() {
        _isLoading = false;
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          _isEditing
              ? TextButton(
                  onPressed: _saveProfile,
                  child: Text(
                    'Save',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.deepOrange,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header with profile image
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepOrange.shade400,
                          Colors.orange.shade300
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white,
                                backgroundImage: _userProfilePic.isNotEmpty
                                    ? NetworkImage(_userProfilePic)
                                    : null,
                                child: _userProfilePic.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.deepOrange.shade300,
                                      )
                                    : null,
                              ),
                              if (_isEditing)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            _isEditing ? 'Edit your profile' : _userName,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (!_isEditing)
                            Text(
                              _userEmail,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Profile details form
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Information',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),

                          // Name field
                          _buildProfileField(
                            label: 'Full Name',
                            value: _userName,
                            controller: _nameController,
                            icon: Icons.person,
                            isEditing: _isEditing,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),

                          // Email field (non-editable)
                          _buildProfileField(
                            label: 'Email',
                            value: _userEmail,
                            icon: Icons.email,
                            isEditing: false, // Email is never editable
                          ),
                          SizedBox(height: 16),

                          // Phone field
                          _buildProfileField(
                            label: 'Phone Number',
                            value: _userPhone,
                            controller: _phoneController,
                            icon: Icons.phone,
                            isEditing: _isEditing,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),

                          // Address field
                          _buildProfileField(
                            label: 'Address',
                            value: _userAddress,
                            controller: _addressController,
                            icon: Icons.location_on,
                            isEditing: _isEditing,
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your address';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 32),

                          // Account statistics
                          Text(
                            'Account Statistics',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),

                          _buildStatisticTile(
                            title: 'Total Shipments',
                            value: '42',
                            icon: Icons.local_shipping,
                            color: Colors.blue,
                          ),
                          _buildStatisticTile(
                            title: 'Active Trackings',
                            value: '7',
                            icon: Icons.track_changes,
                            color: Colors.orange,
                          ),
                          _buildStatisticTile(
                            title: 'Delivered Packages',
                            value: '35',
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                          _buildStatisticTile(
                            title: 'Filed Complaints',
                            value: '3',
                            icon: Icons.report_problem,
                            color: Colors.red,
                          ),

                          SizedBox(height: 24),

                          // Add Shipment Graph
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Monthly Shipment Activity',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Container(
                                  height: 180,
                                  child: _buildShipmentGraph(),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24),

                          // Post History
                          Text(
                            'Recent Posts History',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),

                          _buildPostHistoryTile(
                            trackingNumber: 'HYD87651234',
                            date: 'June 15, 2023',
                            destination: 'Secunderabad, Telangana',
                            status: 'Delivered',
                            color: Colors.green,
                          ),
                          _buildPostHistoryTile(
                            trackingNumber: 'HYD54327890',
                            date: 'July 22, 2023',
                            destination: 'Warangal, Telangana',
                            status: 'Delivered',
                            color: Colors.green,
                          ),
                          _buildPostHistoryTile(
                            trackingNumber: 'HYD98765432',
                            date: 'August 10, 2023',
                            destination: 'Karimnagar, Telangana',
                            status: 'Delivered',
                            color: Colors.green,
                          ),
                          _buildPostHistoryTile(
                            trackingNumber: 'HYD23456789',
                            date: 'September 5, 2023',
                            destination: 'Gachibowli, Hyderabad',
                            status: 'In Transit',
                            color: Colors.orange,
                          ),
                          _buildPostHistoryTile(
                            trackingNumber: 'HYD34567890',
                            date: 'September 18, 2023',
                            destination: 'Kukatpally, Hyderabad',
                            status: 'Processing',
                            color: Colors.blue,
                          ),

                          SizedBox(height: 24),

                          // Logout button
                          Container(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                Navigator.of(context)
                                    .pushReplacementNamed('/login');
                              },
                              icon: Icon(Icons.logout),
                              label: Text(
                                'Logout',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.black87,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                color: Colors.deepOrange,
                onPressed: () {},
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

  Widget _buildProfileField({
    required String label,
    required String value,
    TextEditingController? controller,
    required IconData icon,
    required bool isEditing,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: isEditing
          ? TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon, color: Colors.deepOrange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              maxLines: maxLines,
              validator: validator,
            )
          : ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.deepOrange,
                ),
              ),
              title: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              subtitle: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
    );
  }

  Widget _buildStatisticTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostHistoryTile({
    required String trackingNumber,
    required String date,
    required String destination,
    required String status,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.inventory_2,
            color: color,
          ),
        ),
        title: Text(
          'Package #$trackingNumber',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          date,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: color,
            ),
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPostDetailRow('Destination', destination),
                _buildPostDetailRow('Type', 'Regular Parcel'),
                _buildPostDetailRow('Weight', '1.2 kg'),
                SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/tracking');
                  },
                  child: Text(
                    'Track Again',
                    style: GoogleFonts.poppins(
                      color: Colors.deepOrange,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.deepOrange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentGraph() {
    // Months and their shipment counts
    final List<Map<String, dynamic>> monthlyData = [
      {'month': 'Apr', 'count': 3},
      {'month': 'May', 'count': 5},
      {'month': 'Jun', 'count': 4},
      {'month': 'Jul', 'count': 7},
      {'month': 'Aug', 'count': 9},
      {'month': 'Sep', 'count': 14},
    ];

    // Maximum count for scaling
    final int maxCount = monthlyData
        .map<int>((data) => data['count'] as int)
        .reduce((a, b) => a > b ? a : b);

    return Row(
      children: [
        // Y-axis labels
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('$maxCount',
                style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            Text('${(maxCount / 2).round()}',
                style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            Text('0', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
        SizedBox(width: 8),
        // Graph bars
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: monthlyData.map((data) {
              final double barHeight = (data['count'] as int) / maxCount * 140;
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 24,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withOpacity(0.7),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(4)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.deepOrange,
                          Colors.orange.shade300,
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    data['month'],
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
