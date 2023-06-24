import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/router/router.gr.dart';
import 'package:furry_nebula/screens/home/state/user_bloc.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/ui/nebula_button.dart';

@RoutePage()
class ProfileScreen extends StatefulWidget {
  static const routePath = 'profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final UserBloc _bloc;

  @override
  void initState() {
    super.initState();

    _bloc = BlocProvider.of<UserBloc>(context);
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<UserBloc, UserState>(
    builder: (context, state) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NebulaButton.fill(
          loading: state.isLogoutLoading,
          text: context.translate(Translations.authSignOut),
          onPress: _logout,
          buttonStyle: NebulaButtonStyle.error(context),
        ),
      ],
    ),
  );

  void _logout() {
    _bloc.add(
      UserEvent.logout(
        onFinish: () => context.replaceRoute(const AuthMainRoute()),
      ),
    );
  }
}
