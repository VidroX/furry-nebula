import 'package:ferry/ferry.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/graphql/exceptions/request_failed_exception.dart';
import 'package:furry_nebula/models/pagination/graph_page.dart';
import 'package:furry_nebula/models/pagination/pagination.dart';
import 'package:furry_nebula/models/shelter/animal_type.dart';
import 'package:furry_nebula/models/shelter/shelter.dart';
import 'package:furry_nebula/models/shelter/shelter_animal.dart';
import 'package:furry_nebula/repositories/shelter/shelter_repository.dart';

part 'pets_bloc.freezed.dart';
part 'pets_event.dart';
part 'pets_state.dart';

class PetsBloc extends Bloc<PetsEvent, PetsState> {
  final ShelterRepository shelterRepository;

  PetsBloc({ required this.shelterRepository }) : super(const PetsState()) {
    on<PetsEvent>((events, emit) async =>
        events.map(
          getAnimals: (getAnimalsData) =>
              _getAnimals(getAnimalsData, emit),
          nextPage: (nextPageData) =>
              _nextPage(nextPageData, emit),
          setSheltersFilter: (setSheltersFilterData) =>
              _setSheltersFilter(setSheltersFilterData, emit),
          setAnimalTypeFilter: (setAnimalTypeFilterData) =>
              _setAnimalTypeFilter(setAnimalTypeFilterData, emit),
        ),
    );
  }

  Future<void> _getAnimals(
      GetAnimals getShelterAnimalsData,
      Emitter<PetsState> emit,
  ) async {
    if (state.isLoading) {
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      final animals = await shelterRepository.getShelterAnimals(
        pagination: state.pagination,
        animalType: state.selectedAnimalType,
      );

      emit(state.copyWith(
        shelterAnimals: [...state.shelterAnimals, ...animals.nodes],
        pageInfo: animals.pageInfo,
      ),);

      getShelterAnimalsData.onSuccess?.call(animals);
    } on RequestFailedException catch(e) {
      getShelterAnimalsData.onError?.call(e);
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _nextPage(
      GetAnimalsNextPage nextPageData,
      Emitter<PetsState> emit,
  ) async {
    if (!state.pageInfo.hasNextPage || state.isLoading) {
      return;
    }

    emit(state.copyWith(pagination: state.pagination.nextPage));

    add(PetsEvent.getAnimals(
      onSuccess: nextPageData.onSuccess,
      onError: nextPageData.onError,
    ),);
  }

  Future<void> _setSheltersFilter(
      SetSheltersFilter setSheltersFilterData,
      Emitter<PetsState> emit,
  ) async {
    emit(state.copyWith(selectedShelters: setSheltersFilterData.shelters));
  }

  Future<void> _setAnimalTypeFilter(
      SetAnimalTypeFilter setAnimalTypeFilterData,
      Emitter<PetsState> emit,
  ) async {
    emit(state.copyWith(selectedAnimalType: setAnimalTypeFilterData.animalType));
  }
}
