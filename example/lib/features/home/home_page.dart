import 'dart:async';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _timer;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});

    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Text('Size: ${size.width} x ${size.height}'),
      ),
    );
  }
}
