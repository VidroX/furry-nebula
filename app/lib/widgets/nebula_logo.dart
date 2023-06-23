import 'package:flutter/material.dart';
import 'package:furry_nebula/app_colors.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/gen/assets.gen.dart';
import 'package:furry_nebula/widgets/nebula_text.dart';

class NebulaLogo extends StatelessWidget {
  final bool showText;

  const NebulaLogo({
    this.showText = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Assets.svg.paw.svg(
        colorFilter: ColorFilter.mode(
          context.colors.primaryColors[AppColorsType.text]!,
          BlendMode.srcIn,
        ),
        width: 64,
        height: 64,
      ),
      if (showText)
        Padding(
          padding: const EdgeInsetsDirectional.only(start:12, top: 8),
          child: NebulaText(
            'Rainy Pets',
            style: context.typography
                .withFontSize(AppFontSize.extraLarge)
                .withFontWeight(FontWeight.w600),
          ),
        ),
    ],
  );
}
