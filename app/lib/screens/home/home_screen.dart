import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/graphql/__generated__/schema.schema.gql.dart';
import 'package:furry_nebula/router/router.gr.dart';
import 'package:furry_nebula/screens/home/state/user_bloc.dart';
import 'package:furry_nebula/services/injector.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/layout/screen_layout.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  static const routePath = '/';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _iconPadding = EdgeInsets.only(bottom: 4);
  static const _iconSize = 20.0;

  @override
  Widget build(BuildContext context) => BlocProvider<UserBloc>(
    create: (_) => injector.get<UserBloc>(),
    child: BlocBuilder<UserBloc, UserState>(
      builder: (context, state) => AutoTabsRouter(
        routes: state.hasRole(GRole.Admin) ? const [
          UserApprovalsRoute(),
          ProfileRoute(),
        ] : const [
          AccommodationsRoute(),
          ProfileRoute(),
        ],
        transitionBuilder: (context, child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        builder: (context, child) {
          final tabsRouter = AutoTabsRouter.of(context);

          return ScreenLayout(
            loading: state.user == null || state.isLoading,
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                boxShadow: context.colors.shadow,
                color: context.colors.backgroundColor,
              ),
              child: BottomNavigationBar(
                elevation: 0,
                backgroundColor: context.colors.backgroundColor,
                currentIndex: tabsRouter.activeIndex,
                onTap: (index) => tabsRouter.setActiveIndex(index),
                items: state.hasRole(GRole.Admin) ? [
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
                ] : [
                  BottomNavigationBarItem(
                    label: context.translate(Translations.accommodationsTitle),
                    icon: const Padding(
                      padding: _iconPadding,
                      child: FaIcon(
                        FontAwesomeIcons.tent,
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
            child: child,
          );
        },
      ),
    ),
  );
}
