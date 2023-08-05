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
      SliverPadding(
        padding: padding,
        sliver: SliverFillRemaining(
          hasScrollBody: false,
          child: child,
        ),
      ),
    ],
  );
}
