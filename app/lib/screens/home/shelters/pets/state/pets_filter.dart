import 'package:built_collection/built_collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/graphql/__generated__/schema.schema.gql.dart';
import 'package:furry_nebula/models/shelter/animal_type.dart';

part 'pets_filter.freezed.dart';

@freezed
class PetsFilter with _$PetsFilter {
  const factory PetsFilter({
    AnimalType? animalType,
    String? selectedShelter,
    List<String>? selectedShelters,
  }) = _PetsFilter;

  const PetsFilter._();

  GAnimalFiltersBuilder get toGAnimalFiltersBuilder => GAnimalFiltersBuilder()
    ..shelterId = selectedShelter
    ..animal = animalType?.toGAnimal
    ..shelterIds = selectedShelters != null
        ? ListBuilder(selectedShelters!)
        : null;
}
