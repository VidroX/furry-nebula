import 'package:flutter/material.dart';

class ScreenLayout extends StatelessWidget {
  final Widget child;

  const ScreenLayout({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: child,
      ),
    ),
  );
}
