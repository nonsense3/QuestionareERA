import 'package:flutter/material.dart';

class NeoButton extends StatelessWidget {
  const NeoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.foregroundColor,
    this.icon,
  });
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final Color? foregroundColor;
  final Widget? icon;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white : Colors.black;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          backgroundColor: color ?? Theme.of(context).colorScheme.primary,
          foregroundColor: foregroundColor ?? Colors.black,
          shape: const RoundedRectangleBorder(),
          side: BorderSide(color: borderColor, width: 3),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.9,
          ),
        ),
        onPressed: onPressed,
        child: icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon!,
                  const SizedBox(width: 10),
                  Text(label.toUpperCase()),
                ],
              )
            : Text(label.toUpperCase()),
      ),
    );
  }
}
