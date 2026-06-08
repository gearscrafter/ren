import 'package:flutter/material.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Stack(
        children: [
          BackdropFilter(
            filter: const ColorFilter.mode(
              Colors.black26,
              BlendMode.darken,
            ),
            child: Container(color: Colors.white10),
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
              (i) => ListTile(title: Text('Item $i')),
            ),
          ),
        ],
      ),
    );
  }
}