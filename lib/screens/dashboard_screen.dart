import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int totalPosts = 0;
  int deliveredPosts = 0;
  int inTransitPosts = 0;
  int pendingComplaints = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // For demo purposes, setting static values
      // In a real app, you would fetch this from Firestore
      setState(() {
        totalPosts = 156;
        deliveredPosts = 98;
        inTransitPosts = 58;
        pendingComplaints = 12;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Notifications coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient
              Container(
                padding: EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 35,
                            color: Colors.deepOrange,
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back,',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            Text(
                              'Yash Kumar',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Active Trackings',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$inTransitPosts Active',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: deliveredPosts / totalPosts,
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.green),
                            borderRadius: BorderRadius.circular(10),
                            minHeight: 10,
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Delivered: $deliveredPosts',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                'Total: $totalPosts',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Statistics',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Statistics Cards
                    _buildStatsGrid(),

                    SizedBox(height: 24),

                    // Recent Activity Header with See All button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activities',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Show all activities
                          },
                          child: Text(
                            'See All',
                            style: GoogleFonts.poppins(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Enhanced Activity List
                    _buildRecentActivityList(),

                    SizedBox(height: 24),

                    // Shipment Analytics
                    Container(
                      padding: EdgeInsets.all(20),
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
                            'Shipment Analytics',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: CircularProgressIndicator(
                                            value: 0.63,
                                            strokeWidth: 10,
                                            backgroundColor:
                                                Colors.grey.withOpacity(0.2),
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.green),
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              '63%',
                                              style: GoogleFonts.poppins(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'On Time',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Delivery Rate',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '98 of 156 items',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: CircularProgressIndicator(
                                            value: 0.87,
                                            strokeWidth: 10,
                                            backgroundColor:
                                                Colors.grey.withOpacity(0.2),
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.blue),
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              '87%',
                                              style: GoogleFonts.poppins(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Success',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Satisfaction',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '136 positive reviews',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Post Categories',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildCategoriesPieChart(),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Add Regional Statistics Container
                    Container(
                      padding: EdgeInsets.all(20),
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
                            'Telangana Regional Activity',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            height: 200,
                            child: _buildRegionalBarGraph(),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Regional distribution of your packages in Telangana',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Quick Actions with enhanced UI
                    Text(
                      'Quick Actions',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildQuickActions(),
                  ],
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
                color: Colors.deepOrange,
                onPressed: () {},
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

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Total Posts',
          totalPosts.toString(),
          Icons.mail,
          Colors.blue,
        ),
        _buildStatCard(
          'Delivered',
          deliveredPosts.toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'In Transit',
          inTransitPosts.toString(),
          Icons.local_shipping,
          Colors.orange,
        ),
        _buildStatCard(
          'Pending Complaints',
          pendingComplaints.toString(),
          Icons.report_problem,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
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
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            Spacer(),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityList() {
    final List<Map<String, dynamic>> activities = [
      {
        'title': 'Package Delivered',
        'description': 'Your package #HYD5678901 was delivered to Secunderabad',
        'time': '2 hours ago',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'title': 'New Shipment',
        'description':
            'Registered parcel #HYD2398765 is in transit to Warangal',
        'time': '5 hours ago',
        'icon': Icons.local_shipping,
        'color': Colors.blue,
      },
      {
        'title': 'Complaint Resolved',
        'description':
            'Your complaint #C4567 about Hyderabad delivery has been resolved',
        'time': '1 day ago',
        'icon': Icons.report_problem,
        'color': Colors.orange,
      },
      {
        'title': 'Money Order Processed',
        'description': 'Money order #MO789123 to Karimnagar has been processed',
        'time': '2 days ago',
        'icon': Icons.payments,
        'color': Colors.purple,
      },
      {
        'title': 'Package Picked Up',
        'description': 'Package #HYD9871234 was picked up from Gachibowli',
        'time': '3 days ago',
        'icon': Icons.inventory_2,
        'color': Colors.teal,
      },
      {
        'title': 'Delivery Attempted',
        'description':
            'Package #HYD3456789 delivery was attempted in Kukatpally',
        'time': '4 days ago',
        'icon': Icons.delivery_dining,
        'color': Colors.amber,
      },
      {
        'title': 'Express Mail Received',
        'description':
            'Express package #HYD6789012 has been received at Hyderabad Airport',
        'time': '5 days ago',
        'icon': Icons.send,
        'color': Colors.indigo,
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
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
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: activity['color'].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                activity['icon'],
                color: activity['color'],
              ),
            ),
            title: Text(
              activity['title'],
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['description'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  activity['time'],
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to details
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Activity details coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Container(
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
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildActionButton(
              'Track a Package',
              'Enter tracking number to find your package',
              Icons.search,
              Colors.deepOrange,
              () => Navigator.of(context).pushNamed('/tracking'),
            ),
            Divider(),
            _buildActionButton(
              'File a Complaint',
              'Report issues with your delivery',
              Icons.report_problem,
              Colors.red,
              () => Navigator.of(context).pushNamed('/complaint'),
            ),
            Divider(),
            _buildActionButton(
              'Find Post Office',
              'Locate nearest post office in Hyderabad',
              Icons.location_on,
              Colors.blue,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Post Office locator coming soon!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            Divider(),
            _buildActionButton(
              'Calculate Postage',
              'Estimate shipping costs',
              Icons.calculate,
              Colors.green,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Postage calculator coming soon!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_forward,
          color: color,
          size: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildCategoriesPieChart() {
    final List<Map<String, dynamic>> categories = [
      {'name': 'Regular', 'percentage': 45, 'color': Colors.blue},
      {'name': 'Express', 'percentage': 30, 'color': Colors.deepOrange},
      {'name': 'Registered', 'percentage': 15, 'color': Colors.green},
      {'name': 'International', 'percentage': 10, 'color': Colors.purple},
    ];

    return Row(
      children: [
        // Pie chart representation
        Container(
          width: 120,
          height: 120,
          child: CustomPaint(
            painter: PieChartPainter(categories),
          ),
        ),
        SizedBox(width: 16),
        // Legend
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categories.map((category) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: category['color'],
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${category['percentage']}%',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRegionalBarGraph() {
    final List<Map<String, dynamic>> regionalData = [
      {'region': 'Hyderabad', 'count': 48},
      {'region': 'Warangal', 'count': 32},
      {'region': 'Karimnagar', 'count': 24},
      {'region': 'Nizamabad', 'count': 20},
      {'region': 'Khammam', 'count': 18},
      {'region': 'Adilabad', 'count': 14},
    ];

    // Maximum count for scaling
    final int maxCount = regionalData
        .map<int>((data) => data['count'] as int)
        .reduce((a, b) => a > b ? a : b);

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: regionalData.length,
      itemBuilder: (context, index) {
        final item = regionalData[index];
        final double percentage = (item['count'] as int) / maxCount;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                      width: 80,
                      child: Text(item['region'],
                          style: GoogleFonts.poppins(fontSize: 12))),
                  SizedBox(width: 8),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: percentage,
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.deepOrange,
                                  Colors.orange.shade300
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                      width: 30,
                      child: Text('${item['count']}',
                          style: GoogleFonts.poppins(
                              fontSize: 12, fontWeight: FontWeight.w600))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> categories;

  PieChartPainter(this.categories);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    var startAngle = -90 * (3.14159 / 180); // Start from top (in radians)

    for (var category in categories) {
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = category['color'];

      final sweepAngle = (category['percentage'] / 100) * 2 * 3.14159;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Draw a white circle in the center for a donut chart effect
    final centerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    canvas.drawCircle(center, radius * 0.5, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
