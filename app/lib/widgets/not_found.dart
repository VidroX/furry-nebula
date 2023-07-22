import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_button.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';

class NotFound extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onRefreshPress;

  const NotFound({
    required this.title,
    this.icon = FontAwesomeIcons.circleExclamation,
    this.onRefreshPress,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaIcon(
          icon,
          size: 128,
          color: context.colors.hint,
        ),
        const SizedBox(height: 32),
        NebulaText(
          context.translate(title),
          maxLines: 3,
          textAlign: TextAlign.center,
          style: context.typography
              .withFontWeight(FontWeight.w500)
              .withFontSize(AppFontSize.extraNormal)
              .withColor(context.colors.hint),
        ),
        if (onRefreshPress != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 12),
            child: NebulaButton(
              text: context.translate(Translations.refresh),
              buttonStyle: NebulaButtonStyle.primary(context),
              onPress: onRefreshPress,
            ),
          ),
      ],
    ),
  );
}
