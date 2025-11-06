import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class MarketAnalysisScreen extends StatefulWidget {
  const MarketAnalysisScreen({super.key});

  @override
  State<MarketAnalysisScreen> createState() => _MarketAnalysisScreenState();
}

class _MarketAnalysisScreenState extends State<MarketAnalysisScreen> {
  final List<double> _marketData = [];
  String _prediction = 'Analizando...';
  bool _showPrediction = false;
  late Timer _timer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateInitialMarketData();
    _startMarketSimulation();
  }

  void _generateInitialMarketData() {
    for (int i = 0; i < 50; i++) {
      _marketData.add(_random.nextDouble() * 100 + 50);
    }
  }

  void _startMarketSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateMarketData();
      _makePrediction();
    });
  }

  void _updateMarketData() {
    setState(() {
      final lastValue = _marketData.last;
      double change = (_random.nextDouble() * 2 - 1) * 5; // Fluctuación
      double newValue = lastValue + change;
      if (newValue < 10) newValue = 10;
      if (newValue > 190) newValue = 190;

      _marketData.add(newValue);
      if (_marketData.length > 50) {
        _marketData.removeAt(0);
      }
    });
  }

  void _makePrediction() {
    setState(() {
      // Lógica de predicción simulada
      final lastValue = _marketData.last;
      final previousValue = _marketData[_marketData.length - 2];
      if (lastValue > previousValue) {
        _prediction = 'SUBE ⬆';
      } else {
        _prediction = 'BAJA ⬇';
      }
      _showPrediction = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showPrediction = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis de Mercado Quotex'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1e222d),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: _marketData.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : CustomPaint(
                      painter: MarketChartPainter(_marketData),
                      size: Size.infinite,
                    ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildPredictionAndControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionAndControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        AnimatedOpacity(
          opacity: _showPrediction ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              color: _prediction.contains('SUBE') ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: _prediction.contains('SUBE') ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: Text(
              _prediction,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _prediction.contains('SUBE') ? Colors.green : Colors.red,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTradeButton('SUBE', Icons.arrow_upward, Colors.green),
            _buildTradeButton('BAJA', Icons.arrow_downward, Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildTradeButton(String text, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {
        // Lógica para ejecutar la operación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Operación "$text" ejecutada.'),
            backgroundColor: color,
          ),
        );
      },
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 8,
      ),
    );
  }
}

class MarketChartPainter extends CustomPainter {
  final List<double> data;
  MarketChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double width = size.width;
    final double height = size.height;
    final double dx = width / (data.length - 1);

    final double minData = data.reduce(min);
    final double maxData = data.reduce(max);
    final double dataRange = maxData - minData;

    final Path path = Path();
    path.moveTo(0, height - ((data[0] - minData) / dataRange * height));

    for (int i = 1; i < data.length; i++) {
      path.lineTo(i * dx, height - ((data[i] - minData) / dataRange * height));
    }

    final Paint paint = Paint()
      ..color = data.last > data.first ? Colors.green : Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawPath(path, paint);

    // Dibuja un círculo en el último punto
    final Paint circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset((data.length - 1) * dx, height - ((data.last - minData) / dataRange * height)),
      5,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
