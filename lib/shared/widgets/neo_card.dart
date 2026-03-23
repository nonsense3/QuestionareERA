import 'package:flutter/material.dart';

class NeoCard extends StatelessWidget {
  const NeoCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 14),
  });

  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white : Colors.black;
    // Light mode: softer shadow so cards don’t look “broken” on cream/white.
    final shadowColor = isDark
        ? borderColor
        : borderColor.withValues(alpha: 0.28);
    final shadowOffset = isDark ? const Offset(6, 6) : const Offset(4, 4);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        border: Border.all(color: borderColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: shadowOffset,
            blurRadius: 0,
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
