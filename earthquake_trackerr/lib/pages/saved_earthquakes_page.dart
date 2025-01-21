import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'earthquake_detail_page.dart';

class SavedEarthquakesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Saved\nEarthquakes',
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ).animate().fadeIn().slideX(),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('saved_earthquakes')
                      .orderBy('savedAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: TextStyle(color: Colors.white)),
                      );
                    }

                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    final earthquakes = snapshot.data!.docs;

                    if (earthquakes.isEmpty) {
                      return Center(
                        child: Text(
                          'No saved earthquakes',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemCount: earthquakes.length,
                      itemBuilder: (context, index) {
                        final earthquake =
                            earthquakes[index].data() as Map<String, dynamic>;
                        final properties = earthquake['properties'];
                        final magnitude = properties['mag'].toDouble();

                        return Card(
                          margin: EdgeInsets.only(bottom: 15),
                          elevation: 0,
                          color: Colors.white.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(15),
                            title: Text(
                              properties['place'] ?? 'Unknown Location',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Magnitude: ${magnitude.toStringAsFixed(1)}',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                              ),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios,
                                color: Colors.white70),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EarthquakeDetailPage(
                                    earthquake: {
                                      ...earthquake,
                                      'id': earthquakes[index].id,
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ).animate().fadeIn().slideX();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
