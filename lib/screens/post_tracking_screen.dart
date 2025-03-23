import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';

class PostTrackingScreen extends StatefulWidget {
  @override
  _PostTrackingScreenState createState() => _PostTrackingScreenState();
}

class _PostTrackingScreenState extends State<PostTrackingScreen> {
  final TextEditingController _trackingNumberController =
      TextEditingController();
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isTracking = false;
  String _trackingStatus = "";
  List<Map<String, dynamic>> _trackingHistory = [];

  // Google Maps API Key
  final String googleMapsApiKey = "AIzaSyB3VwYeAKY6FNM-9YEtk13HiV4vkHIeyyU";

  // Post offices in Hyderabad and Telangana
  final Map<String, LatLng> postOffices = {
    'Hyderabad GPO': LatLng(17.3850, 78.4867),
    'Secunderabad PO': LatLng(17.4399, 78.4983),
    'Warangal Head PO': LatLng(17.9689, 79.5941),
    'Karimnagar Head PO': LatLng(18.4377, 78.8516),
    'Nizamabad Head PO': LatLng(18.6725, 78.0941),
    'Khammam Head PO': LatLng(17.2473, 80.1514),
    'Adilabad Head PO': LatLng(19.6640, 78.5320),
    'Mahbubnagar Head PO': LatLng(16.7488, 77.9879),
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _trackingStatus = "Location permissions are denied";
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _trackingStatus = "Error getting location: $e";
      });
    }
  }

  void _trackPackage() {
    String trackingNumber = _trackingNumberController.text;

    if (trackingNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a tracking number'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ));
      return;
    }

    // Generate random tracking route based on input
    _generateRandomTrackingRoute(trackingNumber);
  }

  void _generateRandomTrackingRoute(String trackingNumber) {
    // Get a deterministic but seemingly random selection of post offices for this tracking number
    int trackingSum =
        trackingNumber.codeUnits.fold(0, (sum, code) => sum + code);
    List<String> postOfficeNames = postOffices.keys.toList();

    // Sort by distance from first post office for consistent routes
    postOfficeNames.sort((a, b) {
      double distA =
          _calculateDistance(postOffices[postOfficeNames[0]]!, postOffices[a]!);
      double distB =
          _calculateDistance(postOffices[postOfficeNames[0]]!, postOffices[b]!);
      return distA.compareTo(distB);
    });

    // Select a subset of post offices based on tracking number
    int officeCount = 3 + (trackingSum % 4); // 3 to 6 post offices
    List<String> selectedOffices = postOfficeNames.take(officeCount).toList();

    // Create path from selected post offices
    List<LatLng> trackingPath =
        selectedOffices.map((name) => postOffices[name]!).toList();

    // Determine the current stage of delivery (how far along the route)
    int progressIndex =
        1 + (trackingSum % (officeCount - 1)); // At least passed first point
    if (progressIndex >= trackingPath.length)
      progressIndex = trackingPath.length - 1;

    // Create tracking history based on selected offices
    List<Map<String, dynamic>> history = [];
    DateTime now = DateTime.now();

    for (int i = 0; i < selectedOffices.length; i++) {
      DateTime eventTime =
          now.subtract(Duration(days: selectedOffices.length - i - 1));
      bool completed = i <= progressIndex;

      // Generate appropriate status based on position in route
      String status = '';
      IconData icon;

      if (i == 0) {
        status = 'Received at Post Office';
        icon = Icons.inventory_2;
      } else if (i == selectedOffices.length - 1) {
        status = completed ? 'Delivered' : 'Pending Delivery';
        icon = completed ? Icons.check_circle : Icons.home;
      } else if (i == progressIndex && !completed) {
        status = 'In Transit';
        icon = Icons.local_shipping;
      } else if (i < selectedOffices.length - 1) {
        status = 'Processed at Sorting Facility';
        icon = Icons.store;
      } else {
        status = 'In Transit';
        icon = Icons.local_shipping;
      }

      history.add({
        'date':
            '${eventTime.year}-${eventTime.month.toString().padLeft(2, '0')}-${eventTime.day.toString().padLeft(2, '0')} ${eventTime.hour.toString().padLeft(2, '0')}:${eventTime.minute.toString().padLeft(2, '0')}',
        'location': selectedOffices[i],
        'status': status,
        'completed': completed,
        'icon': icon,
      });
    }

    // If not complete, add an estimated delivery prediction
    if (progressIndex < selectedOffices.length - 1) {
      DateTime estimatedDelivery = now.add(Duration(days: 1));
      history.add({
        'date':
            'Expected: ${estimatedDelivery.year}-${estimatedDelivery.month.toString().padLeft(2, '0')}-${estimatedDelivery.day.toString().padLeft(2, '0')}',
        'location': 'Destination Address',
        'status': 'Delivery Pending',
        'completed': false,
        'icon': Icons.home,
      });
    }

    setState(() {
      _isTracking = true;
      _trackingStatus = "Package found! Displaying tracking information...";

      // Clear previous markers except current location
      _markers
          .removeWhere((marker) => marker.markerId.value != 'currentLocation');
      _polylines.clear();

      // Add destination marker
      _markers.add(
        Marker(
          markerId: MarkerId('destination'),
          position: trackingPath.last,
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: selectedOffices.last,
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      // Add origin marker
      _markers.add(
        Marker(
          markerId: MarkerId('origin'),
          position: trackingPath.first,
          infoWindow: InfoWindow(
            title: 'Origin',
            snippet: selectedOffices.first,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      // Add tracking points for transit locations
      for (int i = 1; i < trackingPath.length - 1; i++) {
        _markers.add(
          Marker(
            markerId: MarkerId('trackingPoint$i'),
            position: trackingPath[i],
            infoWindow: InfoWindow(
              title: 'Transit Point',
              snippet: selectedOffices[i],
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange),
          ),
        );
      }

      // Add polyline for tracking path
      _polylines.add(
        Polyline(
          polylineId: PolylineId('trackingPath'),
          points: trackingPath,
          color: Colors.deepOrange,
          width: 5,
          patterns: [
            PatternItem.dash(20),
            PatternItem.gap(10),
          ],
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );

      // Current progress polyline
      _polylines.add(
        Polyline(
          polylineId: PolylineId('progressPath'),
          points: trackingPath.sublist(0, progressIndex + 1),
          color: Colors.green,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );

      // Update tracking history
      _trackingHistory = history;

      // Move camera to show the tracking path
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          _boundsFromLatLngList(trackingPath),
          50.0,
        ),
      );
    });
  }

  double _calculateDistance(LatLng start, LatLng end) {
    // Simple Euclidean distance for sorting
    return sqrt((start.latitude - end.latitude) *
            (start.latitude - end.latitude) +
        (start.longitude - end.longitude) * (start.longitude - end.longitude));
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
        northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post Tracking',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              gradient: LinearGradient(
                colors: [Colors.deepOrange.shade400, Colors.orange.shade300],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                )
              ],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Track Your Package',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Enter your tracking number to get real-time updates',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _trackingNumberController,
                          decoration: InputDecoration(
                            labelText: 'Enter Tracking Number',
                            hintText: 'e.g., HYD1234567890',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            prefixIcon:
                                Icon(Icons.search, color: Colors.deepOrange),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.deepOrange, Colors.orange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ElevatedButton(
                          onPressed: _trackPackage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'Track',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_trackingStatus.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                _trackingStatus,
                style: GoogleFonts.poppins(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Expanded(
            child: _isTracking
                ? Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Card
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
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 30,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Package #HYD5678901',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'In Transit - On Schedule',
                                      style: GoogleFonts.poppins(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Expected Delivery: Oct 24, 2023',
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
                        ),
                        SizedBox(height: 16),

                        // Map Card
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: [
                                GoogleMap(
                                  mapType: MapType.normal,
                                  initialCameraPosition: CameraPosition(
                                    target: _currentPosition ??
                                        LatLng(17.3850,
                                            78.4867), // Hyderabad by default
                                    zoom: 10,
                                  ),
                                  markers: _markers,
                                  polylines: _polylines,
                                  myLocationEnabled: true,
                                  myLocationButtonEnabled: false,
                                  onMapCreated: (controller) {
                                    _mapController = controller;
                                    _mapController?.setMapStyle('''
                                    [
                                      {
                                        "featureType": "administrative",
                                        "elementType": "geometry",
                                        "stylers": [
                                          {
                                            "visibility": "off"
                                          }
                                        ]
                                      },
                                      {
                                        "featureType": "poi",
                                        "stylers": [
                                          {
                                            "visibility": "off"
                                          }
                                        ]
                                      },
                                      {
                                        "featureType": "road",
                                        "elementType": "labels.icon",
                                        "stylers": [
                                          {
                                            "visibility": "off"
                                          }
                                        ]
                                      },
                                      {
                                        "featureType": "transit",
                                        "stylers": [
                                          {
                                            "visibility": "off"
                                          }
                                        ]
                                      }
                                    ]
                                    ''');
                                  },
                                ),
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.my_location),
                                      onPressed: () {
                                        if (_currentPosition != null) {
                                          _mapController?.animateCamera(
                                            CameraUpdate.newLatLngZoom(
                                                _currentPosition!, 14),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Tracking History
                        Expanded(
                          flex: 3,
                          child: Container(
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
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'Tracking History',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _trackingHistory.length,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    itemBuilder: (context, index) {
                                      final historyItem =
                                          _trackingHistory[index];
                                      final bool isLast =
                                          index == _trackingHistory.length - 1;

                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            children: [
                                              Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color:
                                                      historyItem['completed']
                                                          ? Colors.green
                                                          : Colors
                                                              .grey.shade300,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    historyItem['icon']
                                                            as IconData? ??
                                                        Icons.check,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                              if (!isLast)
                                                Container(
                                                  width: 2,
                                                  height: 50,
                                                  color:
                                                      historyItem['completed']
                                                          ? Colors.green
                                                          : Colors
                                                              .grey.shade300,
                                                ),
                                            ],
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  bottom: isLast ? 0 : 16),
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: historyItem['completed']
                                                    ? Colors.green
                                                        .withOpacity(0.1)
                                                    : Colors.grey
                                                        .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    historyItem['status']
                                                        .toString(),
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: historyItem[
                                                              'completed']
                                                          ? Colors
                                                              .green.shade700
                                                          : Colors
                                                              .grey.shade700,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    historyItem['location']
                                                        .toString(),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    historyItem['date']
                                                        .toString(),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          size: 80,
                          color: Colors.orange.withOpacity(0.5),
                        ),
                        SizedBox(height: 24),
                        Text(
                          'Enter a tracking number to start',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'You will see tracking details once you submit a valid tracking number',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
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
                color: Colors.grey,
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/home'),
                tooltip: 'Home',
              ),
              IconButton(
                icon: Icon(Icons.track_changes),
                color: Colors.deepOrange,
                onPressed: () {},
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
}
