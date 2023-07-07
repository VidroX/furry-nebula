import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/models/photo_object.dart';
import 'package:furry_nebula/models/shelter/add_shelter_data.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/validators/field_length_validator.dart';
import 'package:furry_nebula/widgets/ui/nebula_button.dart';
import 'package:furry_nebula/widgets/ui/nebula_form_field.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class AddShelterModal extends StatefulWidget {
  const AddShelterModal({super.key});

  @override
  State<AddShelterModal> createState() => _AddShelterModalState();
}

class _AddShelterModalState extends State<AddShelterModal> {
  late String _name;
  late String _address;
  String? _info;
  MultipartFile? _photo;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        NebulaFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: FieldLengthValidator(context).validate,
          label: context.translate(Translations.sheltersName),
          onChanged: (value) => setState(() => _name = value),
        ),
        const SizedBox(height: 12),
        NebulaFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: FieldLengthValidator(context).validate,
          label: context.translate(Translations.sheltersAddress),
          onChanged: (value) => setState(() => _address = value),
        ),
        const SizedBox(height: 12),
        NebulaFormField(
          label: context.translate(Translations.sheltersDescription),
          maxLines: 4,
          onChanged: (value) => setState(() => _info = value),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: AlignmentDirectional.center,
          child: NebulaButton(
            text: _photo == null
                ? context.translate(Translations.sheltersUploadPhoto)
                : context.translate(Translations.sheltersRemovePhoto),
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

    context.popRoute<PhotoObject<AddShelterData>>(
      PhotoObject<AddShelterData>(
        object: AddShelterData(
          name: _name.trim(),
          address: _address.trim(),
          info: _info?.trim() ?? '',
        ),
        photo: _photo,
      ),
    );
  }
}
