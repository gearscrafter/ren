import 'dart:async';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final StreamController<String> _controller;
  late final StreamSubscription<String> _subscription;

  @override
  void initState() {
    super.initState();

    _controller = StreamController<String>();

    _subscription = _controller.stream.listen((event) {
      print(event);
    });

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
