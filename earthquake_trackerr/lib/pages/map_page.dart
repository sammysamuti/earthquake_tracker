import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:earthquake_trackerr/service/earthquake_service.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:earthquake_trackerr/pages/earthquake_detail_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart'; 
class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  double? _latitude;
  double? _longitude;
  String? _timeRange;
  List<dynamic> _earthquakeData = [];
  bool _isLoading = false;

  List<String> _timeRanges = [
    'recent',
    '2 days ago',
    '3 days ago',
    'week',
    'month',
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation(); // Get user location when the page is initialized
  }

  // Get the user's current location
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
      // Ask the user to turn on location if coordinates aren't available
      await _showLocationDialog(true);
      return;
    }

    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  // Show location prompt dialog
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

  // Fetch earthquake data based on time range and location
  Future<void> _fetchEarthquakes() async {
    if (_latitude == null || _longitude == null || _timeRange == null) return;

    setState(() => _isLoading = true);

    try {
    
      final List<dynamic> data = await fetchEarthquakeData(
          _latitude!, _longitude!, _timeRange!); 

      setState(() {
        _earthquakeData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _earthquakeData = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching earthquake data')));
    }
  }


  Future<List<dynamic>> fetchEarthquakeData(
      double latitude, double longitude, String timeRange) async {
   
    await Future.delayed(Duration(seconds: 2)); // Simulating network delay
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
           
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.earthquake_trackerr',
              ),
              MarkerLayer(
                markers: _earthquakeData.map((earthquake) {
                  final coordinates = earthquake['geometry']['coordinates'];
                  final properties = earthquake['properties'];
                  final magnitude = properties['mag'] as double;
                  final location = LatLng(coordinates[1], coordinates[0]);

                  return Marker(
                    point: location,
                    width: 30 + (magnitude * 5),
                    height: 30 + (magnitude * 5),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EarthquakeDetailPage(earthquake: earthquake),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getMagnitudeColor(magnitude).withOpacity(0.5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getMagnitudeColor(magnitude),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            magnitude.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Card(
              elevation: 0,
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Earthquake Map',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _timeRange,
                      items: _timeRanges.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _timeRange = newValue;
                        });
                        _fetchEarthquakes(); 
                      },
                      underline: Container(),
                      style: GoogleFonts.poppins(
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn().slideY(),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          if (_earthquakeData.isEmpty && !_isLoading)
            Center(
              child: Text(
                'Coming soon',
                style: TextStyle(color: const Color.fromARGB(124, 23, 5, 5)),
              ),
            ),
        ],
      ),
    );
  }

  Color _getMagnitudeColor(double magnitude) {
    if (magnitude >= 7.0) return Colors.red;
    if (magnitude >= 5.0) return Colors.orange;
    if (magnitude >= 3.0) return Colors.yellow[700]!;
    return Colors.green;
  }
}
