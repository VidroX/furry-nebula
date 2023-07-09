import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/models/photo_object.dart';
import 'package:furry_nebula/models/shelter/add_shelter_data.dart';
import 'package:furry_nebula/models/shelter/shelter.dart';
import 'package:furry_nebula/models/user/user_role.dart';
import 'package:furry_nebula/router/router.gr.dart';
import 'package:furry_nebula/screens/home/shelters/shelter_list/widgets/add_shelter_modal.dart';
import 'package:furry_nebula/screens/home/shelters/state/shelters_bloc.dart';
import 'package:furry_nebula/screens/home/shelters/widgets/image_card.dart';
import 'package:furry_nebula/screens/home/state/user_bloc.dart';
import 'package:furry_nebula/services/injector.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/layout/modal_layout.dart';
import 'package:furry_nebula/widgets/not_found.dart';
import 'package:furry_nebula/widgets/ui/loading_barrier.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_api_grid.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_circular_button.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';

@RoutePage()
class ShelterListScreen extends StatefulWidget {
  static const routePath = '';

  const ShelterListScreen({super.key});

  @override
  State<ShelterListScreen> createState() => _ShelterListScreenState();
}

class _ShelterListScreenState extends State<ShelterListScreen> {
  GlobalKey<NebulaApiGridState> _gridKey = GlobalKey();

  final _bloc = injector.get<SheltersBloc>();

  late final UserBloc _userBloc;

  bool _firstLoad = true;

  @override
  void initState() {
    super.initState();

    _userBloc = BlocProvider.of<UserBloc>(context);

    _fetchShelters();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<SheltersBloc, SheltersState>(
    bloc: _bloc,
    builder: (context, state) => LoadingBarrier(
      loading: state.isAddingShelter,
      title: context.translate(Translations.sheltersAddingNewShelter),
      child: NebulaApiGrid<Shelter>(
        key: _gridKey,
        padding: const EdgeInsets.all(16),
        items: state.shelters,
        pageInfo: state.pageInfo,
        itemsLoading: _firstLoad || state.isLoading,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: context.isLandscape ? 4 : 2,
          mainAxisExtent: context.isLandscape ? 150 : 200,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
        ),
        headerBuilder: (context) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NebulaText(
                context.translate(Translations.sheltersTitle),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.typography
                    .withFontWeight(FontWeight.w600)
                    .withFontSize(AppFontSize.extraLarge),
              ),
              NebulaCircularButton(
                buttonStyle: NebulaCircularButtonStyle.clear(context),
                onPress: _showAddModal,
                padding: EdgeInsets.zero,
                child: Icon(
                  Icons.add,
                  size: 32,
                  color: context.colors.text,
                ),
              ),
            ],
          ),
        ),
        noItemsBuilder: (context) => NotFound(
          title: context.translate(
            Translations.sheltersNoSheltersAdded,
          ),
          icon: FontAwesomeIcons.tents,
        ),
        onLoadNextPage: _loadNextPage,
        itemBuilder: (context, item, index) => ImageCard(
          title: item.name,
          imageUrl: item.photo,
          onTap: () => _openShelterDetails(item),
        ),
      ),
    ),
  );

  void _fetchShelters({ bool rebuildList = false }) {
    if (rebuildList) {
      setState(() {
        _gridKey = GlobalKey();
        _firstLoad = true;
      });
    }

    _bloc.add(SheltersEvent.getShelters(
      showOnlyOwnShelters: !_userBloc.state.hasRole(UserRole.admin),
      onSuccess: (_) {
        setState(() {
          _firstLoad = false;
        });
      },
      onError: context.showApiError,
    ),);
  }

  void _loadNextPage() {
    _bloc.add(SheltersEvent.nextPage(
      showOnlyOwnShelters: !_userBloc.state.hasRole(UserRole.admin),
      onError: context.showApiError,
    ),);
  }

  Future<void> _showAddModal() async {
    if (!mounted) {
      return;
    }

    final shelter = await showNebulaBottomModal<PhotoObject<AddShelterData>>(
      context: context,
      title: context.translate(Translations.sheltersAddShelter),
      child: const AddShelterModal(),
    );

    if (!mounted || shelter == null) {
      return;
    }

    _bloc.add(SheltersEvent.addShelter(
      shelterData: shelter,
      onSuccess: (_) => _fetchShelters(rebuildList: true),
      onError: context.showApiError,
    ),);
  }

  Future<void> _openShelterDetails(Shelter shelter) async {
    if (!mounted) {
      return;
    }

    final isRefreshNeeded = await context.pushRoute<bool>(
      ShelterDetailsRoute(shelterId: shelter.id, shelter: shelter),
    );

    if (!mounted || isRefreshNeeded == null || !isRefreshNeeded) {
      return;
    }

    _fetchShelters(rebuildList: true);
  }
}
