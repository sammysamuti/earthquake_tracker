import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EarthquakeDetailPage extends StatefulWidget {
  final Map<String, dynamic> earthquake;

  const EarthquakeDetailPage({Key? key, required this.earthquake})
      : super(key: key);

  @override
  _EarthquakeDetailPageState createState() => _EarthquakeDetailPageState();
}

class _EarthquakeDetailPageState extends State<EarthquakeDetailPage> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final doc = await FirebaseFirestore.instance
        .collection('saved_earthquakes')
        .doc(widget.earthquake['id'])
        .get();
    setState(() {
      _isSaved = doc.exists;
    });
  }

  void _toggleSave() async {
    final earthquakeRef = FirebaseFirestore.instance
        .collection('saved_earthquakes')
        .doc(widget.earthquake['id']);

    setState(() {
      _isSaved = !_isSaved;
    });

    if (_isSaved) {
      await earthquakeRef.set({
        'properties': widget.earthquake['properties'],
        'geometry': widget.earthquake['geometry'],
        'savedAt': DateTime.now(),
      });
    } else {
      await earthquakeRef.delete();
    }
  }

  void _shareEarthquake() {
    final properties = widget.earthquake['properties'];
    final String shareText = '''
Earthquake Alert!
Location: ${properties['place']}
Magnitude: ${properties['mag']}
Time: ${DateFormat.yMMMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(properties['time']))}
''';
    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final properties = widget.earthquake['properties'];
    final coordinates = widget.earthquake['geometry']['coordinates'];
    final LatLng location = LatLng(coordinates[1], coordinates[0]);
    final magnitude = properties['mag'].toDouble();
    final Color magnitudeColor = _getMagnitudeColor(magnitude);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: FlutterMap(
                options: MapOptions(
                  initialCenter: location,
                  initialZoom: 8,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.earthquake_trackerr',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: location,
                        child: Icon(
                          Icons.location_on,
                          color: magnitudeColor,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: magnitudeColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Magnitude ${magnitude.toStringAsFixed(1)}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ).animate().slideX(),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(_isSaved
                                ? Icons.bookmark
                                : Icons.bookmark_border),
                            onPressed: _toggleSave,
                          ),
                          IconButton(
                            icon: Icon(Icons.share),
                            onPressed: _shareEarthquake,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    properties['place'] ?? 'Unknown Location',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(),
                  SizedBox(height: 20),
                  _buildInfoCard(
                    'Time',
                    DateFormat.yMMMd().add_jm().format(
                          DateTime.fromMillisecondsSinceEpoch(
                              properties['time']),
                        ),
                    Icons.access_time,
                  ),
                  _buildInfoCard(
                    'Depth',
                    '${coordinates[2].toStringAsFixed(1)} km',
                    Icons.vertical_align_bottom,
                  ),
                  _buildInfoCard(
                    'Status',
                    properties['status'] ?? 'Unknown',
                    Icons.info_outline,
                  ),
                  if (properties['tsunami'] == 1)
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red),
                          SizedBox(width: 10),
                          Text(
                            'Tsunami Warning',
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ).animate().shake(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideX();
  }

  Color _getMagnitudeColor(double magnitude) {
    if (magnitude >= 7.0) return Colors.red;
    if (magnitude >= 5.0) return Colors.orange;
    if (magnitude >= 3.0) return Colors.yellow[700]!;
    return Colors.green;
  }
}
