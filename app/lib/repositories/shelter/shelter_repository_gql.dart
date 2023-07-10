import 'package:dio/dio.dart';
import 'package:ferry/typed_links.dart';
import 'package:furry_nebula/graphql/__generated__/schema.schema.gql.dart';
import 'package:furry_nebula/graphql/exceptions/general_api_exception.dart';
import 'package:furry_nebula/graphql/exceptions/request_failed_exception.dart';
import 'package:furry_nebula/graphql/exceptions/validation_exception.dart';
import 'package:furry_nebula/graphql/fragments/__generated__/shelter_animal_fragment.data.gql.dart';
import 'package:furry_nebula/graphql/fragments/__generated__/shelter_fragment.data.gql.dart';
import 'package:furry_nebula/graphql/mutations/shelter/__generated__/add_user_shelter.req.gql.dart';
import 'package:furry_nebula/graphql/mutations/shelter/__generated__/add_user_shelter_animal.req.gql.dart';
import 'package:furry_nebula/graphql/mutations/shelter/__generated__/delete_shelter.req.gql.dart';
import 'package:furry_nebula/graphql/mutations/shelter/__generated__/remove_animal.req.gql.dart';
import 'package:furry_nebula/graphql/queries/shelter/__generated__/get_shelter_animal_by_id.req.gql.dart';
import 'package:furry_nebula/graphql/queries/shelter/__generated__/get_shelter_animals.req.gql.dart';
import 'package:furry_nebula/graphql/queries/shelter/__generated__/get_shelter_by_id.req.gql.dart';
import 'package:furry_nebula/graphql/queries/shelter/__generated__/get_shelters.req.gql.dart';
import 'package:furry_nebula/models/pagination/graph_page.dart';
import 'package:furry_nebula/models/pagination/pagination.dart';
import 'package:furry_nebula/models/shelter/animal_type.dart';
import 'package:furry_nebula/models/shelter/shelter.dart';
import 'package:furry_nebula/models/shelter/shelter_animal.dart';
import 'package:furry_nebula/models/user/user.dart';
import 'package:furry_nebula/models/user/user_role.dart';
import 'package:furry_nebula/repositories/shelter/shelter_repository.dart';
import 'package:furry_nebula/screens/home/shelters/pets/state/pets_filter.dart';
import 'package:furry_nebula/services/api_client.dart';

class ShelterRepositoryGraphQL extends ShelterRepository {
  final ApiClient client;

  ShelterRepositoryGraphQL({ required this.client });

  Shelter _buildShelter(GShelterFragment shelterFragment) => Shelter(
    id: shelterFragment.id,
    name: shelterFragment.name,
    address: shelterFragment.address,
    info: shelterFragment.info,
    photo: shelterFragment.photo,
    representativeUser: User(
      id: shelterFragment.representativeUser.id,
      firstName: shelterFragment.representativeUser.firstName,
      lastName: shelterFragment.representativeUser.lastName,
      isApproved: shelterFragment.representativeUser.isApproved,
      about: shelterFragment.representativeUser.about,
      role: UserRole.fromGRole(shelterFragment.representativeUser.role)!,
      email: shelterFragment.representativeUser.email,
      birthDay: shelterFragment.representativeUser.birthday,
    ),
  );

  ShelterAnimal _buildShelterAnimal(GShelterAnimalFragment animalFragment) =>
      ShelterAnimal(
        id: animalFragment.id,
        name: animalFragment.name,
        description: animalFragment.description,
        photo: animalFragment.photo,
        animalType: AnimalType.fromGAnimal(animalFragment.animal)!,
        shelter: _buildShelter(animalFragment.shelter),
        overallRating: animalFragment.overallRating,
        userRating: animalFragment.userRating,
      );

  @override
  Future<Shelter> addShelter({
    required String name,
    required String address,
    String? info,
    MultipartFile? photo,
  }) async {
    final shelterInput = GShelterInputBuilder()
      ..name = name
      ..address = address
      ..info = info;

    final request = GAddUserShelterReq(
          (b) => b
            ..vars.input = shelterInput
            ..vars.photo = photo
            ..fetchPolicy = FetchPolicy.NoCache,
    );

    final response = await client.ferryClient.request(request).first;

    if (response.linkException is GeneralApiException ||
        response.linkException is ValidationException) {
      throw response.linkException!;
    }

    if (response.data?.addShelter == null) {
      throw const RequestFailedException();
    }

    return _buildShelter(response.data!.addShelter);
  }

