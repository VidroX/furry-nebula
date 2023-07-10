import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_object.freezed.dart';

@freezed
class PhotoObject<T> with _$PhotoObject<T> {
  const factory PhotoObject({
    required T object,
    MultipartFile? photo,
  }) = _PhotoObject;
}
