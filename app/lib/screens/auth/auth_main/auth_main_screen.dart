import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/router/router.gr.dart';
import 'package:furry_nebula/screens/auth/auth_main/widgets/shelter_sign_up_link.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/layout/screen_layout.dart';
import 'package:furry_nebula/widgets/ui/nebula_button.dart';
import 'package:furry_nebula/widgets/ui/nebula_logo.dart';
import 'package:furry_nebula/widgets/ui/nebula_text.dart';

@RoutePage()
class AuthMainScreen extends StatelessWidget {
  static const String routePath = '';

  const AuthMainScreen({super.key});

  @override
  Widget build(BuildContext context) => ScreenLayout(
    scrollable: true,
    decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            context.colors.primary,
            context.colors.secondary,
          ],
        ),
    ),
    child: Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NebulaLogo(iconColor: context.colors.alternativeText),
                const SizedBox(height: 16),
                Container(
                  constraints: const BoxConstraints(maxWidth: 350),
                  width: double.infinity,
                  padding: const EdgeInsetsDirectional.all(12),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      NebulaButton.fill(
                        text: context.translate(Translations.authSignIn),
                        onPress: () => context.navigateTo(const LoginRoute()),
                        buttonStyle: NebulaButtonStyle.background(context),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Divider(
                                color: context.colors.alternativeText,
                                height: 1,
                                thickness: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          NebulaText(
                            context.translate(Translations.or),
                            style: context.typography
                                .withColor(context.colors.alternativeText),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Divider(
                                color: context.colors.alternativeText,
                                height: 1,
                                thickness: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      NebulaButton.fill(
                        text: context.translate(Translations.authSignUp),
                        onPress: () => context.navigateTo(
                          RegistrationRoute(),
                        ),
                        buttonStyle: NebulaButtonStyle.clear(context, isLight: false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ShelterSignUpLink(
          textStyle: context.typography
              .withColor(context.colors.alternativeText),
        ),
      ],
    ),
  );
}
