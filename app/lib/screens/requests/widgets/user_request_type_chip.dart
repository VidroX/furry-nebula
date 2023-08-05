import 'package:flutter/material.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/models/shelter/user_request_type.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';

class UserRequestTypeChip extends StatelessWidget {
  final UserRequestType requestType;

  const UserRequestTypeChip({
    required this.requestType,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.symmetric(vertical: 4, horizontal: 6),
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(6)),
      color: context.colors.primary,
    ),
    child: NebulaText(
      context.translate(requestType.translationKey),
      style: context.typography
          .withFontSize(AppFontSize.small)
          .withColor(
            context.colors.isLight
                ? context.colors.text
                : context.colors.alternativeText,
          ),
    ),
  );
}
