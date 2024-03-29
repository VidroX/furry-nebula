import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/models/shelter/shelter_animal.dart';
import 'package:furry_nebula/models/shelter/user_request_type.dart';
import 'package:furry_nebula/models/user/user_role.dart';
import 'package:furry_nebula/router/router.gr.dart';
import 'package:furry_nebula/screens/home/shelters/pets/state/pets_bloc.dart';
import 'package:furry_nebula/screens/home/state/user_bloc.dart';
import 'package:furry_nebula/screens/pet_details/state/pet_details_bloc.dart';
import 'package:furry_nebula/screens/pet_details/widgets/pet_accommodation_dialog.dart';
import 'package:furry_nebula/screens/pet_details/widgets/pet_adoption_dialog.dart';
import 'package:furry_nebula/screens/pet_details/widgets/remove_pet_dialog.dart';
import 'package:furry_nebula/screens/pet_details/widgets/update_pet_rating_dialog.dart';
import 'package:furry_nebula/screens/requests/state/user_requests_bloc.dart';
import 'package:furry_nebula/services/injector.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/layout/dialog_layout.dart';
import 'package:furry_nebula/widgets/layout/screen_layout.dart';
import 'package:furry_nebula/widgets/not_found.dart';
import 'package:furry_nebula/widgets/ui/loading_barrier.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_button.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_circular_button.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_image.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_link.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_notification.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';
import 'package:furry_nebula/widgets/ui/neumorphic_container.dart';

