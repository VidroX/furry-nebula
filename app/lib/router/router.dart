import 'package:auto_route/auto_route.dart';
import 'package:furry_nebula/router/router.gr.dart';
import 'package:furry_nebula/screens/auth/auth_main/auth_main_screen.dart';
import 'package:furry_nebula/screens/auth/auth_screen.dart';
import 'package:furry_nebula/screens/auth/login/login_screen.dart';
import 'package:furry_nebula/screens/auth/registration/registration_screen.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      initial: true,
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
    ),
  ];
}
