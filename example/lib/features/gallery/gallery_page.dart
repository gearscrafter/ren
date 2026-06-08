import 'package:flutter/material.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  static const _images = [
    'https://picsum.photos/200/300',
    'https://picsum.photos/200/301',
    'https://picsum.photos/200/302',
    'https://picsum.photos/200/303',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: Column(
        children: [
          GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            children: _images
                .map((url) => Image(
                      image: NetworkImage(url), 
                    ))
                .toList(),
          ),

          ImageFiltered(
            imageFilter: const ColorFilter.mode(
              Colors.blue,
              BlendMode.colorBurn,
            ),
            child: const FlutterLogo(size: 100),
          ),

          ClipPath(
            child: Container(color: Colors.red, height: 100),
          ),

          CustomPaint(
            painter: _HeavyPainter(),
            child: const SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}

class _HeavyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint()); 
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HeavyPainter oldDelegate) => true;
}