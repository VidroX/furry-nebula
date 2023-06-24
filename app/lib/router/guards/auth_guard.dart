import 'package:auto_route/auto_route.dart';
import 'package:furry_nebula/graphql/__generated__/schema.schema.gql.dart';
import 'package:furry_nebula/models/user/user.dart';
import 'package:furry_nebula/repositories/user/user_repository.dart';
import 'package:furry_nebula/router/router.gr.dart';

class AuthGuard extends AutoRouteGuard {
  final UserRepository userRepository;
  final bool shouldBeAuthenticated;
  final GRole? roleRequirement;
  final PageRouteInfo? redirectRoute;

  const AuthGuard({
    required this.userRepository,
    this.shouldBeAuthenticated = true,
    this.roleRequirement,
    this.redirectRoute,
  });

  @override
  Future<void> onNavigation(NavigationResolver resolver, StackRouter router) async {
    late final bool isAuthenticated;
    late final User? currentUser;

    try {
      final isTokenValid = await userRepository.isAuthenticated();

      currentUser = isTokenValid
          ? await userRepository.getCurrentUser()
          : null;
      isAuthenticated = currentUser != null;
    } catch (_) {
      currentUser = null;
      isAuthenticated = false;
    }

    final canContinueNavigation = isAuthenticated == shouldBeAuthenticated && (
        roleRequirement == null || currentUser?.role == roleRequirement
    );

    if(canContinueNavigation){
      return resolver.next();
    }

    resolver.next(false);
    router.replace(redirectRoute ?? const AuthMainRoute());
  }
}
