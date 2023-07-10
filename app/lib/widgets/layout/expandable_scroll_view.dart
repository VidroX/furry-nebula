import 'package:flutter/material.dart';

class ExpandableScrollView extends StatelessWidget {
  final Widget child;
  final ScrollPhysics physics;
  final EdgeInsetsGeometry padding;
  final ScrollController? controller;

  const ExpandableScrollView({
    required this.child,
    this.physics = const BouncingScrollPhysics(),
    this.padding = EdgeInsets.zero,
    this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) => CustomScrollView(
    controller: controller,
    physics: physics,
    slivers: [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    ],
  );
}
