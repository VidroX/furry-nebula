import 'package:flutter/material.dart';
import 'package:furry_nebula/models/overlay_option.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_form_field.dart';
import 'package:furry_nebula/widgets/ui/overlay_follower.dart';

class NebulaAutocomplete<T> extends StatefulWidget {
  final List<OverlayOption<T>> options;

  const NebulaAutocomplete({
    this.options = const [],
    super.key,
  });

  @override
  State<NebulaAutocomplete<T>> createState() => _NebulaAutocompleteState();
}

class _NebulaAutocompleteState<T> extends State<NebulaAutocomplete<T>> {
  @override
  Widget build(BuildContext context) => OverlayFollower(
    overlayBuilder: (context, controller) => const SizedBox(),
    targetBuilder: (context, controller) => NebulaFormField(
      readOnly: true,
      onTap: controller.toggleOverlay,
    ),
  );
}
