import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

class UploadSerializer extends PrimitiveSerializer<MultipartFile> {
  @override
  MultipartFile deserialize(Serializers serializers, Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    assert(
      serialized is List<int>,
      "UploadSerializer expected 'Uint8List' but got ${serialized.runtimeType}",
    );
    return MultipartFile.fromBytes(serialized as List<int>);
  }

  @override
  Object serialize(Serializers serializers, MultipartFile file, {
    FullType specifiedType = FullType.unspecified,
  }) => file;

  @override
  Iterable<Type> get types => [MultipartFile];

  @override
  String get wireName => "Upload";
}
