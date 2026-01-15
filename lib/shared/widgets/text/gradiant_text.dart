import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  const GradientText(this.data, {super.key, required this.colors, this.style});

  final String data;
  final List<Color> colors;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        tileMode: TileMode.mirror,
      ).createShader(bounds),
      child: Text(
        data,
        style:
            style?.copyWith(color: Colors.white) ??
            const TextStyle(color: Colors.white),
      ),
    );
  }
}
