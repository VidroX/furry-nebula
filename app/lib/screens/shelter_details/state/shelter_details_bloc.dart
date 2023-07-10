import 'package:ferry/ferry.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/graphql/exceptions/request_failed_exception.dart';
import 'package:furry_nebula/models/shelter/shelter.dart';
import 'package:furry_nebula/repositories/shelter/shelter_repository.dart';

part 'shelter_details_bloc.freezed.dart';
part 'shelter_details_event.dart';
part 'shelter_details_state.dart';

class ShelterDetailsBloc extends Bloc<ShelterDetailsEvent, ShelterDetailsState> {
  final ShelterRepository shelterRepository;

  ShelterDetailsBloc({ required this.shelterRepository }) : super(const ShelterDetailsState()) {
    on<ShelterDetailsEvent>((events, emit) async =>
        events.map(
          getShelterById: (getShelterData) =>
              _getShelterById(getShelterData, emit),
          setShelter: (setShelterData) =>
              _setShelter(setShelterData, emit),
        ),
    );
  }

  Future<void> _getShelterById(
      GetShelterById getShelterData,
      Emitter<ShelterDetailsState> emit,
  ) async {
    if (state.isLoading) {
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      final shelter = await shelterRepository.getShelterById(getShelterData.id);

      emit(state.copyWith(shelter: shelter));

      getShelterData.onSuccess?.call(shelter);
    } on RequestFailedException catch(e) {
      getShelterData.onError?.call(e);
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _setShelter(
      SetShelter setShelterData,
      Emitter<ShelterDetailsState> emit,
  ) async {
    emit(state.copyWith(shelter: setShelterData.shelter));
  }
}
