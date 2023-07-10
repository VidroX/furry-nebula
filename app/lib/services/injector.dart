import 'package:dio/dio.dart';
import 'package:ferry/ferry.dart';
import 'package:furry_nebula/graphql/__generated__/schema.schema.gql.dart';
import 'package:furry_nebula/repositories/shelter/shelter_repository.dart';
import 'package:furry_nebula/repositories/shelter/shelter_repository_gql.dart';
import 'package:furry_nebula/repositories/user/user_repository.dart';
import 'package:furry_nebula/repositories/user/user_repository_gql.dart';
import 'package:furry_nebula/screens/auth/state/auth_bloc.dart';
import 'package:furry_nebula/screens/home/approvals/state/user_approvals_bloc.dart';
import 'package:furry_nebula/screens/home/shelters/pets/state/pets_bloc.dart';
import 'package:furry_nebula/screens/home/shelters/state/shelters_bloc.dart';
import 'package:furry_nebula/screens/home/state/user_bloc.dart';
import 'package:furry_nebula/screens/pet_details/state/pet_details_bloc.dart';
import 'package:furry_nebula/screens/shelter_details/state/shelter_details_bloc.dart';
import 'package:furry_nebula/services/api_client.dart';
import 'package:get_it/get_it.dart';

final injector = GetIt.instance;

void initDependencyInjector() {
  _initApi();
  _initRepositories();
  _initBlocs();
}

void _initApi() {
  injector
    // ignore: avoid_redundant_argument_values
    ..registerSingleton<Cache>(Cache(possibleTypes: possibleTypesMap))
    ..registerSingleton<Dio>(Dio())
    ..registerSingleton<ApiClient>(ApiClient.init(
      cache: injector.get(),
      client: injector.get(),
    ),);
}

void _initRepositories() {
  injector
    ..registerSingleton<UserRepository>(
      UserRepositoryGraphQL(client: injector.get()),
    )
    ..registerSingleton<ShelterRepository>(
      ShelterRepositoryGraphQL(client: injector.get()),
    );
}

void _initBlocs() {
  injector
      ..registerFactory<AuthBloc>(() => AuthBloc(userRepository: injector.get()))
      ..registerFactory<UserBloc>(() => UserBloc(userRepository: injector.get()))
      ..registerFactory<UserApprovalsBloc>(() =>
          UserApprovalsBloc(userRepository: injector.get()),
      )
      ..registerFactory<SheltersBloc>(() =>
          SheltersBloc(shelterRepository: injector.get()),
      )
      ..registerFactory<PetsBloc>(() =>
          PetsBloc(shelterRepository: injector.get()),
      )
      ..registerFactory<ShelterDetailsBloc>(() =>
          ShelterDetailsBloc(shelterRepository: injector.get()),
      )
      ..registerFactory<PetDetailsBloc>(() =>
          PetDetailsBloc(shelterRepository: injector.get()),
      );
}
