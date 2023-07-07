import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_shelter_data.freezed.dart';

@freezed
class AddShelterData with _$AddShelterData {
  const factory AddShelterData({
    required String name,
    required String address,
    @Default('') String info,
  }) = _AddShelterData;
}
