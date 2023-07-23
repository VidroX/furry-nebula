import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/models/shelter/shelter_animal.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_button.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_datepicker_field.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';

class PetAccommodationDialog extends StatefulWidget {
  final ShelterAnimal pet;

  const PetAccommodationDialog({
    required this.pet,
    super.key,
  });

  @override
  State<PetAccommodationDialog> createState() => _PetAccommodationDialogState();
}

class _PetAccommodationDialogState extends State<PetAccommodationDialog> {
  DateTime? _fromDate;
  DateTime? _toDate;

  bool get _isFilled => _fromDate != null
      && _toDate != null
      && (
          _fromDate!.isBefore(_toDate!)
          || _fromDate!.isAtSameMomentAs(_toDate!)
      );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      NebulaText(
        context.translate(
          Translations.userRequestAccommodatePrompt,
          params: {
            'animal': widget.pet.name,
          },
        ),
      ),
      const SizedBox(height: 12),
      NebulaDatePickerField(
        label: context.translate(Translations.userRequestFrom),
        onDateSelected: (date) => setState(() => _fromDate = date),
        initialDatePickerMode: DatePickerMode.day,
        initialDate: _fromDate ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: _toDate,
      ),
      const SizedBox(height: 12),
      NebulaDatePickerField(
        label: context.translate(Translations.userRequestTo),
        onDateSelected: (date) => setState(() => _toDate = date),
        initialDatePickerMode: DatePickerMode.day,
        initialDate: _toDate ?? DateTime.now(),
        firstDate: _fromDate ?? DateTime.now(),
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          Expanded(
            child: NebulaButton(
              text: context.translate(Translations.cancel),
              buttonStyle: NebulaButtonStyle.outlinedError(context),
              onPress: () => context.popRoute<PetAccommodationDateSet>(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: NebulaButton(
              text: context.translate(Translations.create),
              buttonStyle: NebulaButtonStyle.primary(context),
              onPress: _isFilled ? () => context.popRoute<PetAccommodationDateSet>(
                PetAccommodationDateSet(fromDate: _fromDate!, toDate: _toDate!),
              ) : null,
            ),
          ),
        ],
      ),
    ],
  );
}

class PetAccommodationDateSet {
  final DateTime fromDate;
  final DateTime toDate;

  const PetAccommodationDateSet({ required this.fromDate, required this.toDate });
}