@RoutePage<bool>()
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
  final _petsBloc = injector.get<PetsBloc>();
  final _requestsBloc = injector.get<UserRequestsBloc>();

  bool _firstLoad = true;
  bool _reloadPetsScreen = false;

  bool _canEditShelterAnimal(UserState userState, ShelterAnimal animal) =>
      userState.user != null
          && userState.hasRole(UserRole.shelter)
          && (
              userState.user!.id == animal.shelter.representativeUser.id ||
              userState.hasRole(UserRole.admin)
          );

  bool _isImagePresent(String? photo) => photo != null
      && photo.trim().isNotEmpty;

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
    resizeToAvoidBottomInset: true,
    padding: EdgeInsets.zero,
    child: BlocBuilder<PetDetailsBloc, PetDetailsState>(
      bloc: _bloc,
      builder: (context, state) => BlocBuilder<PetsBloc, PetsState>(
        bloc: _petsBloc,
        builder: (context, petsState) {
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

          return LoadingBarrier(
            loading: petsState.isRemovingPet,
            title: context.translate(Translations.petDetailsRemoveProgress),
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
                          url: state.shelterAnimal!.photo,
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
                                buttonStyle: _isImagePresent(state.shelterAnimal!.photo)
                                    ? NebulaCircularButtonStyle.background(context)
                                    : NebulaCircularButtonStyle.container(context),
                                onPress: () =>
                                    context.popRoute<bool>(_reloadPetsScreen),
                                padding: EdgeInsets.zero,
                                child: FaIcon(
                                  FontAwesomeIcons.arrowLeftLong,
                                  size: 16,
                                  color: context.colors.text,
                                ),
                              ),
                              const Spacer(),
                              if (_canEditShelterAnimal(userState, state.shelterAnimal!))
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(end: 12),
                                  child: NebulaCircularButton(
                                    buttonStyle: NebulaCircularButtonStyle.error(context),
                                    onPress: () => _onRemoveClicked(state.shelterAnimal!),
                                    padding: EdgeInsets.zero,
                                    child: FaIcon(
                                      FontAwesomeIcons.trash,
                                      size: 16,
                                      color: context.colors.text,
                                    ),
                                  ),
                                ),
                              NebulaCircularButton(
                                buttonStyle: _isImagePresent(state.shelterAnimal!.photo)
                                    ? NebulaCircularButtonStyle.background(context)
                                    : NebulaCircularButtonStyle.container(context),
                                onPress: () => context.router.push(ShelterDetailsRoute(
                                  shelterId: state.shelterAnimal!.shelter.id,
                                  shelter: state.shelterAnimal!.shelter,
                                ),),
                                padding: EdgeInsets.zero,
                                child: FaIcon(
                                  FontAwesomeIcons.tent,
                                  size: 16,
                                  color: context.colors.text,
                                ),
                              ),
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
                          state.shelterAnimal!.name,
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
                                  FontAwesomeIcons.paw,
                                  color: context.colors.text,
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: NebulaText(
                                context.translate(
                                  state.shelterAnimal!.animalType.translationKey,
                                ),
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
                                  FontAwesomeIcons.tent,
                                  color: context.colors.text,
                                  size: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: NebulaText(
                                context.translate(
                                  state.shelterAnimal!.shelter.name,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            SizedBox(
                              width: 16,
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.solidStar,
                                  color: context.colors.text,
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!state.isUpdatingRating)
                              Expanded(
                                child: state.shelterAnimal!.canRate ? NebulaLink(
                                  text: state.shelterAnimal!.overallRating
                                      .toStringAsFixed(1),
                                  onTap: () =>
                                      _onRatingClick(state.shelterAnimal!),
                                ) : NebulaText(
                                  state.shelterAnimal!.overallRating
                                      .toStringAsFixed(1),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            else
                              SizedBox(
                                width: 16 * context.typography.lineHeight,
                                height: 16 * context.typography.lineHeight,
                                child: Center(
                                  child: Transform.scale(
                                    scale: 0.75,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                        if (state.shelterAnimal?.description != null &&
                            state.shelterAnimal!.description.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(top: 24),
                            child: NeumorphicContainer(
                              width: double.maxFinite,
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  NebulaText(
                                    context.translate(Translations.description),
                                    style: context.typography
                                        .withFontSize(AppFontSize.extraNormal)
                                        .withFontWeight(FontWeight.w500),
                                  ),
                                  const SizedBox(height: 12),
                                  NebulaText(state.shelterAnimal!.description.trim()),
                                ],
                              ),
                            ),
                          ),
                        BlocBuilder<UserBloc, UserState>(
                          builder: (context, userState) {
                            final shelterRep = state.shelterAnimal!
                                .shelter
                                .representativeUser;

                            if (userState.user?.id == shelterRep.id) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 24),
                                NebulaButton.fill(
                                  text: context.translate(
                                    Translations.userRequestRequestToAccommodate,
                                  ),
                                  onPress: () => _requestAccommodation(state.shelterAnimal!),
                                  buttonStyle: NebulaButtonStyle.primary(context),
                                ),
                                const SizedBox(height: 12),
                                NebulaButton.fill(
                                  text: context.translate(
                                    Translations.userRequestRequestToAdopt,
                                  ),
                                  onPress: () => _requestAdoption(state.shelterAnimal!),
                                  buttonStyle: NebulaButtonStyle.primary(context),
                                ),
                              ],
                            );
                          },
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
  );

  Future<void> _onRemoveClicked(ShelterAnimal pet) async {
    if (!mounted) {
      return;
    }

    final shouldRemove = await showNebulaDialog<bool>(
      context: context,
      title: context.translate(Translations.removeConfirmation),
      child: RemovePetDialog(pet: pet),
    );

    if (!mounted || shouldRemove == null || !shouldRemove) {
      return;
    }

    _petsBloc.add(
      PetsEvent.removePet(
        pet: pet,
        onSuccess: () {
          context.showNotification(
            NebulaNotification.primary(
              title: context.translate(Translations.info),
              description: context.translate(
                Translations.petDetailsRemovedSuccessfully,
                params: {
                  'animal': pet.name,
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

  Future<void> _requestAccommodation(ShelterAnimal pet) async {
    if (!mounted) {
      return;
    }

    final dateSet = await showNebulaDialog<PetAccommodationDateSet>(
      context: context,
      title: context.translate(Translations.userRequestCreateRequest),
      child: PetAccommodationDialog(pet: pet),
    );

    if (!mounted || dateSet == null) {
      return;
    }

    _requestsBloc.add(UserRequestsEvent.createRequest(
      animalId: pet.id,
      requestType: UserRequestType.accommodation,
      fromDate: dateSet.fromDate,
      toDate: dateSet.toDate,
      onSuccess: (userRequest) => context.showNotification(
        NebulaNotification.primary(
          title: context.translate(Translations.info),
          description: context.translate(Translations.userRequestAccommodationRequestSent),
        ),
      ),
      onError: context.showApiError,
    ),);
  }

  Future<void> _requestAdoption(ShelterAnimal pet) async {
    if (!mounted) {
      return;
    }

    final shouldSendRequest = await showNebulaDialog<bool>(
      context: context,
      title: context.translate(Translations.userRequestCreateRequest),
      child: PetAdoptionDialog(pet: pet),
    );

    if (!mounted || shouldSendRequest == null || !shouldSendRequest) {
      return;
    }

    _requestsBloc.add(UserRequestsEvent.createRequest(
      animalId: pet.id,
      requestType: UserRequestType.adoption,
      onSuccess: (userRequest) => context.showNotification(
        NebulaNotification.primary(
          title: context.translate(Translations.info),
          description: context.translate(Translations.userRequestAdoptionRequestSent),
        ),
      ),
      onError: context.showApiError,
    ),);
  }

  Future<void> _onRatingClick(ShelterAnimal pet) async {
    if (!mounted) {
      return;
    }

    final animalRating = await showNebulaDialog<double>(
      context: context,
      title: pet.userRating == null
          ? context.translate(Translations.petDetailsSetRating)
          : context.translate(Translations.petDetailsUpdateRating),
      child: UpdatePetRatingDialog(pet: pet),
    );

    if (!mounted || animalRating == null || animalRating < 1 || animalRating > 5) {
      return;
    }

    setState(() {
      _reloadPetsScreen = true;
    });

    _bloc.add(
      PetDetailsEvent.updateShelterAnimalRating(
        id: pet.id,
        rating: animalRating,
        onSuccess: (shelterAnimal) {
          context.showNotification(
            NebulaNotification.primary(
              title: context.translate(Translations.info),
              description: context.translate(
                Translations.petDetailsRatingHasBeenSet,
              ),
            ),
          );
        },
        onError: context.showApiError,
      ),
    );
  }
}
