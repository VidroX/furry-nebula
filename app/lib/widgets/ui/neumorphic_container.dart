import 'package:flutter/material.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration decoration;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final Clip clipBehaviour;

  static const borderRadius = BorderRadius.all(Radius.circular(8));

  const NeumorphicContainer({
    required this.child,
    this.decoration = const BoxDecoration(
      borderRadius: borderRadius,
    ),
    this.clipBehaviour = Clip.antiAlias,
    this.backgroundColor,
    this.padding,
    this.width,
    this.height,
    this.constraints,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    constraints: constraints,
    decoration: decoration.copyWith(
      color: backgroundColor ?? context.colors.containerColor,
      boxShadow: context.colors.neumorphicShadow,
    ),
    clipBehavior: clipBehaviour,
    padding: padding,
    child: child,
  );
}
