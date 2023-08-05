import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/graphql/fragments/__generated__/shelter_animal_fragment.data.gql.dart';
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
    required bool canRate,
  }) = _ShelterAnimal;

  factory ShelterAnimal.fromFragment(GShelterAnimalFragment fragment) =>
      ShelterAnimal(
        id: fragment.id,
        name: fragment.name,
        description: fragment.description,
        photo: fragment.photo,
        animalType: AnimalType.fromGAnimal(fragment.animal)!,
        shelter: Shelter.fromFragment(fragment.shelter),
        overallRating: fragment.overallRating,
        userRating: fragment.userRating,
        canRate: fragment.canRate,
      );

  const ShelterAnimal._();
}
