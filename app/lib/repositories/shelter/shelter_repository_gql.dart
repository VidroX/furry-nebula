import 'package:dio/dio.dart';
import 'package:ferry/typed_links.dart';
import 'package:furry_nebula/graphql/__generated__/schema.schema.gql.dart';
import 'package:furry_nebula/graphql/exceptions/general_api_exception.dart';
import 'package:furry_nebula/graphql/exceptions/request_failed_exception.dart';
import 'package:furry_nebula/graphql/exceptions/validation_exception.dart';
import 'package:furry_nebula/graphql/mutations/shelter/__generated__/add_user_shelter.req.gql.dart';
import 'package:furry_nebula/graphql/mutations/shelter/__generated__/add_user_shelter_animal.req.gql.dart';
import 'package:furry_nebula/graphql/mutations/shelter/__generated__/cancel_user_request.req.gql.dart';
import 'package:furry_nebula/graphql/mutations/shelter/__generated__/change_user_request_status.req.gql.dart';
import 'package:furry_nebula/graphql/mutations/shelter/__generated__/create_user_request.req.gql.dart';
import 'package:furry_nebula/graphql/mutations/shelter/__generated__/delete_shelter.req.gql.dart';
import 'package:furry_nebula/graphql/mutations/shelter/__generated__/remove_animal.req.gql.dart';
import 'package:furry_nebula/graphql/queries/shelter/__generated__/get_shelter_animal_by_id.req.gql.dart';
import 'package:furry_nebula/graphql/queries/shelter/__generated__/get_shelter_animals.req.gql.dart';
import 'package:furry_nebula/graphql/queries/shelter/__generated__/get_shelter_by_id.req.gql.dart';
import 'package:furry_nebula/graphql/queries/shelter/__generated__/get_shelters.req.gql.dart';
import 'package:furry_nebula/graphql/queries/shelter/__generated__/get_user_requests.req.gql.dart';
import 'package:furry_nebula/models/pagination/graph_page.dart';
import 'package:furry_nebula/models/pagination/pagination.dart';
import 'package:furry_nebula/models/shelter/animal_type.dart';
import 'package:furry_nebula/models/shelter/shelter.dart';
import 'package:furry_nebula/models/shelter/shelter_animal.dart';
import 'package:furry_nebula/models/shelter/user_request.dart';
import 'package:furry_nebula/models/shelter/user_request_status.dart';
import 'package:furry_nebula/models/shelter/user_request_type.dart';
import 'package:furry_nebula/repositories/shelter/shelter_repository.dart';
import 'package:furry_nebula/screens/home/shelters/pets/state/pets_filter.dart';
import 'package:furry_nebula/screens/requests/state/user_requests_filters.dart';
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

    return Shelter.fromFragment(response.data!.addShelter);
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

    return ShelterAnimal.fromFragment(response.data!.addShelterAnimal);
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
        .map((animal) => ShelterAnimal.fromFragment(animal))
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
        .map((shelter) => Shelter.fromFragment(shelter))
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

    return ShelterAnimal.fromFragment(response.data!.shelterAnimal);
  }

  @override
  Future<Shelter> getShelterById(String id) async {
    final request = GGetShelterByIdReq((b) => b..vars.id = id);

    final response = await client.ferryClient.request(request).first;

    if (response.data?.shelter == null) {
      throw const RequestFailedException();
    }

    return Shelter.fromFragment(response.data!.shelter);
  }

  @override
  Future<GraphPage<UserRequest>> getUserRequests({
    UserRequestsFilters filters = const UserRequestsFilters(),
    bool shouldGetFromCacheFirst = true,
    Pagination pagination = const Pagination(),
  }) async {
    final request = GGetUserRequestsReq(
          (b) => b
            ..vars.filters = filters.toGUserRequestFiltersBuilder
            ..vars.pagination = pagination.toGPaginationBuilder
            ..fetchPolicy = shouldGetFromCacheFirst
                ? FetchPolicy.CacheFirst
                : FetchPolicy.NetworkOnly,
    );

    final response = await client.ferryClient.request(request).first;

    if (response.data?.userRequests.node == null) {
      throw const RequestFailedException();
    }

    final pageInfo = response.data!.userRequests.pageInfo;
    final userRequests = response.data!.userRequests.node
        .map((userRequest) => UserRequest.fromFragment(userRequest))
        .toList();

    return GraphPage.fromFragment(
      nodes: userRequests,
      pageInfo: pageInfo,
    );
  }

  @override
  Future<UserRequest> createUserRequest({
    required String animalId,
    required UserRequestType requestType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final userRequestInput = GUserRequestInputBuilder()
      ..animalId = animalId
      ..requestType = requestType.toGUserRequestType
      ..fromDate = fromDate
      ..toDate = toDate;

    final request = GCreateUserRequestReq(
          (b) => b..vars.data = userRequestInput,
    );

    final response = await client.ferryClient.request(request).first;

    if (response.linkException is GeneralApiException ||
        response.linkException is ValidationException) {
      throw response.linkException!;
    }

    if (response.data?.createUserRequest == null) {
      throw const RequestFailedException();
    }

    return UserRequest.fromFragment(response.data!.createUserRequest);
  }

  @override
  Future<void> changeUserRequestStatus({
    required String requestId,
    UserRequestStatus status = UserRequestStatus.cancelled,
  }) async {
    final request = GChangeUserRequestStatusReq(
          (b) => b
            ..vars.id = requestId
            ..vars.status = status.toGUserRequestStatus,
    );

    final response = await client.ferryClient.request(request).first;

    if (response.linkException != null) {
      throw const RequestFailedException();
    }
  }

  @override
  Future<void> cancelUserRequest({required String requestId}) async {
    final request = GCancelUserRequestReq(
          (b) => b..vars.id = requestId,
    );

    final response = await client.ferryClient.request(request).first;

    if (response.linkException != null) {
      throw const RequestFailedException();
    }
  }
}
