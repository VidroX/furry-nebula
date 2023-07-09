import 'package:flutter/material.dart';

class OverlayOption<T> {
  final String title;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final T data;

  const OverlayOption({
    required this.data,
    required this.title,
    this.prefixWidget,
    this.suffixWidget,
  });
}
