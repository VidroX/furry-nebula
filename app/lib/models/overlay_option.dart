import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'overlay_option.freezed.dart';

@freezed
class OverlayOption<T> with _$OverlayOption<T> {
  const factory OverlayOption({
    required T data,
    required String title,
    String? uniqueIndex,
  }) = _OverlayOption;
}
