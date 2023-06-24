import 'package:flutter/material.dart';

class ExpandableScrollView extends StatelessWidget {
  final Widget child;
  final ScrollPhysics physics;

  const ExpandableScrollView({
    required this.child,
    this.physics = const BouncingScrollPhysics(),
    super.key,
  });

  @override
  Widget build(BuildContext context) => CustomScrollView(
    physics: physics,
    slivers: [
      SliverFillRemaining(
        hasScrollBody: false,
        child: child,
      ),
    ],
  );
}
