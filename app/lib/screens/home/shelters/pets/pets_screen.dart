import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/models/shelter/animal_type.dart';
import 'package:furry_nebula/models/shelter/shelter_animal.dart';
import 'package:furry_nebula/router/router.gr.dart';
import 'package:furry_nebula/screens/home/shelters/pets/state/pets_bloc.dart';
import 'package:furry_nebula/screens/home/shelters/pets/state/pets_filter.dart';
import 'package:furry_nebula/screens/home/shelters/pets/widgets/pet_filters_dialog.dart';
import 'package:furry_nebula/screens/home/shelters/widgets/image_card.dart';
import 'package:furry_nebula/services/injector.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/layout/dialog_layout.dart';
import 'package:furry_nebula/widgets/not_found.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_api_grid.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_circular_button.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';

@RoutePage()
class PetsScreen extends StatefulWidget {
  static const routePath = 'pets';

  final String? selectedShelter;
  final List<String>? selectedShelters;
  final AnimalType? animalType;

  const PetsScreen({
    @QueryParam('selectedShelterId') this.selectedShelter,
    @QueryParam('selectedShelterIds') this.selectedShelters,
    @QueryParam('animalType') this.animalType,
    super.key,
  });

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  GlobalKey<NebulaApiGridState> _gridKey = GlobalKey();

  final _bloc = injector.get<PetsBloc>();

  bool _firstLoad = true;

  @override
  void initState() {
    _bloc.add(PetsEvent.getAnimals(
      filters: PetsFilter(
        selectedShelter: widget.selectedShelter,
        selectedShelters: widget.selectedShelters,
        animalType: widget.animalType,
      ),
      onSuccess: (_) => _firstLoad = false,
    ),);

    super.initState();
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => _bloc,
    child: BlocBuilder<PetsBloc, PetsState>(
      builder: (context, state) => NebulaApiGrid<ShelterAnimal>(
        key: _gridKey,
        padding: const EdgeInsets.all(16),
        items: state.shelterAnimals,
        pageInfo: state.pageInfo,
        itemsLoading: _firstLoad || state.isLoading,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: context.isLandscape ? 4 : 2,
          mainAxisExtent: context.isLandscape ? 150 : 200,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
        ),
        onRefresh: () {
          _fetchPets(rebuildList: true, filters: state.filters);

          return Future<bool>.value(state.isLoading);
        },
        headerBuilder: (context) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: NebulaText(
                  context.translate(Translations.petsTitle),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography
                      .withFontWeight(FontWeight.w600)
                      .withFontSize(AppFontSize.extraLarge),
                ),
              ),
              NebulaCircularButton(
                buttonStyle: NebulaCircularButtonStyle.clear(context),
                onPress: () => _showFiltersDialog(state.filters),
                padding: EdgeInsets.zero,
                child: FaIcon(
                  FontAwesomeIcons.filter,
                  size: 20,
                  color: context.colors.text,
                ),
              ),
            ],
          ),
        ),
        noItemsBuilder: (context) => NotFound(
          icon: FontAwesomeIcons.paw,
          title: state.filters.isEmpty
              ? context.translate(Translations.petsNoPetsFound)
              : context.translate(Translations.petsNoPetsFoundWithFilters),
          onRefreshPress: () =>
              _fetchPets(rebuildList: true, filters: state.filters),
        ),
        onLoadNextPage: _loadNextPage,
        itemBuilder: (context, item, index) => ImageCard(
          title: item.name,
          imageUrl: item.photo,
          onTap: () => _openAnimalDetails(item),
        ),
      ),
    ),
  );

  void _fetchPets({ bool rebuildList = false, PetsFilter? filters }) {
    if (rebuildList) {
      setState(() {
        _gridKey = GlobalKey();
        _firstLoad = true;
      });
    }

    _bloc.add(PetsEvent.getAnimals(
      clearFetch: rebuildList,
      filters: filters,
      onSuccess: (_) {
        setState(() {
          _firstLoad = false;
        });
      },
      onError: context.showApiError,
    ),);
  }

  void _loadNextPage() {
    _bloc.add(PetsEvent.nextPage(
      onError: context.showApiError,
    ),);
  }

  Future<void> _showFiltersDialog(PetsFilter currentFilters) async {
    if (!mounted) {
      return;
    }

    final filters = await showNebulaDialog<PetsFilter>(
      context: context,
      title: context.translate(Translations.filters),
      child: PetFiltersDialog(currentFilters: currentFilters),
    );

    if (!mounted || filters == null) {
      return;
    }

    _fetchPets(rebuildList: true, filters: filters);
  }

  Future<void> _openAnimalDetails(ShelterAnimal animal) async {
    if (!mounted) {
      return;
    }

    final isRefreshNeeded = await context.pushRoute<bool>(
      PetDetailsRoute(shelterAnimalId: animal.id, shelterAnimal: animal),
    );

    if (!mounted || isRefreshNeeded == null || !isRefreshNeeded) {
      return;
    }

    _fetchPets(rebuildList: true);
  }
}
