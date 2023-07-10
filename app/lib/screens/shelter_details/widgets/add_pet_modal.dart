import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/models/overlay_option.dart';
import 'package:furry_nebula/models/photo_object.dart';
import 'package:furry_nebula/models/shelter/add_shelter_animal_data.dart';
import 'package:furry_nebula/models/shelter/animal_type.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/validators/field_length_validator.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_button.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_dropdown.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_form_field.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class AddPetModal extends StatefulWidget {
  const AddPetModal({super.key});

  @override
  State<AddPetModal> createState() => _AddPetModalState();
}

class _AddPetModalState extends State<AddPetModal> {
  late String _name;
  String? _description;
  MultipartFile? _photo;

  final _animalTypeOptions = AnimalType.values
      .map((e) => OverlayOption(
        data: e,
        title: e.translationKey,
      ),)
      .toList();

  late OverlayOption<AnimalType> _animalType = _animalTypeOptions[0];

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        NebulaDropdown<AnimalType>(
          label: context.translate(Translations.animalTypesTitle),
          validator: FieldLengthValidator(context).validate,
          options: _animalTypeOptions,
          selectedOption: _animalType,
          onOptionSelected: (option) => setState(() => _animalType = option),
        ),
        const SizedBox(height: 12),
        NebulaFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: FieldLengthValidator(context).validate,
          label: context.translate(Translations.shelterDetailsAddAnimalName),
          onChanged: (value) => setState(() => _name = value),
        ),
        const SizedBox(height: 12),
        NebulaFormField(
          label: context.translate(Translations.shelterDetailsAddAnimalDescription),
          maxLines: 4,
          onChanged: (value) => setState(() => _description = value),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: AlignmentDirectional.center,
          child: NebulaButton(
            text: _photo == null
                ? context.translate(Translations.shelterDetailsAddAnimalUploadAnimalPhoto)
                : context.translate(Translations.shelterDetailsAddAnimalRemoveAnimalPhoto),
            prefixChild: _photo == null ? FaIcon(
              FontAwesomeIcons.upload,
              size: 14,
              color: context.colors.primary,
            ) : FaIcon(
              FontAwesomeIcons.trash,
              size: 14,
              color: context.colors.error,
            ),
            buttonStyle: _photo == null
                ? NebulaButtonStyle.outlinedPrimary(context)
                : NebulaButtonStyle.outlinedError(context),
            onPress: _photo == null
                ? _pickPhoto
                : _removePhoto,
          ),
        ),
        const SizedBox(height: 16),
        NebulaButton.fill(
          text:context.translate(Translations.add),
          onPress: _finish,
        ),
      ],
    ),
  );

  Future<void> _pickPhoto() async {
    if (!mounted) {
      return;
    }

    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    final bytes = await image?.readAsBytes();

    if (!mounted || image == null || bytes == null) {
      return;
    }

    final imageMimeType = image.mimeType ?? lookupMimeType(image.name);

    setState(() {
      _photo = MultipartFile.fromBytes(
        bytes,
        filename: image.name,
        contentType: imageMimeType != null
            ? MediaType.parse(imageMimeType)
            : null,
      );
    });
  }

  void _removePhoto() {
    setState(() {
      _photo = null;
    });
  }

  void _finish() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.popRoute<PhotoObject<AddShelterAnimalData>>(
      PhotoObject<AddShelterAnimalData>(
        object: AddShelterAnimalData(
          name: _name.trim(),
          animalType: _animalType.data,
          description: _description?.trim() ?? '',
        ),
        photo: _photo,
      ),
    );
  }
}
