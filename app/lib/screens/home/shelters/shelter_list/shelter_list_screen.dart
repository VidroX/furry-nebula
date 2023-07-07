import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/graphql/exceptions/general_api_exception.dart';
import 'package:furry_nebula/graphql/exceptions/request_failed_exception.dart';
import 'package:furry_nebula/models/photo_object.dart';
import 'package:furry_nebula/models/shelter/add_shelter_data.dart';
import 'package:furry_nebula/models/shelter/shelter.dart';
import 'package:furry_nebula/models/user/user_role.dart';
import 'package:furry_nebula/screens/home/shelters/shelter_list/widgets/add_shelter_modal.dart';
import 'package:furry_nebula/screens/home/shelters/state/shelters_bloc.dart';
import 'package:furry_nebula/screens/home/shelters/widgets/image_card.dart';
import 'package:furry_nebula/screens/home/state/user_bloc.dart';
import 'package:furry_nebula/services/injector.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/layout/modal_layout.dart';
import 'package:furry_nebula/widgets/ui/loading_barrier.dart';
import 'package:furry_nebula/widgets/ui/nebula_api_grid.dart';
import 'package:furry_nebula/widgets/ui/nebula_circular_button.dart';
import 'package:furry_nebula/widgets/ui/nebula_notification.dart';
import 'package:furry_nebula/widgets/ui/nebula_text.dart';

@RoutePage()
class ShelterListScreen extends StatefulWidget {
  static const routePath = '';

  const ShelterListScreen({super.key});

  @override
  State<ShelterListScreen> createState() => _ShelterListScreenState();
}

class _ShelterListScreenState extends State<ShelterListScreen> {
  final _bloc = injector.get<SheltersBloc>();

  late final UserBloc _userBloc;

  bool _firstLoad = true;

  @override
  void initState() {
    super.initState();

    _userBloc = BlocProvider.of<UserBloc>(context);

    _bloc.add(SheltersEvent.getShelters(
      showOnlyOwnShelters: !_userBloc.state.hasRole(UserRole.admin),
      onSuccess: (_) => _firstLoad = false,
      onError: (e) {
        if (e is RequestFailedException) {
          context.showNotification(
            NebulaNotification.error(
              title: context.translate(Translations.error),
              description: context.translate(e.message),
            ),
          );
        }
      },
    ),);
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<SheltersBloc, SheltersState>(
    bloc: _bloc,
    builder: (context, state) => LoadingBarrier(
      loading: state.isAddingShelter,
      title: context.translate(Translations.sheltersAddingNewShelter),
      child: NebulaApiGrid<Shelter>(
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
        noItemsBuilder: (context) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.tents,
                size: 128,
                color: context.colors.hint,
              ),
              const SizedBox(height: 32),
              NebulaText(
                context.translate(
                  Translations.sheltersNoSheltersAdded,
                ),
                maxLines: 3,
                textAlign: TextAlign.center,
                style: context.typography
                    .withFontWeight(FontWeight.w500)
                    .withFontSize(AppFontSize.extraNormal)
                    .withColor(context.colors.hint),
              ),
            ],
          ),
        ),
        onLoadNextPage: _loadNextPage,
        itemBuilder: (context, item, index) => ImageCard(
          title: item.name,
          imageUrl: item.photo,
        ),
      ),
    ),
  );

  void _loadNextPage() {
    _bloc.add(SheltersEvent.nextPage(
      showOnlyOwnShelters: !_userBloc.state.hasRole(UserRole.admin),
      onError: (e) {
        if (e is RequestFailedException) {
          context.showNotification(
            NebulaNotification.error(
              title: context.translate(Translations.error),
              description: context.translate(e.message),
            ),
          );
        }
      },
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
      onError: (e) => e != null && e is GeneralApiException
          ? context.showNotification(
              NebulaNotification.error(
                title: context.translate(Translations.error),
                description: context.translate(e.messages[0]),
              ),
            )
          : null,
    ),);
  }
}
