import 'package:collection/collection.dart';
import 'package:ferry/ferry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/graphql/exceptions/request_failed_exception.dart';
import 'package:furry_nebula/models/pagination/graph_page.dart';
import 'package:furry_nebula/models/pagination/pagination.dart';
import 'package:furry_nebula/models/user/user.dart';
import 'package:furry_nebula/repositories/user/user_repository.dart';

part 'user_approvals_bloc.freezed.dart';
part 'user_approvals_event.dart';
part 'user_approvals_state.dart';

class UserApprovalsBloc extends Bloc<UserApprovalsEvent, UserApprovalsState> {
  final UserRepository userRepository;

  UserApprovalsBloc({ required this.userRepository }) : super(const UserApprovalsState()) {
    on<UserApprovalsEvent>((events, emit) async =>
        events.map(
          getUnapprovedUsers: (getUnapprovedUsersData) =>
              _getUnapprovedUsers(getUnapprovedUsersData, emit),
          nextPage: (nextPageData) =>
              _nextPage(nextPageData, emit),
          changeUserStatus: (changeUserStatusData) =>
              _changeUserStatus(changeUserStatusData, emit),
          removeUser: (removeUserData) => _removeUser(removeUserData, emit),
        ),
    );
  }

  Future<void> _getUnapprovedUsers(
      GetUnapprovedUsers unapprovedUsersData,
      Emitter<UserApprovalsState> emit,
  ) async {
    if (state.isLoading) {
      return;
    }

    if (unapprovedUsersData.clearFetch) {
      emit(state.copyWith(
        userApprovals: [],
        pageInfo: const GraphPageInfo(),
        pagination: const Pagination(),
      ),);
    }

    emit(state.copyWith(isLoading: true));

    try {
      final unapprovedUsers = await userRepository.getUnapprovedUsers(
        shouldGetFromCacheFirst: !unapprovedUsersData.clearFetch,
        pagination: state.pagination,
      );

      emit(state.copyWith(
        userApprovals: unapprovedUsersData.clearFetch
            ? unapprovedUsers.nodes
            : [...state.userApprovals, ...unapprovedUsers.nodes],
        pageInfo: unapprovedUsers.pageInfo,
      ),);

      unapprovedUsersData.onSuccess?.call(unapprovedUsers);
    } on RequestFailedException catch(e) {
      unapprovedUsersData.onError?.call(e);
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _nextPage(
      GetUnapprovedUsersNextPage nextPageData,
      Emitter<UserApprovalsState> emit,
  ) async {
    if (!state.pageInfo.hasNextPage || state.isLoading) {
      return;
    }

    emit(state.copyWith(pagination: state.pagination.nextPage));

    add(UserApprovalsEvent.getUnapprovedUsers(
      clearFetch: false,
      onSuccess: nextPageData.onSuccess,
      onError: nextPageData.onError,
    ),);
  }

  Future<void> _changeUserStatus(
      ChangeUserStatus changeUserStatusData,
      Emitter<UserApprovalsState> emit,
  ) async {
    if (state.pendingApprovalUsers.contains(changeUserStatusData.user) ||
        state.pendingRejectionUsers.contains(changeUserStatusData.user)) {
      return;
    }

    if (changeUserStatusData.isApproved) {
      emit(state.copyWith(
        pendingApprovalUsers: [
          ...state.pendingApprovalUsers,
          changeUserStatusData.user,
        ],
      ),);
    } else {
      emit(state.copyWith(
        pendingRejectionUsers: [
          ...state.pendingRejectionUsers,
          changeUserStatusData.user,
        ],
      ),);
    }

    try {
      await userRepository.changeUserApprovalStatus(
        userId: changeUserStatusData.user.id,
        isApproved: changeUserStatusData.isApproved,
      );

      changeUserStatusData.onSuccess?.call();
    } on RequestFailedException catch(e) {
      changeUserStatusData.onError?.call(e);
    } finally {
      emit(state.copyWith(
        pendingApprovalUsers: state.pendingApprovalUsers
            .whereNot((user) => user.id == changeUserStatusData.user.id)
            .toList(),
        pendingRejectionUsers: state.pendingRejectionUsers
            .whereNot((user) => user.id == changeUserStatusData.user.id)
            .toList(),
      ),);
    }
  }

  void _removeUser(RemoveUser removeUserData, Emitter<UserApprovalsState> emit) {
    emit(state.copyWith(
      userApprovals: state.userApprovals
          .whereNot((user) => user.id == removeUserData.userId)
          .toList(),
      pageInfo: state.pageInfo.copyWith(
        totalResults: state.pageInfo.totalResults - 1,
      ),
    ),);
  }
}
