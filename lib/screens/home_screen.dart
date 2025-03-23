import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'India Post Services',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () => Navigator.of(context).pushNamed('/ai_chat'),
            tooltip: 'AI Assistant',
          ),
          IconButton(
            icon: Icon(Icons.dashboard),
            onPressed: () => Navigator.of(context).pushNamed('/dashboard'),
            tooltip: 'Dashboard',
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: Column(
        children: [
          // Hero Banner
          Container(
            height: 160,
            width: double.infinity,
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.deepOrange.shade400, Colors.orange.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(16),
                    ),
                    child: Image.network(
                      'https://www.indiapost.gov.in/VAS/PublishingImages/speed-post-banner.png',
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return SizedBox(
                          height: 120,
                          width: 120,
                          child: Icon(Icons.local_shipping,
                              size: 60, color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        'India Post',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 180,
                        child: Text(
                          'Track, manage, and send posts with ease',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Services Label
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Our Services',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Divider(thickness: 1),
                ),
              ],
            ),
          ),

          // Services Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.track_changes,
                  label: 'Post Tracking',
                  description: 'Track your shipments',
                  color: Colors.blue,
                  onTap: () => Navigator.of(context).pushNamed('/tracking'),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.report_problem,
                  label: 'Raise Complaint',
                  description: 'Issues with delivery',
                  color: Colors.red,
                  onTap: () => Navigator.of(context).pushNamed('/complaint'),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.location_city,
                  label: 'Branch Locator',
                  description: 'Find nearest post office',
                  color: Colors.green,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Branch locator coming soon!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.local_post_office,
                  label: 'Postal Services',
                  description: 'Mail, parcels, and more',
                  color: Colors.purple,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Service details coming soon!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.support_agent,
                  label: 'AI Assistant',
                  description: 'Get help and answers',
                  color: Colors.deepOrange,
                  onTap: () => Navigator.of(context).pushNamed('/ai_chat'),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.calculate,
                  label: 'Postage Calculator',
                  description: 'Calculate shipping costs',
                  color: Colors.teal,
                  onTap: () {
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
        ],
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
                color: Colors.deepOrange,
                onPressed: () {},
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

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