  @override
  Future<ShelterAnimal> addShelterAnimal({
    required String shelterId,
    required AnimalType animalType,
    required String name,
    String? description,
    MultipartFile? photo,
  }) async {
    final shelterAnimalInput = GShelterAnimalInputBuilder()
      ..shelterId = shelterId
      ..name = name
      ..description = description
      ..animal = animalType.toGAnimal;

    final request = GAddUserShelterAnimalReq(
          (b) => b
            ..vars.input = shelterAnimalInput
            ..vars.photo = photo
            ..fetchPolicy = FetchPolicy.NoCache,
    );

    final response = await client.ferryClient.request(request).first;

    if (response.linkException is GeneralApiException ||
        response.linkException is ValidationException) {
      throw response.linkException!;
    }

    if (response.data?.addShelterAnimal == null) {
      throw const RequestFailedException();
    }

    return _buildShelterAnimal(response.data!.addShelterAnimal);
  }

  @override
  Future<void> deleteShelter({ required String shelterId }) async {
    final request = GDeleteShelterReq((b) => b..vars.id = shelterId);

    final response = await client.ferryClient.request(request).first;

    if (response.linkException != null) {
      throw const RequestFailedException();
    }
  }

  @override
  Future<GraphPage<ShelterAnimal>> getShelterAnimals({
    Pagination pagination = const Pagination(),
    bool shouldGetFromCacheFirst = true,
    PetsFilter filters = const PetsFilter(),
  }) async {
    final request = GGetShelterAnimalsReq(
          (b) => b
            ..vars.filters = filters.toGAnimalFiltersBuilder
            ..vars.pagination = pagination.toGPaginationBuilder
            ..fetchPolicy = shouldGetFromCacheFirst
                ? FetchPolicy.CacheFirst
                : FetchPolicy.NetworkOnly,
    );

    final response = await client.ferryClient.request(request).first;

    if (response.data?.shelterAnimals.node == null) {
      throw const RequestFailedException();
    }

    final pageInfo = response.data!.shelterAnimals.pageInfo;
    final shelterAnimals = response.data!.shelterAnimals.node
        .map((animal) => _buildShelterAnimal(animal!))
        .toList();

    return GraphPage.fromFragment(
      nodes: shelterAnimals,
      pageInfo: pageInfo,
    );
  }

  @override
  Future<GraphPage<Shelter>> getShelters({
    Pagination pagination = const Pagination(),
    bool shouldGetFromCacheFirst = true,
    bool? showOnlyOwnShelters,
  }) async {
    final shelterFilters = GShelterFiltersBuilder()
      ..showOnlyOwnShelters = showOnlyOwnShelters;

    final request = GGetSheltersReq(
          (b) => b
            ..vars.filters = shelterFilters
            ..vars.pagination = pagination.toGPaginationBuilder
            ..fetchPolicy = shouldGetFromCacheFirst
                ? FetchPolicy.CacheFirst
                : FetchPolicy.NetworkOnly,
    );

    final response = await client.ferryClient.request(request).first;

    if (response.data?.shelters.node == null) {
      throw const RequestFailedException();
    }

    final pageInfo = response.data!.shelters.pageInfo;
    final shelters = response.data!.shelters.node
        .map((shelter) => _buildShelter(shelter!))
        .toList();

    return GraphPage.fromFragment(
      nodes: shelters,
      pageInfo: pageInfo,
    );
  }

  @override
  Future<void> removeShelterAnimal({ required String shelterAnimalId }) async {
    final request = GRemoveAnimalReq((b) => b..vars.id = shelterAnimalId);

    final response = await client.ferryClient.request(request).first;

    if (response.linkException != null) {
      throw const RequestFailedException();
    }
  }

  @override
  Future<ShelterAnimal> getShelterAnimalById(String id) async {
    final request = GGetShelterAnimalByIdReq((b) => b..vars.id = id);

    final response = await client.ferryClient.request(request).first;

    if (response.data?.shelterAnimal == null) {
      throw const RequestFailedException();
    }

    return _buildShelterAnimal(response.data!.shelterAnimal);
  }

  @override
  Future<Shelter> getShelterById(String id) async {
    final request = GGetShelterByIdReq((b) => b..vars.id = id);

    final response = await client.ferryClient.request(request).first;

    if (response.data?.shelter == null) {
      throw const RequestFailedException();
    }

    return _buildShelter(response.data!.shelter);
  }
}
