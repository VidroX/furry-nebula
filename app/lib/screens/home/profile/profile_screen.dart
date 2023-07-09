import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/router/router.gr.dart';
import 'package:furry_nebula/screens/home/state/user_bloc.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/layout/expandable_scroll_view.dart';
import 'package:furry_nebula/widgets/ui/details_list.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_button.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';
import 'package:furry_nebula/widgets/ui/neumorphic_container.dart';
import 'package:intl/intl.dart';

@RoutePage()
class ProfileScreen extends StatefulWidget {
  static const routePath = 'profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final DateFormat _dateFormat;
  late final UserBloc _bloc;

  @override
  void initState() {
    super.initState();

    _dateFormat = DateFormat(DateFormat.YEAR_MONTH_DAY, Platform.localeName);
    _bloc = BlocProvider.of<UserBloc>(context);
  }

  @override
  Widget build(BuildContext context) => ExpandableScrollView(
    padding: const EdgeInsets.all(16),
    child: BlocBuilder<UserBloc, UserState>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NebulaText(
            context.translate(Translations.profileHiWithName, params: {
              'fullName': state.user!.fullName,
            },),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.typography
                .withFontWeight(FontWeight.w600)
                .withFontSize(AppFontSize.extraLarge),
          ),
          const SizedBox(height: 24),
          _ProfileContainer(
            title: context.translate(Translations.profilePrimaryInfo),
            children: [
              DetailsList(
                titles: [
                  context.translate(Translations.profileFirstName),
                  context.translate(Translations.profileLastName),
                  context.translate(Translations.profileBirthDay),
                  context.translate(Translations.profileStatus),
                ],
                details: [
                  state.user!.firstName,
                  state.user!.lastName,
                  _dateFormat.format(state.user!.birthDay),
                  context.translate(state.user!.role.translationKey),
                ],
              ),
            ],
          ),
          if (state.user!.about.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _ProfileContainer(
                title: context.translate(Translations.profileDetails),
                children: [
                  NebulaText(state.user!.about),
                ],
              ),
            ),
          const SizedBox(height: 20),
          NebulaButton.fill(
            loading: state.isLogoutLoading,
            text: context.translate(Translations.authSignOut),
            onPress: _logout,
            buttonStyle: NebulaButtonStyle.error(context),
          ),
        ],
      ),
    ),
  );

  void _logout() {
    _bloc.add(
      UserEvent.logout(
        onFinish: () => context.router.root.replace(const AuthMainRoute()),
      ),
    );
  }
}

class _ProfileContainer extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _ProfileContainer({
    required this.children,
    this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) => NeumorphicContainer(
    width: double.maxFinite,
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          NebulaText(
            title!,
            style: context.typography
                .withFontSize(AppFontSize.extraNormal)
                .withFontWeight(FontWeight.w600),
          ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}
