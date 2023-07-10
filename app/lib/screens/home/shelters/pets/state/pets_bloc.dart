import 'package:ferry/ferry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/graphql/exceptions/request_failed_exception.dart';
import 'package:furry_nebula/models/pagination/graph_page.dart';
import 'package:furry_nebula/models/pagination/pagination.dart';
import 'package:furry_nebula/models/photo_object.dart';
import 'package:furry_nebula/models/shelter/add_shelter_animal_data.dart';
import 'package:furry_nebula/models/shelter/shelter_animal.dart';
import 'package:furry_nebula/repositories/shelter/shelter_repository.dart';
import 'package:furry_nebula/screens/home/shelters/pets/state/pets_filter.dart';

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
          setFilters: (filtersData) =>
              _setFilters(filtersData, emit),
          addPet: (petData) =>
              _addPet(petData, emit),
          removePet: (removePetData) =>
              _removePet(removePetData, emit),
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

    if (getShelterAnimalsData.clearFetch) {
      emit(state.copyWith(
        shelterAnimals: [],
        pageInfo: const GraphPageInfo(),
        pagination: const Pagination(),
        filters: const PetsFilter(),
      ),);
    }

    if (getShelterAnimalsData.filters != null) {
      emit(state.copyWith(filters: getShelterAnimalsData.filters!));
    }

    emit(state.copyWith(isLoading: true));

    try {
      final animals = await shelterRepository.getShelterAnimals(
        pagination: state.pagination,
        filters: state.filters,
        shouldGetFromCacheFirst: !getShelterAnimalsData.clearFetch,
      );

      emit(state.copyWith(
        shelterAnimals: getShelterAnimalsData.clearFetch
            ? animals.nodes
            : [...state.shelterAnimals, ...animals.nodes],
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
      clearFetch: false,
      filters: nextPageData.filters,
      onSuccess: nextPageData.onSuccess,
      onError: nextPageData.onError,
    ),);
  }

  Future<void> _setFilters(
      SetFilters filtersData,
      Emitter<PetsState> emit,
  ) async {
    emit(state.copyWith(filters: filtersData.filters));
  }

  Future<void> _addPet(
      AddPet petData,
      Emitter<PetsState> emit,
  ) async {
    if (state.isAddingPet) {
      return;
    }

    emit(state.copyWith(isAddingPet: true));

    try {
      final shelterAnimal = await shelterRepository.addShelterAnimal(
        shelterId: petData.shelterId,
        name: petData.petData.object.name,
        description: petData.petData.object.description,
        animalType: petData.petData.object.animalType,
        photo: petData.petData.photo,
      );

      petData.onSuccess?.call(shelterAnimal);
    } on ServerException catch(e) {
      petData.onError?.call(e);
    } finally {
      emit(state.copyWith(isAddingPet: false));
    }
  }

  Future<void> _removePet(
      RemovePet removePetData,
      Emitter<PetsState> emit,
  ) async {
    if (state.isRemovingPet) {
      return;
    }

    emit(state.copyWith(isRemovingPet: true));

    try {
      await shelterRepository.removeShelterAnimal(
        shelterAnimalId: removePetData.pet.id,
      );

      removePetData.onSuccess?.call();
    } on ServerException catch(e) {
      removePetData.onError?.call(e);
    } finally {
      emit(state.copyWith(isRemovingPet: false));
    }
  }
}
