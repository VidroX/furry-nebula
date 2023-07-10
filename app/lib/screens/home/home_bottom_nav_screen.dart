import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/models/user/user_role.dart';
import 'package:furry_nebula/router/router.gr.dart';
import 'package:furry_nebula/screens/home/shelters/pets/state/pets_filter.dart';
import 'package:furry_nebula/screens/home/state/user_bloc.dart';
import 'package:furry_nebula/services/injector.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/layout/screen_layout.dart';

@RoutePage()
class HomeBottomNavScreen extends StatefulWidget {
  static const routePath = '';

  final PetsFilter? petsFilter;

  const HomeBottomNavScreen({
    this.petsFilter,
    super.key,
  });

  @override
  State<HomeBottomNavScreen> createState() => _HomeBottomNavScreenState();
}

class _HomeBottomNavScreenState extends State<HomeBottomNavScreen> {
  static const _iconPadding = EdgeInsets.only(bottom: 4);
  static const _iconSize = 20.0;

  @override
  Widget build(BuildContext context) => BlocProvider<UserBloc>(
    create: (_) => injector.get<UserBloc>(),
    child: BlocBuilder<UserBloc, UserState>(
      builder: (context, state) => AutoTabsRouter(
        routes: [
          PetsRoute(
            selectedShelter: widget.petsFilter?.selectedShelter,
            selectedShelters: widget.petsFilter?.selectedShelters,
            animalType: widget.petsFilter?.animalType,
          ),
          if (state.hasRole(UserRole.shelter))
            const ShelterListRoute(),
          if (state.hasRole(UserRole.admin))
            const UserApprovalsRoute(),
          const ProfileRoute(),
        ],
        transitionBuilder: (context, child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        builder: (context, child) {
          final tabsRouter = AutoTabsRouter.of(context);

          return ScreenLayout(
            padding: EdgeInsets.zero,
            loading: state.user == null || state.isLoading,
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                boxShadow: context.colors.shadow,
                color: context.colors.containerColor,
              ),
              child: Theme(
                data: context.theme.copyWith(
                  colorScheme: context.theme.colorScheme.copyWith(
                    surface: context.theme.colorScheme.onBackground,
                  ),
                ),
                child: BottomNavigationBar(
                  selectedItemColor: context.colors.primary,
                  unselectedItemColor: context.colors.text,
                  elevation: 0,
                  backgroundColor: context.colors.containerColor,
                  currentIndex: tabsRouter.activeIndex,
                  onTap: (index) => tabsRouter.setActiveIndex(index),
                  items: [
                    BottomNavigationBarItem(
                      label: context.translate(Translations.petsPets),
                      icon: const Padding(
                        padding: _iconPadding,
                        child: FaIcon(
                          FontAwesomeIcons.paw,
                          size: _iconSize,
                        ),
                      ),
                    ),
                    if (state.hasRole(UserRole.shelter))
                      BottomNavigationBarItem(
                        label: context.translate(Translations.sheltersShelters),
                        icon: const Padding(
                          padding: _iconPadding,
                          child: FaIcon(
                            FontAwesomeIcons.tents,
                            size: _iconSize,
                          ),
                        ),
                      ),
                    if (state.hasRole(UserRole.admin))
                      BottomNavigationBarItem(
                        label: context.translate(Translations.userApprovalsTitle),
                        icon: const Padding(
                          padding: _iconPadding,
                          child: Icon(
                            Icons.thumbs_up_down,
                            size: _iconSize,
                          ),
                        ),
                      ),
                    BottomNavigationBarItem(
                      label: context.translate(Translations.profileTitle),
                      icon: const Padding(
                        padding: _iconPadding,
                        child: FaIcon(
                          FontAwesomeIcons.user,
                          size: _iconSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child: child,
          );
        },
      ),
    ),
  );
}
