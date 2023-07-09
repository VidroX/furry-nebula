import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/models/shelter/shelter.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_button.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';

class DeleteShelterDialog extends StatelessWidget {
  final Shelter shelter;

  const DeleteShelterDialog({
    required this.shelter,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      NebulaText(
        context.translate(Translations.shelterDetailsDeletePrompt, params: {
          'shelter': shelter.name,
        },),
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          Expanded(
            child: NebulaButton(
              text: context.translate(Translations.cancel),
              buttonStyle: NebulaButtonStyle.outlinedPrimary(context),
              onPress: () => context.popRoute<bool>(false),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: NebulaButton(
              text: context.translate(Translations.delete),
              buttonStyle: NebulaButtonStyle.error(context),
              onPress: () => context.popRoute<bool>(true),
            ),
          ),
        ],
      ),
    ],
  );
}
