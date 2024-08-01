import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

/* ---> Custom Clipper for object <--- */
class MyClipper extends CustomClipper<Path> {
  final bool left;
  final bool top;
  final bool right;
  final bool bottom;

  MyClipper({
    this.left = false,
    this.top = false,
    this.right = false,
    this.bottom = false,
  });

  @override
  Path getClip(Size size) {
    Path path = Path();

    if (left) {
      path.addRect(Rect.fromLTWH(0, 0, 6, size.height));
    }
    if (top) {
      path.addRect(Rect.fromLTWH(0, 0, size.width, 6));
    }
    if (right) {
      path.addRect(Rect.fromLTWH(size.width - 6, 0, 6, size.height));
    }
    if (bottom) {
      path.addRect(Rect.fromLTWH(0, size.height - 6, size.width, 6));
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/* ----> PositionedClipper Widget (for position of clipper) <----- */
class PositionedClipper extends StatelessWidget {
  final bool left;
  final bool top;
  final bool right;
  final bool bottom;
  final Color color;
  final double width;
  final double height;

  PositionedClipper({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.color,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top ? (MediaQuery.sizeOf(context).height - height) / 2 - 100 : null,
      left: left ? (MediaQuery.sizeOf(context).width - width) / 2 - 40 : null,
      right: right ? (MediaQuery.sizeOf(context).width - width) / 2 - 40 : null,
      bottom: bottom ? (MediaQuery.sizeOf(context).height - height) / 2 + 27 : null,
      child: ClipPath(
        clipper: MyClipper(left: left, top: top, right: right, bottom: bottom),
        child: AnimatedContainer(
          color: color,
          duration: Duration(milliseconds: 700),
          width: 0.7 * width,
          height: 0.7 * height,
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ColorChanging(),
    );
  }
}

/* ----> ColorChanging Widget <----- */
class ColorChanging extends StatefulWidget {
  const ColorChanging({super.key});

  @override
  State<ColorChanging> createState() => _ColorChangingState();
}

class _ColorChangingState extends State<ColorChanging> {
  Color _clipperColor = Colors.white;
  late Timer _colorTimer;
  late Timer _positionTimer;
  double? imageWidth;
  double? imageHeight;

  bool _animateToBottom = false;
  double _containerHeight = 220;
  double _maxContainerHeight = 220;
  bool _showClippers = false;

  @override
  void initState() {
    super.initState();
    _startColorChangingTimer();
    _loadImage();
    _startContainerPositionAnimation();

    // Delay to show clippers
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _showClippers = true;
      });
    });
  }

  @override
  void dispose() {
    _colorTimer.cancel();
    _positionTimer.cancel();
    super.dispose();
  }

  // timer for changing color
  void _startColorChangingTimer() {
    _colorTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _clipperColor = _clipperColor == Colors.white ? Color(0XFF27aae2) : Colors.white;
      });
    });
  }

  // loading image
  void _loadImage() {
    final assetImage = AssetImage('assets/images/tpaylogo.png');
    final imageStream = assetImage.resolve(ImageConfiguration());

    imageStream.addListener(
      ImageStreamListener((ImageInfo info, bool synchronousCall) {
        setState(() {
          imageWidth = info.image.width.toDouble();
          imageHeight = info.image.height.toDouble();
        });
      }),
    );
  }

  // timer for moving the animated container
  void _startContainerPositionAnimation() {
    _positionTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        _animateToBottom = !_animateToBottom;
        if (_animateToBottom) {
          _containerHeight = _maxContainerHeight;
        } else {
          _containerHeight = 0;
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFF27aae2),
      body: Center(
        child: Stack(
          children: [
            Stack(
              children: [
                if (_showClippers && imageWidth != null && imageHeight != null) ...[
                  PositionedClipper(
                    left: true,
                    top: true,
                    right: false,
                    bottom: false,
                    color: _clipperColor,
                    width: imageWidth!,
                    height: imageHeight!,
                  ),
                  PositionedClipper(
                    left: false,
                    top: true,
                    right: true,
                    bottom: false,
                    color: _clipperColor,
                    width: imageWidth!,
                    height: imageHeight!,
                  ),
                  PositionedClipper(
                    left: true,
                    top: false,
                    right: false,
                    bottom: true,
                    color: _clipperColor,
                    width: imageWidth!,
                    height: imageHeight!,
                  ),
                  PositionedClipper(
                    left: false,
                    top: false,
                    right: true,
                    bottom: true,
                    color: _clipperColor,
                    width: imageWidth!,
                    height: imageHeight!,
                  ),
                ],
                Align(
                  alignment: Alignment.center,
                  child: imageWidth != null && imageHeight != null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/tpaylogo.png',
                        errorBuilder: (context, error, stackTrace) {
                          return Text('Failed to load image');
                        },
                      ),
                      SizedBox(height: 70),
                      Image.asset(
                        'assets/images/tpaylogo2.png',
                        errorBuilder: (context, error, stackTrace) {
                          return Text('Failed to load image');
                        },
                      ),
                    ],
                  )
                      : CircularProgressIndicator(),
                ),
              ],
            ),
            if (imageWidth != null && imageHeight != null)
              AnimatedPositioned(
                duration: Duration(seconds: 3),
                bottom: _animateToBottom ? 0 : (MediaQuery.sizeOf(context).height / 2) - 110,
                left: (MediaQuery.sizeOf(context).width / 2) - 100,
                child: AnimatedContainer(
                  height: _containerHeight,
                  width: 200,
                  alignment: _animateToBottom ? Alignment.bottomCenter : Alignment.topCenter,
                  color: Color(0XFF27aae2),
                  duration: Duration(seconds: 1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
