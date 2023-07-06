import 'package:auto_route/auto_route.dart';
import 'package:furry_nebula/models/user/user_role.dart';
import 'package:furry_nebula/router/guards/auth_guard.dart';
import 'package:furry_nebula/router/router.gr.dart';
import 'package:furry_nebula/screens/auth/auth_screen.dart';
import 'package:furry_nebula/screens/auth/login/login_screen.dart';
import 'package:furry_nebula/screens/auth/main/auth_main_screen.dart';
import 'package:furry_nebula/screens/auth/registration/registration_screen.dart';
import 'package:furry_nebula/screens/home/approvals/user_approvals_screen.dart';
import 'package:furry_nebula/screens/home/home_screen.dart';
import 'package:furry_nebula/screens/home/profile/profile_screen.dart';
import 'package:furry_nebula/screens/home/shelters/pets/pets_screen.dart';
import 'package:furry_nebula/screens/home/shelters/shelter_list/shelter_list_screen.dart';
import 'package:furry_nebula/screens/home/shelters/shelters_screen.dart';
import 'package:furry_nebula/services/injector.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      initial: true,
      path: HomeScreen.routePath,
      page: HomeRoute.page,
      children: [
        AutoRoute(
          path: ProfileScreen.routePath,
          page: ProfileRoute.page,
        ),
        AutoRoute(
          path: SheltersScreen.routePath,
          page: SheltersRoute.page,
          children: [
            AutoRoute(
              initial: true,
              path: PetsScreen.routePath,
              page: PetsRoute.page,
            ),
            AutoRoute(
              path: ShelterListScreen.routePath,
              page: ShelterListRoute.page,
              guards: [
                AuthGuard(
                  userRepository: injector.get(),
                  roleRequirement: UserRole.shelter,
                ),
              ],
            ),
          ],
        ),
        AutoRoute(
          path: UserApprovalsScreen.routePath,
          page: UserApprovalsRoute.page,
          guards: [
            AuthGuard(
              userRepository: injector.get(),
              roleRequirement: UserRole.admin,
            ),
          ],
        ),
      ],
      guards: [
        AuthGuard(userRepository: injector.get()),
      ],
    ),
    AutoRoute(
      path: AuthScreen.routePath,
      page: AuthRoute.page,
      children: [
        AutoRoute(
          initial: true,
          path: AuthMainScreen.routePath,
          page: AuthMainRoute.page,
        ),
        AutoRoute(
          path: LoginScreen.routePath,
          page: LoginRoute.page,
        ),
        AutoRoute(
          path: RegistrationScreen.routePath,
          page: RegistrationRoute.page,
        ),
      ],
      guards: [
        AuthGuard(
          userRepository: injector.get(),
          shouldBeAuthenticated: false,
          redirectRoute: const HomeRoute(),
        ),
      ],
    ),
  ];
}
