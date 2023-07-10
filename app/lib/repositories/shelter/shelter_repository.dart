import 'package:dio/dio.dart';
import 'package:furry_nebula/models/pagination/graph_page.dart';
import 'package:furry_nebula/models/pagination/pagination.dart';
import 'package:furry_nebula/models/shelter/animal_type.dart';
import 'package:furry_nebula/models/shelter/shelter.dart';
import 'package:furry_nebula/models/shelter/shelter_animal.dart';
import 'package:furry_nebula/screens/home/shelters/pets/state/pets_filter.dart';

abstract class ShelterRepository {
  Future<GraphPage<Shelter>> getShelters({
    Pagination pagination = const Pagination(),
    bool shouldGetFromCacheFirst = true,
    bool? showOnlyOwnShelters,
  });

  Future<Shelter> getShelterById(String id);

  Future<GraphPage<ShelterAnimal>> getShelterAnimals({
    Pagination pagination = const Pagination(),
    bool shouldGetFromCacheFirst = true,
    PetsFilter filters = const PetsFilter(),
  });

  Future<ShelterAnimal> getShelterAnimalById(String id);

  Future<Shelter> addShelter({
    required String name,
    required String address,
    String? info,
    MultipartFile? photo,
  });

  Future<ShelterAnimal> addShelterAnimal({
    required String shelterId,
    required AnimalType animalType,
    required String name,
    String? description,
    MultipartFile? photo,
  });

  Future<void> deleteShelter({ required String shelterId });

  Future<void> removeShelterAnimal({ required String shelterAnimalId });
}
