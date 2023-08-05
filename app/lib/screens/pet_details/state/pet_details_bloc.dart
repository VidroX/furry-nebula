import 'package:ferry/ferry.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/graphql/exceptions/request_failed_exception.dart';
import 'package:furry_nebula/models/shelter/shelter_animal.dart';
import 'package:furry_nebula/repositories/shelter/shelter_repository.dart';

part 'pet_details_bloc.freezed.dart';
part 'pet_details_event.dart';
part 'pet_details_state.dart';

class PetDetailsBloc extends Bloc<PetDetailsEvent, PetDetailsState> {
  final ShelterRepository shelterRepository;

  PetDetailsBloc({ required this.shelterRepository }) : super(const PetDetailsState()) {
    on<PetDetailsEvent>((events, emit) async =>
        events.map(
          getShelterAnimalById: (getShelterAnimalData) =>
              _getShelterAnimalById(getShelterAnimalData, emit),
          setShelterAnimal: (setShelterAnimalData) =>
              _setShelterAnimal(setShelterAnimalData, emit),
          updateShelterAnimalRating: (shelterAnimalRatingData) =>
              _updateShelterAnimalRating(shelterAnimalRatingData, emit),
        ),
    );
  }

  Future<void> _getShelterAnimalById(
      GetShelterAnimalById getShelterAnimalData,
      Emitter<PetDetailsState> emit,
  ) async {
    if (state.isLoading) {
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      final shelterAnimal = await shelterRepository.getShelterAnimalById(
        getShelterAnimalData.id,
      );

      emit(state.copyWith(shelterAnimal: shelterAnimal));

      getShelterAnimalData.onSuccess?.call(shelterAnimal);
    } on RequestFailedException catch(e) {
      getShelterAnimalData.onError?.call(e);
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _setShelterAnimal(
      SetShelterAnimal setShelterAnimalData,
      Emitter<PetDetailsState> emit,
  ) async {
    emit(state.copyWith(shelterAnimal: setShelterAnimalData.shelterAnimal));
  }

  Future<void> _updateShelterAnimalRating(
      UpdateShelterAnimalRating shelterAnimalRatingData,
      Emitter<PetDetailsState> emit,
  ) async {
    if (state.isUpdatingRating) {
      return;
    }

    emit(state.copyWith(isUpdatingRating: true));

    try {
      final shelterAnimal = await shelterRepository.updateAnimalRating(
        animalId: shelterAnimalRatingData.id,
        rating: shelterAnimalRatingData.rating,
      );

      emit(state.copyWith(shelterAnimal: shelterAnimal));

      shelterAnimalRatingData.onSuccess?.call(shelterAnimal);
    } on RequestFailedException catch(e) {
      shelterAnimalRatingData.onError?.call(e);
    } finally {
      emit(state.copyWith(isUpdatingRating: false));
    }
  }
}
