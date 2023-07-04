import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/models/shelter/animal_type.dart';
import 'package:furry_nebula/models/shelter/shelter.dart';

part 'shelter_animal.freezed.dart';

@freezed
class ShelterAnimal with _$ShelterAnimal {
  const factory ShelterAnimal({
    required String id,
    required String name,
    @Default('') String description,
    String? photo,
    required AnimalType animalType,
    required Shelter shelter,
    required double overallRating,
    double? userRating,
  }) = _ShelterAnimal;

  const ShelterAnimal._();
}
