import 'dart:math' as math;

import 'package:flutter/material.dart';

class NeoLoader extends StatefulWidget {
  const NeoLoader({
    super.key,
    this.label = 'Loading...',
    this.size = 56,
  });

  final String label;
  final double size;

  @override
  State<NeoLoader> createState() => _NeoLoaderState();
}

class _NeoLoaderState extends State<NeoLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stroke = isDark ? Colors.white : Colors.black;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  border: Border.all(color: stroke, width: 3),
                  boxShadow: [
                    BoxShadow(color: stroke, offset: const Offset(5, 5)),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: widget.size * 0.35,
                    height: widget.size * 0.35,
                    decoration: BoxDecoration(
                      border: Border.all(color: stroke, width: 3),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          widget.label.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ],
    );
  }
}
