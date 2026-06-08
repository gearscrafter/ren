import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),

      body: SingleChildScrollView(
        child: Column(
          children: [
            RepaintBoundary(
              child: const Text('Static content'),
            ),

            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.red,
                BlendMode.colorBurn,
              ),
              child: const FlutterLogo(size: 100),
            ),

            FadeInImage(
              placeholder: const AssetImage('assets/placeholder.png'),
              image: const NetworkImage('https://picsum.photos/200'),
            ),

            Wrap(
              children: List.generate(
                200,
                (i) => Chip(label: Text('Tag $i')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}