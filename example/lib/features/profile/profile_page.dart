import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final StreamController<String> _controller;

  // ignore: unused_field
  late final StreamSubscription<String> _subscription;

  // ignore: unused_field
  late final AnimationController _animationController;

  // ignore: unused_field
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();

    _controller = StreamController<String>();
    _subscription = _controller.stream.listen((event) {
      print(event);
    });
    _animationController = AnimationController(
      vsync: const _FakeTickerProvider(),
      duration: const Duration(seconds: 1),
    );
    _textController = TextEditingController();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile')),
    );
  }

  @override
  void dispose() {
    setState(() {});
    super.dispose();
  }
}

class _FakeTickerProvider implements TickerProvider {
  const _FakeTickerProvider();
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
