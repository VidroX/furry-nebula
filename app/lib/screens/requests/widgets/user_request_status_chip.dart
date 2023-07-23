import 'package:flutter/material.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/models/shelter/user_request_status.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';

class UserRequestStatusChip extends StatelessWidget {
  final UserRequestStatus requestStatus;

  const UserRequestStatusChip({
    required this.requestStatus,
    super.key,
  });

  _FontSet _getFontSet(BuildContext context) {
    return _FontSet(
      backgroundColor: context.colors.primary,
      fontColor: context.colors.text,
    );
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.symmetric(vertical: 4, horizontal: 6),
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(6)),
      color: _getFontSet(context).backgroundColor,
    ),
    child: NebulaText(
      context.translate(requestStatus.translationKey),
      style: context.typography
          .withFontSize(AppFontSize.small)
          .withColor(_getFontSet(context).fontColor),
    ),
  );
}

class _FontSet {
  final Color fontColor;
  final Color backgroundColor;

  const _FontSet({ required this.backgroundColor, required this.fontColor });
}
