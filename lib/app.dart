import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(const ECGApp());

class ECGApp extends StatelessWidget {
  const ECGApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ECG App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const UserFormScreen(),
    );
  }
}

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  int age = 0;
  bool hasHeartDisease = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Datos del usuario')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                onSaved: (value) => name = value ?? '',
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingresa tu nombre' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
                onSaved: (value) => age = int.tryParse(value ?? '0') ?? 0,
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingresa tu edad' : null,
              ),
              SwitchListTile(
                title: const Text('¿Tienes enfermedad cardíaca?'),
                value: hasHeartDisease,
                onChanged: (value) {
                  setState(() {
                    hasHeartDisease = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Ver ECG'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ECGScreen(
                          name: name,
                          age: age,
                          hasHeartDisease: hasHeartDisease,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ECGScreen extends StatelessWidget {
  final String name;
  final int age;
  final bool hasHeartDisease;

  const ECGScreen({
    super.key,
    required this.name,
    required this.age,
    required this.hasHeartDisease,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultados ECG')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Paciente: $name, Edad: $age'),
            Text('Enfermedad cardíaca: ${hasHeartDisease ? 'Sí' : 'No'}'),
            const SizedBox(height: 24),
            const Text('Simulación de ECG', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateMockECG(),
                      isCurved: true,
                      barWidth: 2,
                      color: Colors.red,
                      dotData: FlDotData(show: false),
                    )
                  ],
                  titlesData: FlTitlesData(show: false),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateMockECG() {
    final points = <FlSpot>[];
    for (double x = 0; x < 6.28; x += 0.1) {
      double y = (x * 2).sin() + 0.2 * (x * 10).sin(); // simulación de ECG
      points.add(FlSpot(x, y));
    }
    return points;
  }
}
