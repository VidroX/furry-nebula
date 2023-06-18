import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/models/user/user.dart';
import 'package:furry_nebula/repositories/user/user_repository.dart';

part 'auth_bloc.freezed.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;

  AuthBloc({ required this.userRepository }) : super(const AuthState()) {
    on<AuthEvent>((events, emit) async =>
        events.map(
          login: (loginData) => _login(loginData, emit),
        ),
    );
  }

  Future<void> _login(Login loginData, Emitter<AuthState> emit) async {
    final user = await userRepository.login(loginData.email, loginData.password);

    emit(state.copyWith(user: user));
  }
}
