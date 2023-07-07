import 'package:ferry/ferry.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/graphql/exceptions/request_failed_exception.dart';
import 'package:furry_nebula/models/pagination/graph_page.dart';
import 'package:furry_nebula/models/pagination/pagination.dart';
import 'package:furry_nebula/models/photo_object.dart';
import 'package:furry_nebula/models/shelter/add_shelter_data.dart';
import 'package:furry_nebula/models/shelter/shelter.dart';
import 'package:furry_nebula/repositories/shelter/shelter_repository.dart';

part 'shelters_bloc.freezed.dart';
part 'shelters_event.dart';
part 'shelters_state.dart';

class SheltersBloc extends Bloc<SheltersEvent, SheltersState> {
  final ShelterRepository shelterRepository;

  SheltersBloc({ required this.shelterRepository }) : super(const SheltersState()) {
    on<SheltersEvent>((events, emit) async =>
        events.map(
          getShelters: (getSheltersData) =>
              _getShelters(getSheltersData, emit),
          nextPage: (nextPageData) =>
              _nextPage(nextPageData, emit),
          addShelter: (addShelterData) =>
              _addShelter(addShelterData, emit),
        ),
    );
  }

  Future<void> _getShelters(
      GetShelters getSheltersData,
      Emitter<SheltersState> emit,
  ) async {
    if (state.isLoading) {
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      final shelters = await shelterRepository.getShelters(
        pagination: state.pagination,
        showOnlyOwnShelters: getSheltersData.showOnlyOwnShelters,
      );

      emit(state.copyWith(
        shelters: [...state.shelters, ...shelters.nodes],
        pageInfo: shelters.pageInfo,
      ),);

      getSheltersData.onSuccess?.call(shelters);
    } on RequestFailedException catch(e) {
      getSheltersData.onError?.call(e);
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _nextPage(
      GetSheltersNextPage nextPageData,
      Emitter<SheltersState> emit,
  ) async {
    if (!state.pageInfo.hasNextPage || state.isLoading) {
      return;
    }

    emit(state.copyWith(pagination: state.pagination.nextPage));

    add(SheltersEvent.getShelters(
      showOnlyOwnShelters: nextPageData.showOnlyOwnShelters,
      onSuccess: nextPageData.onSuccess,
      onError: nextPageData.onError,
    ),);
  }

  Future<void> _addShelter(
      AddShelter addShelterData,
      Emitter<SheltersState> emit,
  ) async {
    if (state.isAddingShelter) {
      return;
    }

    emit(state.copyWith(isAddingShelter: true));

    try {
      final shelter = await shelterRepository.addShelter(
        name: addShelterData.shelterData.object.name,
        address: addShelterData.shelterData.object.address,
        info: addShelterData.shelterData.object.info,
        photo: addShelterData.shelterData.photo,
      );

      emit(state.copyWith(
        shelters: [shelter, ...state.shelters],
      ),);

      addShelterData.onSuccess?.call(shelter);
    } on RequestFailedException catch(e) {
      addShelterData.onError?.call(e);
    } finally {
      emit(state.copyWith(isAddingShelter: false));
    }
  }
}