import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/models/shelter/shelter_animal.dart';
import 'package:furry_nebula/screens/pet_details/state/pet_details_bloc.dart';
import 'package:furry_nebula/services/injector.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/layout/screen_layout.dart';
import 'package:furry_nebula/widgets/not_found.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';

@RoutePage()
class PetDetailsScreen extends StatefulWidget {
  static const routePath = 'pet/:id';

  final String shelterAnimalId;
  final ShelterAnimal? shelterAnimal;

  const PetDetailsScreen({
    @PathParam('id') required this.shelterAnimalId,
    this.shelterAnimal,
    super.key,
  });

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  final _bloc = injector.get<PetDetailsBloc>();

  bool _firstLoad = true;

  @override
  void initState() {
    if (widget.shelterAnimal != null) {
      _bloc.add(PetDetailsEvent.setShelterAnimal(
        shelterAnimal: widget.shelterAnimal!,
      ),);
      _firstLoad = false;
    } else {
      _bloc.add(PetDetailsEvent.getShelterAnimalById(
        id: widget.shelterAnimalId,
        onError: (_) => _firstLoad = false,
        onSuccess: (_) => _firstLoad = false,
      ),);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) => ScreenLayout(
    child: BlocBuilder<PetDetailsBloc, PetDetailsState>(
      bloc: _bloc,
      builder: (context, state) {
        if (_firstLoad || state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.shelterAnimal == null) {
          return NotFound(
            title: context.translate(Translations.petDetailsErrorsNotFound),
            icon: FontAwesomeIcons.paw,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NebulaText(state.shelterAnimal!.id),
            NebulaText(state.shelterAnimal!.name),
          ],
        );
      },
    ),
  );
}
