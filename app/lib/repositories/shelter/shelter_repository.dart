import 'package:dio/dio.dart';
import 'package:furry_nebula/models/pagination/graph_page.dart';
import 'package:furry_nebula/models/pagination/pagination.dart';
import 'package:furry_nebula/models/shelter/animal_type.dart';
import 'package:furry_nebula/models/shelter/shelter.dart';
import 'package:furry_nebula/models/shelter/shelter_animal.dart';
import 'package:furry_nebula/models/shelter/user_request.dart';
import 'package:furry_nebula/models/shelter/user_request_type.dart';
import 'package:furry_nebula/screens/home/shelters/pets/state/pets_filter.dart';
import 'package:furry_nebula/screens/requests/state/user_requests_filters.dart';

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

  Future<GraphPage<UserRequest>> getUserRequests({
    UserRequestsFilters filters = const UserRequestsFilters(),
    bool shouldGetFromCacheFirst = true,
    Pagination pagination = const Pagination(),
  });

  Future<UserRequest> createUserRequest({
    required String animalId,
    required UserRequestType requestType,
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<void> changeUserRequestStatus({
    required String requestId,
    bool isApproved = false,
  });

  Future<void> changeUserRequestFulfillmentStatus({
    required String requestId,
    bool isFulfilled = false,
  });
}
