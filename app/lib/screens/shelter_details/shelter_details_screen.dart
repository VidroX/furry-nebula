import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/models/photo_object.dart';
import 'package:furry_nebula/models/shelter/add_shelter_animal_data.dart';
import 'package:furry_nebula/models/shelter/shelter.dart';
import 'package:furry_nebula/models/user/user_role.dart';
import 'package:furry_nebula/router/router.gr.dart';
import 'package:furry_nebula/screens/home/shelters/pets/state/pets_bloc.dart';
import 'package:furry_nebula/screens/home/shelters/pets/state/pets_filter.dart';
import 'package:furry_nebula/screens/home/shelters/state/shelters_bloc.dart';
import 'package:furry_nebula/screens/home/state/user_bloc.dart';
import 'package:furry_nebula/screens/shelter_details/state/shelter_details_bloc.dart';
import 'package:furry_nebula/screens/shelter_details/widgets/add_pet_modal.dart';
import 'package:furry_nebula/screens/shelter_details/widgets/delete_shelter_dialog.dart';
import 'package:furry_nebula/services/injector.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/layout/dialog_layout.dart';
import 'package:furry_nebula/widgets/layout/modal_layout.dart';
import 'package:furry_nebula/widgets/layout/screen_layout.dart';
import 'package:furry_nebula/widgets/not_found.dart';
import 'package:furry_nebula/widgets/ui/loading_barrier.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_button.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_circular_button.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_image.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_notification.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';
import 'package:furry_nebula/widgets/ui/neumorphic_container.dart';

@RoutePage<bool>()
class ShelterDetailsScreen extends StatefulWidget {
  static const routePath = 'shelter/:id';

  final String shelterId;
  final Shelter? shelter;

  const ShelterDetailsScreen({
    @PathParam('id') required this.shelterId,
    this.shelter,
    super.key,
  });

  @override
  State<ShelterDetailsScreen> createState() => _ShelterDetailsScreenState();
}

class _ShelterDetailsScreenState extends State<ShelterDetailsScreen> {
  final _bloc = injector.get<ShelterDetailsBloc>();
  final _sheltersBloc = injector.get<SheltersBloc>();
  final _petsBloc = injector.get<PetsBloc>();

  late final PetsFilter _filters;

  bool _firstLoad = true;

  bool _canEditShelter(UserState userState, Shelter shelter) =>
      userState.user != null
      && userState.hasRole(UserRole.shelter)
      && (
          userState.user!.id == shelter.representativeUser.id ||
          userState.hasRole(UserRole.admin)
      );

  @override
  void initState() {
    if (widget.shelter != null) {
      _bloc.add(ShelterDetailsEvent.setShelter(shelter: widget.shelter!));

      _filters = PetsFilter(
        selectedShelter: widget.shelter!.id,
      );

      _petsBloc.add(
        PetsEvent.getAnimals(
          filters: _filters,
        ),
      );

      _firstLoad = false;
    } else {
      _bloc.add(ShelterDetailsEvent.getShelterById(
        id: widget.shelterId,
        onError: (_) => _firstLoad = false,
        onSuccess: (shelter) {
          _filters = PetsFilter(
            selectedShelter: shelter.id,
          );

          _petsBloc.add(
            PetsEvent.getAnimals(
              filters: _filters,
            ),
          );

          _firstLoad = false;
        },
      ),);
    }

    super.initState();
  }

