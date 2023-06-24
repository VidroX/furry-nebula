import 'package:ferry/ferry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/graphql/__generated__/schema.schema.gql.dart';
import 'package:furry_nebula/graphql/exceptions/request_failed_exception.dart';
import 'package:furry_nebula/models/user/user.dart';
import 'package:furry_nebula/repositories/user/user_repository.dart';

part 'user_bloc.freezed.dart';
part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc({ required this.userRepository }) : super(const UserState()) {
    on<UserEvent>((events, emit) async =>
        events.map(
          getCurrentUser: (userData) => _getCurrentUser(userData, emit),
          logout: (logoutData) => _logout(logoutData, emit),
        ),
    );

    add(const UserEvent.getCurrentUser());
  }

  Future<void> _getCurrentUser(GetCurrentUser userData, Emitter<UserState> emit) async {
    if (!(await userRepository.isAuthenticated())) {
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      final user = await userRepository.getCurrentUser();

      emit(state.copyWith(user: user));
      userData.onSuccess?.call();
    } on RequestFailedException catch(e) {
      userData.onError?.call(e);
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _logout(Logout logoutData, Emitter<UserState> emit) async {
    emit(state.copyWith(isLogoutLoading: true));

    await userRepository.logout();

    emit(state.copyWith(isLogoutLoading: false));

    logoutData.onFinish?.call();
  }
}
