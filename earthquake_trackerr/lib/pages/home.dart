import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:earthquake_trackerr/service/earthquake_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:earthquake_trackerr/pages/earthquake_detail_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  double? _latitude;
  double? _longitude;
  String? _timeRange;
  String? _fcmToken;
  List<dynamic> _earthquakeData = [];
  bool _isLoading = false;

  List<String> _timeRanges = [
    'recent',
    '2 days ago',
    '3 days ago',
    'week',
    'month'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addObserver(this); // Adding observer to detect app lifecycle changes
    _initializeData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Cleaning up observer
    super.dispose();
  }

  // Handling app lifecycle state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _getUserLocation(); // Rechecking location when the app is resumed
    }
  }

  Future<void> _initializeData() async {
    await _getUserLocation();
    await _getFCMToken();
  }

  // to get the user's current location
  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Prompt user to enable location services
      await _showLocationDialog();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position? position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (position == null) {
      // Asking the user to turn on location if coordinates aren't available
      await _showLocationDialog(true);
      return;
    }

    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  // to show location prompt dialog
  Future<void> _showLocationDialog([bool isLocationMissing = false]) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isLocationMissing
              ? "Location is unavailable"
              : "Location services are off"),
          content: Text(isLocationMissing
              ? "Please enable location services in your device settings."
              : "Please enable location services to proceed."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isLocationMissing) {
                  _openLocationSettings();
                }
              },
              child: Text(isLocationMissing ? "Open Settings" : "OK"),
            ),
          ],
        );
      },
    );
  }

  // Open location settings
  Future<void> _openLocationSettings() async {
    final Uri locationSettingsUri = Uri.parse('app-settings:');
    if (await canLaunch(locationSettingsUri.toString())) {
      await launch(locationSettingsUri.toString());
    } else {
      print("Could not open location settings.");
    }
  }

  // Get the FCM token
  Future<void> _getFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    setState(() {
      _fcmToken = token;
    });
  }

  // Handle form submission
  void _sendUserData() async {
    if (_latitude != null &&
        _longitude != null &&
        _timeRange != null &&
        _fcmToken != null) {
      setState(() => _isLoading = true);

      try {
        String responseBody = await sendUserData(
            _latitude!, _longitude!, _timeRange!, _fcmToken!);

        if (responseBody.isNotEmpty) {
          final Map<String, dynamic> data = json.decode(responseBody);
          if (data['success'] == true) {
            setState(() {
              _earthquakeData = data['earthquakeData'] ?? [];
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching earthquake data')));
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please fill in all fields.')));
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // Set the background to white
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Text(
                  'Earthquake\nTracker',
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900, // Updated text color
                    height: 1.2,
                  ),
                ).animate().fadeIn().slideX(),
                SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.9), // Slight opacity to blend
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        color: Colors.blue.shade900, width: 1), // Border color
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _timeRange,
                      hint: Text('Select Time Range',
                          style: TextStyle(color: Colors.blue.shade900)),
                      dropdownColor: Colors.white,
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down,
                          color: Colors.blue.shade900),
                      style:
                          TextStyle(color: Colors.blue.shade900, fontSize: 16),
                      onChanged: (newValue) {
                        setState(() => _timeRange = newValue);
                      },
                      items: _timeRanges.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ).animate().fadeIn().slideY(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendUserData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900, // Button color
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('Search Earthquakes',
                          style: GoogleFonts.poppins(fontSize: 16)),
                ).animate().fadeIn().slideY(),
                SizedBox(height: 30),
                Expanded(
                  child: _earthquakeData.isEmpty
                      ? Center(
                          child: Text(
                            'No earthquake data available',
                            style: TextStyle(color: Colors.blue.shade900),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _earthquakeData.length,
                          itemBuilder: (context, index) {
                            final earthquake = _earthquakeData[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 15),
                              elevation: 0, // No shadow
                              color:
                                  Colors.white, // Set card background to white
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(15),
                                title: Text(
                                  earthquake['properties']['title'],
                                  style: TextStyle(
                                    color: Colors
                                        .blue.shade900, // Updated text color
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Magnitude: ${earthquake['properties']['mag']}',
                                  style: TextStyle(color: Colors.blue.shade700),
                                ),
                                trailing: Icon(Icons.arrow_forward_ios,
                                    color: Colors.blue.shade700),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EarthquakeDetailPage(
                                        earthquake: earthquake,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ).animate().fadeIn().slideX();
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