  bool _isImagePresent(String? photo) => photo != null
      && photo.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) => ScreenLayout(
    padding: EdgeInsets.zero,
    child: BlocBuilder<SheltersBloc, SheltersState>(
      bloc: _sheltersBloc,
      builder: (context, sheltersState) => BlocBuilder<PetsBloc, PetsState>(
        bloc: _petsBloc,
        builder: (context, petsState) => BlocBuilder<ShelterDetailsBloc, ShelterDetailsState>(
          bloc: _bloc,
          builder: (context, state) {
            if (_firstLoad || state.isLoading || petsState.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state.shelter == null) {
              return NotFound(
                title: context.translate(Translations.shelterDetailsErrorsNotFound),
                icon: FontAwesomeIcons.tent,
              );
            }

            return LoadingBarrier(
              loading: petsState.isAddingPet || sheltersState.isDeletingShelter,
              title: sheltersState.isDeletingShelter ? context.translate(
                Translations.shelterDetailsDeleteProgress,
                params: {
                  'shelter': state.shelter!.name,
                },
              ) : context.translate(
                Translations.shelterDetailsAddAnimalAddProgress,
              ),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    collapsedHeight: ScreenLayout.defaultPadding.vertical + 48,
                    expandedHeight: MediaQuery.of(context).size.height / 3,
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: Stack(
                      children: [
                        Positioned.fill(
                          child: NebulaImage(
                            url: state.shelter!.photo,
                            fit: BoxFit.cover,
                          ),
                        ),
                        BlocBuilder<UserBloc, UserState>(
                          builder: (context, userState) => PositionedDirectional(
                            top: ScreenLayout.defaultPadding.top,
                            end: ScreenLayout.defaultPadding.end,
                            start: ScreenLayout.defaultPadding.start,
                            child: Row(
                              children: [
                                NebulaCircularButton(
                                  buttonStyle: _isImagePresent(state.shelter!.photo)
                                      ? NebulaCircularButtonStyle.background(context)
                                      : NebulaCircularButtonStyle.container(context),
                                  onPress: () => context.popRoute(),
                                  padding: EdgeInsets.zero,
                                  child: FaIcon(
                                    FontAwesomeIcons.arrowLeftLong,
                                    size: 16,
                                    color: context.colors.text,
                                  ),
                                ),
                                const Spacer(),
                                if (_canEditShelter(userState, state.shelter!)) ...[
                                  NebulaCircularButton(
                                    buttonStyle: NebulaCircularButtonStyle.error(context),
                                    onPress: () => _onDeleteClicked(state.shelter!),
                                    padding: EdgeInsets.zero,
                                    child: FaIcon(
                                      FontAwesomeIcons.trash,
                                      size: 16,
                                      color: context.colors.text,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  NebulaCircularButton(
                                    buttonStyle: _isImagePresent(state.shelter!.photo)
                                        ? NebulaCircularButtonStyle.background(context)
                                        : NebulaCircularButtonStyle.container(context),
                                    onPress: () => _onAddClicked(state.shelter!),
                                    padding: EdgeInsets.zero,
                                    child: FaIcon(
                                      FontAwesomeIcons.plus,
                                      size: 16,
                                      color: context.colors.text,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: ScreenLayout.defaultPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NebulaText(
                            state.shelter!.name,
                            style: context.typography
                                .withFontSize(AppFontSize.large)
                                .withFontWeight(FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                child: Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.locationPin,
                                    color: context.colors.text,
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: NebulaText(
                                  state.shelter!.address.trim(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                child: Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.paw,
                                    color: context.colors.text,
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (petsState.isLoading)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                    ),
                                  ),
                                )
                              else
                                Expanded(
                                  child: NebulaText(
                                    petsState.pageInfo.totalResults.toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                          if (state.shelter?.info != null &&
                              state.shelter!.info.trim().isNotEmpty)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(top: 24),
                              child: NeumorphicContainer(
                                width: double.maxFinite,
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    NebulaText(
                                      context.translate(Translations.sheltersDescription),
                                      style: context.typography
                                          .withFontSize(AppFontSize.extraNormal)
                                          .withFontWeight(FontWeight.w500),
                                    ),
                                    const SizedBox(height: 12),
                                    NebulaText(state.shelter!.info.trim()),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          NebulaButton.fill(
                            text: context.translate(
                              Translations.shelterDetailsViewShelterAnimals,
                            ),
                            onPress: () =>
                                context.router.pushAndPopUntil(
                                  PetsRoute(
                                    selectedShelter: _filters.selectedShelter,
                                    selectedShelters: _filters.selectedShelters,
                                    animalType: _filters.animalType,
                                  ),
                                  predicate: (route) =>
                                    route.settings.name == HomeRoute.name,
                                ),
                            buttonStyle: NebulaButtonStyle.primary(context),
                            prefixChild: FaIcon(
                              FontAwesomeIcons.paw,
                              size: 16,
                              color: NebulaButtonStyle.primary(context)
                                  .textStyle
                                  .color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );

  Future<void> _onDeleteClicked(Shelter shelter) async {
    if (!mounted) {
      return;
    }

    final shouldDelete = await showNebulaDialog<bool>(
      context: context,
      title: context.translate(Translations.deleteConfirmation),
      child: DeleteShelterDialog(shelter: shelter),
    );

    if (!mounted || shouldDelete == null || !shouldDelete) {
      return;
    }

    _sheltersBloc.add(
      SheltersEvent.deleteShelter(
        shelter: shelter,
        onSuccess: () {
          context.showNotification(
            NebulaNotification.primary(
              title: context.translate(Translations.info),
              description: context.translate(
                Translations.shelterDetailsDeletedSuccessfully,
                params: {
                  'shelter': shelter.name,
                },
              ),
            ),
          );

          context.popRoute<bool>(true);
        },
        onError: context.showApiError,
      ),
    );
  }

  Future<void> _onAddClicked(Shelter shelter) async {
    if (!mounted) {
      return;
    }

    final shelterAnimal = await showNebulaBottomModal<PhotoObject<AddShelterAnimalData>>(
      context: context,
      title: context.translate(Translations.shelterDetailsAddAnimalTitle),
      child: const AddPetModal(),
    );

    if (!mounted || shelterAnimal == null) {
      return;
    }

    _petsBloc.add(PetsEvent.addPet(
      shelterId: shelter.id,
      petData: shelterAnimal,
      onSuccess: (_) {
        context.showNotification(
          NebulaNotification.primary(
            title: context.translate(Translations.info),
            description: context.translate(
              Translations.shelterDetailsAddAnimalSuccess,
            ),
          ),
        );

        _petsBloc.add(
          PetsEvent.getAnimals(
            filters: _filters,
          ),
        );
      },
      onError: context.showApiError,
    ),);
  }
}
