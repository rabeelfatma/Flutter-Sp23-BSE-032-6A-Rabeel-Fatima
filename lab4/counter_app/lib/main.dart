import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const CounterApp());
}

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter App',
      theme: ThemeData.dark(),
      home: const CounterHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CounterHome extends StatefulWidget {
  const CounterHome({super.key});

  @override
  State<CounterHome> createState() => _CounterHomeState();
}

class _CounterHomeState extends State<CounterHome>
    with SingleTickerProviderStateMixin {
  double _counter = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🔹 Existing functions
  void _increment() => setState(() => _counter++);
  void _decrement() => setState(() => _counter--);
  void _reset() => setState(() => _counter = 0);
  void _delete() => setState(() => _counter = 0);
  void _update() => setState(() => _counter = 10);
  void _square() => setState(() => _counter = _counter * _counter);
  void _squareRoot() =>
      setState(() => _counter >= 0 ? _counter = sqrt(_counter) : _counter);
  void _cubeRoot() =>
      setState(() => _counter = pow(_counter, 1 / 3).toDouble());

  // 🔹 New functions
  void _random() =>
      setState(() => _counter = Random().nextInt(100).toDouble());

  void _halfValue() => setState(() => _counter = _counter / 2);

  void _absolute() => setState(() => _counter = _counter.abs());

  void _factorial() {
    setState(() {
      int n = _counter.floor();
      if (n < 0) {
        _counter = double.nan;
      } else {
        int result = 1;
        for (int i = 1; i <= n; i++) {
          result *= i;
        }
        _counter = result.toDouble();
      }
    });
  }

  void _logarithm() {
    setState(() {
      if (_counter > 0) {
        _counter = log(_counter);
      }
    });
  }

  void _antilog() {
    setState(() {
      _counter = exp(_counter); // e^counter
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("✨ Counter App"),
        centerTitle: true,
        backgroundColor: Colors.black87,
      ),
      body: Stack(
        children: [
          // 🔹 Animated Stylish Background
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: BubbleBackground(_controller.value),
                child: Container(),
              );
            },
          ),

          // 🔹 Counter UI
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Counter Value:",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.blueAccent, blurRadius: 12)],
                  ),
                ),
                Text(
                  _counter.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 65,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyanAccent,
                    shadows: [
                      Shadow(color: Colors.black, blurRadius: 10),
                      Shadow(color: Colors.cyan, blurRadius: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildButton("Increment", Colors.greenAccent, _increment),
                    _buildButton("Decrement", Colors.redAccent, _decrement),
                    _buildButton("Reset", Colors.blueAccent, _reset),
                    _buildButton("Delete", Colors.orangeAccent, _delete),
                    _buildButton("Update to 10", Colors.purpleAccent, _update),
                    _buildButton("Square", Colors.tealAccent, _square),
                    _buildButton("Square Root", Colors.pinkAccent, _squareRoot),
                    _buildButton("Cube Root", Colors.yellowAccent, _cubeRoot),
                    _buildButton("Random", Colors.lightBlueAccent, _random),
                    _buildButton("Half", Colors.amberAccent, _halfValue),
                    _buildButton("Absolute", Colors.white70, _absolute),
                    _buildButton("Factorial", Colors.deepOrangeAccent, _factorial),
                    _buildButton("Logarithm", Colors.indigoAccent, _logarithm),
                    _buildButton("Antilog", Colors.greenAccent, _antilog),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        shadowColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// 🔹 Custom Painter for Stylish Animated Bubble Background
class BubbleBackground extends CustomPainter {
  final double animationValue;
  BubbleBackground(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = Random(3);

    for (int i = 0; i < 20; i++) {
      final dx = (size.width * random.nextDouble() +
          animationValue * 100 * (i.isEven ? 1 : -1)) %
          size.width;
      final dy = (size.height * random.nextDouble() +
          animationValue * 120 * (i.isOdd ? 1 : -1)) %
          size.height;

      paint.color =
          Colors.primaries[i % Colors.primaries.length].withOpacity(0.3);

      canvas.drawCircle(Offset(dx, dy), 40, paint);
    }
  }

  @override
  bool shouldRepaint(covariant BubbleBackground oldDelegate) => true;
}
