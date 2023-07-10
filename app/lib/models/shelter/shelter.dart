import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/models/user/user.dart';

part 'shelter.freezed.dart';

@freezed
class Shelter with _$Shelter {
  const factory Shelter({
    required String id,
    required String name,
    required String address,
    @Default('') String info,
    String? photo,
    required User representativeUser,
  }) = _Shelter;

  const Shelter._();
}
