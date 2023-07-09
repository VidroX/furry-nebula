import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';

class NotFound extends StatelessWidget {
  final String title;
  final IconData icon;

  const NotFound({
    required this.title,
    this.icon = FontAwesomeIcons.circleExclamation,
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
      ],
    ),
  );
}
