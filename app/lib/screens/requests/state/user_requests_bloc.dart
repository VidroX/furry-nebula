import 'package:ferry/ferry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/graphql/exceptions/request_failed_exception.dart';
import 'package:furry_nebula/models/pagination/graph_page.dart';
import 'package:furry_nebula/models/pagination/pagination.dart';
import 'package:furry_nebula/models/shelter/user_request.dart';
import 'package:furry_nebula/models/shelter/user_request_type.dart';
import 'package:furry_nebula/repositories/shelter/shelter_repository.dart';
import 'package:furry_nebula/screens/requests/state/user_requests_filters.dart';

part 'user_requests_bloc.freezed.dart';
part 'user_requests_event.dart';
part 'user_requests_state.dart';

class UserRequestsBloc extends Bloc<UserRequestsEvent, UserRequestsState> {
  final ShelterRepository shelterRepository;

  UserRequestsBloc({ required this.shelterRepository }) : super(const UserRequestsState()) {
    on<UserRequestsEvent>((events, emit) async =>
        events.map(
          getRequests: (getRequestsData) =>
              _getRequests(getRequestsData, emit),
          nextPage: (nextPageData) =>
              _nextPage(nextPageData, emit),
          setFilters: (filtersData) =>
              _setFilters(filtersData, emit),
          createRequest: (createRequestData) =>
              _createRequest(createRequestData, emit),
          changeRequestStatus: (changeRequestStatusData) =>
              _changeRequestStatus(changeRequestStatusData, emit),
          changeRequestFulfillmentStatus: (changeRequestFulfillmentStatusData) =>
              _changeRequestFulfillmentStatus(changeRequestFulfillmentStatusData, emit),
        ),
    );
  }

  Future<void> _getRequests(
      GetUserRequests getRequestsData,
      Emitter<UserRequestsState> emit,
  ) async {
    if (state.isLoading) {
      return;
    }

    emit(state.copyWith(isLoading: true));

    if (getRequestsData.clearFetch) {
      emit(state.copyWith(
        userRequests: [],
        pageInfo: const GraphPageInfo(),
        pagination: const Pagination(),
        filters: const UserRequestsFilters(),
      ),);
    }

    if (getRequestsData.filters != null) {
      emit(state.copyWith(filters: getRequestsData.filters!));
    }

    try {
      final userRequests = await shelterRepository.getUserRequests(
        pagination: state.pagination,
        filters: state.filters,
        shouldGetFromCacheFirst: !getRequestsData.clearFetch,
      );

      emit(state.copyWith(
        userRequests: getRequestsData.clearFetch
            ? userRequests.nodes
            : [...state.userRequests, ...userRequests.nodes],
        pageInfo: userRequests.pageInfo,
      ),);

      getRequestsData.onSuccess?.call(userRequests);
    } on RequestFailedException catch(e) {
      getRequestsData.onError?.call(e);
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _nextPage(
      GetUserRequestsNextPage nextPageData,
      Emitter<UserRequestsState> emit,
  ) async {
    if (!state.pageInfo.hasNextPage || state.isLoading) {
      return;
    }

    emit(state.copyWith(pagination: state.pagination.nextPage));

    add(UserRequestsEvent.getRequests(
      clearFetch: false,
      filters: nextPageData.filters,
      onSuccess: nextPageData.onSuccess,
      onError: nextPageData.onError,
    ),);
  }

  Future<void> _setFilters(
      SetRequestFilters filtersData,
      Emitter<UserRequestsState> emit,
  ) async {
    emit(state.copyWith(filters: filtersData.filters));
  }

  Future<void> _createRequest(
      CreateRequest createRequestData,
      Emitter<UserRequestsState> emit,
  ) async {
    if (state.isCreatingRequest) {
      return;
    }

    emit(state.copyWith(isCreatingRequest: true));

    try {
      final userRequest = await shelterRepository.createUserRequest(
        animalId: createRequestData.animalId,
        requestType: createRequestData.requestType,
        fromDate: createRequestData.fromDate,
        toDate: createRequestData.toDate,
      );

      createRequestData.onSuccess?.call(userRequest);
    } on ServerException catch(e) {
      createRequestData.onError?.call(e);
    } finally {
      emit(state.copyWith(isCreatingRequest: false));
    }
  }

  Future<void> _changeRequestStatus(
      ChangeRequestStatus changeRequestStatusData,
      Emitter<UserRequestsState> emit,
  ) async {
    if (state.isChangingStatus) {
      return;
    }

    emit(state.copyWith(isChangingStatus: true));

    try {
      await shelterRepository.changeUserRequestStatus(
        requestId: changeRequestStatusData.requestId,
        isApproved: changeRequestStatusData.isApproved,
      );

      changeRequestStatusData.onSuccess?.call();
    } on ServerException catch(e) {
      changeRequestStatusData.onError?.call(e);
    } finally {
      emit(state.copyWith(isChangingStatus: false));
    }
  }

  Future<void> _changeRequestFulfillmentStatus(
      ChangeRequestFulfillmentStatus changeRequestFulfillmentStatusData,
      Emitter<UserRequestsState> emit,
  ) async {
    if (state.isChangingStatus) {
      return;
    }

    emit(state.copyWith(isChangingStatus: true));

    try {
      await shelterRepository.changeUserRequestFulfillmentStatus(
        requestId: changeRequestFulfillmentStatusData.requestId,
        isFulfilled: changeRequestFulfillmentStatusData.isFulfilled,
      );

      changeRequestFulfillmentStatusData.onSuccess?.call();
    } on ServerException catch(e) {
      changeRequestFulfillmentStatusData.onError?.call(e);
    } finally {
      emit(state.copyWith(isChangingStatus: false));
    }
  }
}
