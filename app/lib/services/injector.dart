import 'package:dio/dio.dart';
import 'package:furry_nebula/repositories/user/user_repository.dart';
import 'package:furry_nebula/repositories/user/user_repository_gql.dart';
import 'package:furry_nebula/screens/auth/state/auth_bloc.dart';
import 'package:furry_nebula/screens/home/approvals/state/user_approvals_bloc.dart';
import 'package:furry_nebula/screens/home/state/user_bloc.dart';
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
    ..registerSingleton<Dio>(Dio())
    ..registerSingleton<ApiClient>(ApiClient(injector.get<Dio>()));
}

void _initRepositories() {
  injector
    .registerSingleton<UserRepository>(
      UserRepositoryGraphQL(client: injector.get()),
    );
}

void _initBlocs() {
  injector
      ..registerFactory<AuthBloc>(() => AuthBloc(userRepository: injector.get()))
      ..registerFactory<UserBloc>(() => UserBloc(userRepository: injector.get()))
      ..registerFactory<UserApprovalsBloc>(() =>
          UserApprovalsBloc(userRepository: injector.get()),
      );
}
