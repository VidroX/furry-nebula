import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/models/shelter/animal_type.dart';

part 'add_shelter_animal_data.freezed.dart';

@freezed
class AddShelterAnimalData with _$AddShelterAnimalData {
  const factory AddShelterAnimalData({
    required String name,
    required AnimalType animalType,
    @Default('') String description,
  }) = _AddShelterAnimalData;
}
