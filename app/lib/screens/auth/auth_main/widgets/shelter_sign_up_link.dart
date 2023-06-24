import 'package:flutter/material.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/router/router.gr.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/ui/nebula_link.dart';
import 'package:furry_nebula/widgets/ui/nebula_text.dart';

class ShelterSignUpLink extends StatelessWidget {
  final NebulaTextStyle? textStyle;
  final NebulaLinkStyle? linkStyle;

  const ShelterSignUpLink({
    this.linkStyle,
    this.textStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Wrap(
    children: [
      Padding(
        padding: const EdgeInsetsDirectional.only(end: 8),
        child: NebulaText(
          context.translate(Translations.authIsShelterRepresentative),
          style: textStyle,
        ),
      ),
      NebulaLink(
        routeInfo: RegistrationRoute(isShelterRep: true),
        text: context.translate(Translations.authSignUpHere),
        style: linkStyle,
      ),
    ],
  );
}
