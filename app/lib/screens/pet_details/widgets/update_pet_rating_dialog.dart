import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/models/shelter/shelter_animal.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_button.dart';

class UpdatePetRatingDialog extends StatefulWidget {
  final ShelterAnimal pet;

  const UpdatePetRatingDialog({
    required this.pet,
    super.key,
  });

  @override
  State<UpdatePetRatingDialog> createState() => _UpdatePetRatingDialogState();
}

class _UpdatePetRatingDialogState extends State<UpdatePetRatingDialog> {
  var _rating = 0.0;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Center(
        child: RatingBar.builder(
          initialRating: widget.pet.userRating ?? 5,
          minRating: 1,
          itemBuilder: (context, _) => FaIcon(
            FontAwesomeIcons.solidStar,
            color: context.colors.primary,
          ),
          onRatingUpdate: (rating) => setState(() => _rating = rating),
        ),
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          Expanded(
            child: NebulaButton(
              text: context.translate(Translations.cancel),
              buttonStyle: NebulaButtonStyle.outlinedPrimary(context),
              onPress: () => context.popRoute<double>(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: NebulaButton(
              text: widget.pet.userRating == null
                  ? context.translate(Translations.set)
                  : context.translate(Translations.update),
              buttonStyle: NebulaButtonStyle.primary(context),
              onPress: () => context.popRoute<double>(_rating),
            ),
          ),
        ],
      ),
    ],
  );
}
