import 'dart:ui';

import 'package:flutter/material.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Stack(
        children: [
          ListView(
            children: List.generate(
              100,
              (i) => BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: ListTile(title: Text('Item $i')),
              ),
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.blue, Colors.purple],
            ).createShader(bounds),
            child: const Text('Checkout', style: TextStyle(fontSize: 32)),
          ),
          Opacity(
            opacity: 0.5,
            child: Container(color: Colors.red),
          ),
          ListView(
            children: List.generate(
              100,
              (i) => Opacity(
                opacity: 0.8,
                child: ListTile(title: Text('Opacity Item $i')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
