import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<double> ecgSignal = [];
  List<double> displayedData = [];
  List<double> timestamps = [];
  int currentIndex = 0;
  double timeCounter = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadECGData();
  }

  Future<void> _loadECGData() async {
    try {
      final csvString = await rootBundle.loadString('assets/sample.csv');
      final lines = const LineSplitter().convert(csvString);

      setState(() {
        ecgSignal = lines
            .where((line) => line.trim().isNotEmpty)
            .map((line) => double.tryParse(line.trim()) ?? 0.0)
            .toList();
      });

      _startStreaming();
    } catch (e) {
      print('Error cargando datos: $e');
    }
  }

  void _startStreaming() {
    const sampleRate = 250; // Hz
    final interval = Duration(milliseconds: (1000 / sampleRate).round());

    _timer = Timer.periodic(interval, (timer) {
      if (currentIndex >= ecgSignal.length) {
        timer.cancel();
        return;
      }

      setState(() {
        displayedData.add(ecgSignal[currentIndex]);
        timestamps.add(timeCounter);
        timeCounter += 1 / 250;
        currentIndex++;

        // Mantener solo los últimos 1000 puntos para mejor rendimiento
        if (displayedData.length > 1000) {
          displayedData.removeAt(0);
          timestamps.removeAt(0);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            'ECG en Tiempo Real',
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.blue,
          centerTitle: true,
          elevation: 2,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 300,
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: displayedData.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toStringAsFixed(1),
                                    style: TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toStringAsFixed(1),
                                    style: TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                displayedData.length,
                                (index) => FlSpot(
                                  timestamps[index],
                                  displayedData[index],
                                ),
                              ),
                              isCurved: false,
                              color: Color(0xFF0057B8),
                              barWidth: 2,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    displayedData.isNotEmpty
                        ? 'Muestra actual: ${displayedData.last.toStringAsFixed(2)} mV'
                        : currentIndex >= ecgSignal.length
                            ? 'Señal completada'
                            : 'Cargando datos...',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _timer?.cancel();
                        setState(() {
                          currentIndex = 0;
                          displayedData.clear();
                          timestamps.clear();
                          timeCounter = 0.0;
                        });
                        _startStreaming();
                      },
                      child: Text('Reiniciar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_timer?.isActive ?? false) {
                          _timer?.cancel();
                        } else {
                          _startStreaming();
                        }
                      },
                      child: Text(_timer?.isActive ?? false ? 'Pausar' : 'Continuar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}