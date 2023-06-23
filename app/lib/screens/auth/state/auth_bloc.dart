import 'package:ferry/ferry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/graphql/exceptions/validation_exception.dart';
import 'package:furry_nebula/models/user/user.dart';
import 'package:furry_nebula/repositories/user/exceptions/login_failed_exception.dart';
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
          clearValidationErrors: (fieldData) => _clearValidationErrors(fieldData, emit),
        ),
    );
  }

  Future<void> _login(Login loginData, Emitter<AuthState> emit) async {
    add(const AuthEvent.clearValidationErrors());

    emit(state.copyWith(isLoading: true));

    try {
      final user = await userRepository.login(
        loginData.email,
        loginData.password,
      );

      emit(state.copyWith(user: user));
      loginData.onSuccess?.call();
    } on ValidationException catch (e) {
      emit(state.copyWith(validationErrors: e.fieldsValidationMap));
      loginData.onError?.call(e);
    } on LoginFailedException catch(e) {
      loginData.onError?.call(e);
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _clearValidationErrors(ClearValidationErrors fieldData, Emitter<AuthState> emit) {
    if (fieldData.field != null) {
      final newValidationsErrors = { ...state.validationErrors };

      newValidationsErrors.removeWhere((key, value) => key == fieldData.field);

      emit(state.copyWith(validationErrors: newValidationsErrors));
    } else {
      emit(state.copyWith(validationErrors: {}));
    }
  }
}