import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  static String routeName = 'HomePage';
  static String routePath = '/homePage';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
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
    final csvString = await rootBundle.loadString('assets/sample.csv');
    final lines = const LineSplitter().convert(csvString);

    setState(() {
      ecgSignal = lines.map((line) => double.tryParse(line) ?? 0.0).toList();
    });

    _startStreaming();
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          title: Text(
            'ECG en Tiempo Real',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(),
                  color: Colors.white,
                  fontSize: 22,
                ),
          ),
          backgroundColor: FlutterFlowTheme.of(context).primary,
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 250,
                padding: EdgeInsets.all(16),
                child: FlutterFlowLineChart(
                  data: [
                    FFLineChartData(
                      xData: timestamps,
                      yData: displayedData,
                      settings: LineChartBarData(
                        color: Color(0xFF0057B8),
                        barWidth: 2,
                        isCurved: false,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    )
                  ],
                  chartStylingInfo: ChartStylingInfo(
                    backgroundColor: FlutterFlowTheme.of(context)
                        .secondaryBackground,
                    showGrid: true,
                    showBorder: false,
                  ),
                  axisBounds: AxisBounds(),
                  xAxisLabelInfo: AxisLabelInfo(
                    reservedSize: 32,
                    labelTextStyle: TextStyle(fontSize: 10),
                  ),
                  yAxisLabelInfo: AxisLabelInfo(
                    reservedSize: 40,
                    labelTextStyle: TextStyle(fontSize: 10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  currentIndex < ecgSignal.length
                      ? 'Muestra: ${displayedData.last.toStringAsFixed(2)} mV'
                      : 'Señal completada',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        fontSize: 18,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}