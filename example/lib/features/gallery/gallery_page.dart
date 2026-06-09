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
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            children:
                _images.map((url) => Image(image: NetworkImage(url))).toList(),
          ),
          SizedBox(
            height: 200,
            child: ListView(
              children: List.generate(
                20,
                (i) => ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                  ).createShader(bounds),
                  child: ListTile(title: Text('Shader Item $i')),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView(
              children: List.generate(
                20,
                (i) => ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.red,
                    BlendMode.colorBurn,
                  ),
                  child: ListTile(title: Text('ColorFilter Item $i')),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView(
              children: List.generate(
                20,
                (i) => ClipPath(
                  child: Container(
                    height: 50,
                    color: Colors.green,
                    child: Text('Clip Item $i'),
                  ),
                ),
              ),
            ),
          ),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            children: List.generate(
              4,
              (i) => CustomPaint(
                painter: _HeavyPainter(),
                child: const SizedBox(height: 100),
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView(
              children: List.generate(
                20,
                (i) => ImageFiltered(
                  imageFilter: const ColorFilter.mode(
                    Colors.blue,
                    BlendMode.colorBurn,
                  ),
                  child: ListTile(title: Text('ImageFilter Item $i')),
                ),
              ),
            ),
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
