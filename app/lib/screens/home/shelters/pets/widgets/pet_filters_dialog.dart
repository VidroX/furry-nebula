import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/models/overlay_option.dart';
import 'package:furry_nebula/models/shelter/animal_type.dart';
import 'package:furry_nebula/models/shelter/shelter.dart';
import 'package:furry_nebula/screens/home/shelters/pets/state/pets_filter.dart';
import 'package:furry_nebula/screens/home/shelters/state/shelters_bloc.dart';
import 'package:furry_nebula/screens/shelter_details/state/shelter_details_bloc.dart';
import 'package:furry_nebula/services/injector.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_button.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_dropdown.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_link.dart';

class PetFiltersDialog extends StatefulWidget {
  final PetsFilter currentFilters;

  const PetFiltersDialog({
    this.currentFilters = const PetsFilter(),
    super.key,
  });

  @override
  State<PetFiltersDialog> createState() => _PetFiltersDialogState();
}

class _PetFiltersDialogState extends State<PetFiltersDialog> {
  final _bloc = injector.get<SheltersBloc>();
  final _shelterDetailsBloc = injector.get<ShelterDetailsBloc>();

  final _formKey = GlobalKey<FormState>();

  late final _animalTypeOptions = FilterAnimalType.values
      .map((e) => OverlayOption(
        data: e,
        title: e.translationKey,
      ),)
      .toList();

  late OverlayOption<FilterAnimalType>? _selectedAnimalType = _animalTypeOptions
      .firstWhere(
        (e) => e.data.name == widget.currentFilters.animalType?.name,
        orElse: () => _animalTypeOptions[0],
      );

  OverlayOption<Shelter>? _selectedShelter;

  late PetsFilter _filters = widget.currentFilters;

  @override
  void initState() {
    _bloc.add(SheltersEvent.getShelters(
      onSuccess: (shelters) {
        final shelter = shelters.nodes
            .firstWhereOrNull((e) => e.id == widget.currentFilters.selectedShelter);

        if (shelter == null && widget.currentFilters.selectedShelter != null) {
          _fetchSpecificShelter(widget.currentFilters.selectedShelter!);
        }

        _selectedShelter = shelter != null
            ? OverlayOption(
              data: shelter,
              title: shelter.name,
              uniqueIndex: shelter.id,
            )
            : null;
      },
    ),);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        NebulaDropdown<FilterAnimalType>(
          label: context.translate(Translations.animalTypesTitle),
          options: _animalTypeOptions,
          selectedOption: _selectedAnimalType,
          onOptionSelected: _onAnimalTypeSelected,
        ),
        const SizedBox(height: 12),
        BlocBuilder<SheltersBloc, SheltersState>(
          bloc: _bloc,
          builder: (context, state) => BlocBuilder<ShelterDetailsBloc, ShelterDetailsState>(
            bloc: _shelterDetailsBloc,
            builder: (context, detailsState) => NebulaDropdown<Shelter>(
              loading: state.isLoading || detailsState.isLoading,
              label: context.translate(Translations.petsShelter),
              options: state.shelters
                  .map((e) => OverlayOption(
                data: e,
                title: e.name,
                uniqueIndex: e.id,
              ),)
                  .toList(),
              selectedOption: _selectedShelter,
              onOptionSelected: _onShelterSelected,
              onListEndReached: _loadMoreShelters,
            ),
          ),
        ),
        const SizedBox(height: 16),
        NebulaLink(
          text: context.translate(Translations.clearFilters),
          onTap: _clearFilters,
        ),
        const SizedBox(height: 12),
        NebulaButton.fill(
          text:context.translate(Translations.apply),
          onPress: _apply,
        ),
      ],
    ),
  );

  void _clearFilters() {
    setState(() {
      _selectedAnimalType = _animalTypeOptions[0];
      _selectedShelter = null;
      _filters = const PetsFilter();
    });
  }

  void _onAnimalTypeSelected(OverlayOption<FilterAnimalType> animalType) {
    setState(() {
      _selectedAnimalType = animalType;
      _filters = _filters.copyWith(
        animalType: animalType.data.toAnimalType,
      );
    });
  }

  void _onShelterSelected(OverlayOption<Shelter> shelter) {
    setState(() {
      _selectedShelter = shelter;
      _filters = _filters.copyWith(
        selectedShelter: shelter.data.id,
      );
    });
  }

  void _apply() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.popRoute<PetsFilter>(_filters);
  }

  void _loadMoreShelters() {
    _bloc.add(SheltersEvent.nextPage(
      onError: context.showApiError,
    ),);
  }

  void _fetchSpecificShelter(String id) {
    _shelterDetailsBloc.add(
      ShelterDetailsEvent.getShelterById(
        id: id,
        onSuccess: (shelter) {
          setState(() {
            _selectedShelter = OverlayOption(
              data: shelter,
              title: shelter.name,
              uniqueIndex: shelter.id,
            );
          });
        },
      ),
    );
  }
}
