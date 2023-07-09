import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furry_nebula/models/shelter/animal_type.dart';
import 'package:furry_nebula/screens/home/shelters/pets/state/pets_bloc.dart';
import 'package:furry_nebula/screens/home/shelters/pets/state/pets_filter.dart';
import 'package:furry_nebula/services/injector.dart';

@RoutePage()
class PetsScreen extends StatefulWidget {
  static const routePath = 'pets';

  final PetsFilter filters;

  PetsScreen({
    @queryParam String? selectedShelter,
    @queryParam List<String>? selectedShelters,
    @queryParam AnimalType? animalType,
    super.key,
  }) : filters = PetsFilter(
    animalType: animalType,
    selectedShelter: selectedShelter,
    selectedShelters: selectedShelters,
  );

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  late PetsFilter _localFilters;

  final _bloc = injector.get<PetsBloc>();

  @override
  void initState() {
    _localFilters = widget.filters;
    _bloc.add(PetsEvent.getAnimals(filters: widget.filters));

    super.initState();
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => _bloc,
    child: BlocBuilder<PetsBloc, PetsState>(
      builder: (context, state) => const Placeholder(),
    ),
  );
}
