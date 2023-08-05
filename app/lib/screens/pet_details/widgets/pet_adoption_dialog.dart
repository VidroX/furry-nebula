import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/models/shelter/shelter_animal.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_button.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';

class PetAdoptionDialog extends StatelessWidget {
  final ShelterAnimal pet;

  const PetAdoptionDialog({
    required this.pet,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      NebulaText(
        context.translate(Translations.userRequestAdoptPrompt, params: {
          'animal': pet.name,
        },),
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          Expanded(
            child: NebulaButton(
              text: context.translate(Translations.cancel),
              buttonStyle: NebulaButtonStyle.outlinedError(context),
              onPress: () => context.popRoute<bool>(false),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: NebulaButton(
              text: context.translate(Translations.create),
              buttonStyle: NebulaButtonStyle.primary(context),
              onPress: () => context.popRoute<bool>(true),
            ),
          ),
        ],
      ),
    ],
  );
}
