import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<Map<String, dynamic>> _monthlyData = [];
  Map<String, int> _magnitudeRanges = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('earthquakes')
          .orderBy('properties.time', descending: true)
          .limit(1000)
          .get();

      _processData(snapshot.docs);
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error fetching statistics: $e');
      setState(() => _isLoading = false);
    }
  }

  void _processData(List<QueryDocumentSnapshot> docs) {
    Map<String, List<double>> monthlyMagnitudes = {};
    _magnitudeRanges = {
      '0-2.9': 0,
      '3-4.9': 0,
      '5-6.9': 0,
      '7+': 0,
    };

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final properties = data['properties'];
      final time = DateTime.fromMillisecondsSinceEpoch(properties['time']);
      final magnitude = properties['mag'].toDouble();
      final monthKey = '${time.year}-${time.month.toString().padLeft(2, '0')}';

      // Monthly data
      if (!monthlyMagnitudes.containsKey(monthKey)) {
        monthlyMagnitudes[monthKey] = [];
      }
      monthlyMagnitudes[monthKey]!.add(magnitude);

      // Magnitude ranges
      if (magnitude < 3.0) {
        _magnitudeRanges['0-2.9'] = (_magnitudeRanges['0-2.9'] ?? 0) + 1;
      } else if (magnitude < 5.0) {
        _magnitudeRanges['3-4.9'] = (_magnitudeRanges['3-4.9'] ?? 0) + 1;
      } else if (magnitude < 7.0) {
        _magnitudeRanges['5-6.9'] = (_magnitudeRanges['5-6.9'] ?? 0) + 1;
      } else {
        _magnitudeRanges['7+'] = (_magnitudeRanges['7+'] ?? 0) + 1;
      }
    }

    _monthlyData = monthlyMagnitudes.entries.map((entry) {
      final magnitudes = entry.value;
      return {
        'month': entry.key,
        'average': magnitudes.reduce((a, b) => a + b) / magnitudes.length,
        'count': magnitudes.length,
      };
    }).toList();

    _monthlyData.sort((a, b) => a['month'].compareTo(b['month']));
  }

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
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Earthquake\nStatistics',
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ).animate().fadeIn().slideX(),
                      SizedBox(height: 30),
                      _buildMagnitudeDistributionCard(),
                      SizedBox(height: 20),
                      _buildMonthlyTrendsCard(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildMagnitudeDistributionCard() {
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Magnitude Distribution',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.7,
              child: PieChart(
                PieChartData(
                  sections: _magnitudeRanges.entries.map((entry) {
                    final double percentage = entry.value /
                        _magnitudeRanges.values
                            .reduce((sum, value) => sum + value) *
                        100;
                    return PieChartSectionData(
                      color: _getMagnitudeRangeColor(entry.key),
                      value: entry.value.toDouble(),
                      title: '${percentage.toStringAsFixed(1)}%',
                      radius: 100,
                      titleStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _magnitudeRanges.entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getMagnitudeRangeColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      '${entry.key}: ${entry.value}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildMonthlyTrendsCard() {
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Trends',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.7,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < _monthlyData.length) {
                            final month =
                                _monthlyData[value.toInt()]['month'].toString();
                            return Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                month.substring(5),
                                style: GoogleFonts.poppins(
                                  color: Colors.white60,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _monthlyData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(),
                            entry.value['average'].toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.white,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY();
  }

  Color _getMagnitudeRangeColor(String range) {
    switch (range) {
      case '0-2.9':
        return Colors.green;
      case '3-4.9':
        return Colors.yellow[700]!;
      case '5-6.9':
        return Colors.orange;
      case '7+':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
