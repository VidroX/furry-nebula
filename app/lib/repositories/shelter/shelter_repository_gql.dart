import 'package:dio/dio.dart';
import 'package:furry_nebula/models/pagination/graph_page.dart';
import 'package:furry_nebula/models/pagination/pagination.dart';
import 'package:furry_nebula/models/shelter/animal_type.dart';
import 'package:furry_nebula/models/shelter/shelter.dart';
import 'package:furry_nebula/models/shelter/shelter_animal.dart';
import 'package:furry_nebula/repositories/shelter/shelter_repository.dart';
import 'package:furry_nebula/services/api_client.dart';

class ShelterRepositoryGraphQL extends ShelterRepository {
  final ApiClient client;

  ShelterRepositoryGraphQL({ required this.client });

  @override
  Future<Shelter> addShelter({
    required String name,
    required String address,
    String? info,
    MultipartFile? photo,
  }) {
    // TODO: implement addShelter
    throw UnimplementedError();
  }

  @override
  Future<ShelterAnimal> addShelterAnimal({
    required String shelterId,
    required AnimalType animalType,
    required String name,
    String? description,
    MultipartFile? photo,
  }) {
    // TODO: implement addShelterAnimal
    throw UnimplementedError();
  }

  @override
  Future<void> deleteShelter({ required String shelterId }) {
    // TODO: implement deleteShelter
    throw UnimplementedError();
  }

  @override
  Future<GraphPage<ShelterAnimal>> getShelterAnimals({
    Pagination pagination = const Pagination(),
    String? shelterId,
    AnimalType? animalType,
  }) {
    // TODO: implement getShelterAnimals
    throw UnimplementedError();
  }

  @override
  Future<GraphPage<Shelter>> getShelters({
    Pagination pagination = const Pagination(),
    bool showOnlyOwnShelters = false,
  }) {
    // TODO: implement getShelters
    throw UnimplementedError();
  }

  @override
  Future<void> removeShelterAnimal({ required String shelterAnimalId }) {
    // TODO: implement removeShelterAnimal
    throw UnimplementedError();
  }
}
