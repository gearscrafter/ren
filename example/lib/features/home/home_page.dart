import 'dart:async';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

  }

  @override
  Widget build(BuildContext context) {
    setState(() {});

    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('Size: ${size.width} x ${size.height}'),

            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _controller.value,
                  child: const FlutterLogo(size: 100),
                );
              },
            ),

            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return ClipPath(
                  child: Container(
                    color: Colors.blue,
                    height: 100,
                  ),
                );
              },
            ),

            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _SimplePainter(_controller.value),
                  child: const SizedBox(height: 100),
                );
              },
            ),

            SizedBox(
              height: 200,
              child: PageView(
                children: List.generate(
                  5,
                  (i) => Opacity(
                    opacity: 0.7,
                    child: Container(
                      color: Colors.primaries[i % Colors.primaries.length],
                      child: Center(child: Text('Page $i')),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  Container(color: Colors.purple, height: 200),
                  BackdropFilter(
                    filter: const ColorFilter.mode(
                      Colors.black26,
                      BlendMode.darken,
                    ),
                    child: Container(color: Colors.white10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _SimplePainter extends CustomPainter {
  final double value;
  _SimplePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width * value, size.height / 2),
      20,
      Paint()..color = Colors.red,
    );
  }

  @override
  bool shouldRepaint(_SimplePainter old) => old.value != value;
}