import 'package:flutter/material.dart';
import 'features/home/home_page.dart';

void main() => runApp(const RenExampleApp());

class RenExampleApp extends StatelessWidget {
  const RenExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ren Example',
      home: const HomePage(),
    );
  }
}