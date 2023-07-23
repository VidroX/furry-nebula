import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/extensions/datetime_extensions.dart';
import 'package:furry_nebula/models/shelter/user_request.dart';
import 'package:furry_nebula/models/shelter/user_request_status.dart';
import 'package:furry_nebula/models/shelter/user_request_type.dart';
import 'package:furry_nebula/models/user/user.dart';
import 'package:furry_nebula/models/user/user_role.dart';
import 'package:furry_nebula/screens/requests/widgets/user_request_status_chip.dart';
import 'package:furry_nebula/screens/requests/widgets/user_request_type_chip.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/layout/screen_layout.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_button.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_circular_button.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';
import 'package:furry_nebula/widgets/ui/neumorphic_container.dart';

class RequestDetails extends StatelessWidget {
  final User currentUser;
  final UserRequest request;
  final VoidCallback? onApprove;
  final VoidCallback? onDeny;
  final VoidCallback? onCancel;
  final VoidCallback? onReturn;

  const RequestDetails({
    required this.request,
    required this.currentUser,
    this.onApprove,
    this.onDeny,
    this.onCancel,
    this.onReturn,
    super.key,
  });

  @override
  Widget build(BuildContext context) => ScreenLayout(
    scrollable: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            NebulaCircularButton(
              buttonStyle: NebulaCircularButtonStyle.clear(context),
              onPress: () => context.popRoute(),
              padding: EdgeInsets.zero,
              child: FaIcon(
                FontAwesomeIcons.arrowLeftLong,
                size: 16,
                color: context.colors.text,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NebulaText(
                request.animal.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.typography
                    .withFontWeight(FontWeight.w600)
                    .withFontSize(AppFontSize.extraLarge),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            UserRequestStatusChip(
              requestStatus: request.requestStatus,
            ),
            const SizedBox(width: 4),
            UserRequestTypeChip(
              requestType: request.requestType,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.paw,
                  color: context.colors.text,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NebulaText(
                context.translate(
                  request.animal.animalType.translationKey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.tent,
                  color: context.colors.text,
                  size: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NebulaText(
                context.translate(
                  request.animal.shelter.name,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.solidStar,
                  color: context.colors.text,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NebulaText(
                request.animal.overallRating
                    .toStringAsFixed(1),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.solidUser,
                  color: context.colors.text,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NebulaText(
                request.user.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.solidEnvelope,
                  color: context.colors.text,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NebulaText(
                request.user.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (request.requestType == UserRequestType.accommodation
            && request.fromDate != null
            && request.toDate != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.solidCalendar,
                      color: context.colors.text,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: request.fromDate!.formatToYearMonthDay,
                        ),
                        const WidgetSpan(child: SizedBox(width: 4)),
                        const TextSpan(text: '—'),
                        const WidgetSpan(child: SizedBox(width: 4)),
                        TextSpan(
                          text: request.toDate!.formatToYearMonthDay,
                        ),
                      ],
                      style: context.typography.toTextStyle(),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        NeumorphicContainer(
          width: double.maxFinite,
          padding: const EdgeInsetsDirectional.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NebulaText(
                context.translate(Translations.userRequestUserDetails),
                style: context.typography
                    .withFontSize(AppFontSize.extraNormal)
                    .withFontWeight(FontWeight.w500),
              ),
              const SizedBox(height: 12),
              NebulaText(
                request.user.about.trim().isEmpty
                    ? context.translate(Translations.userRequestNoUserDetails)
                    : request.user.about.trim(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (request.requestStatus == UserRequestStatus.pending
            && currentUser.role != UserRole.user)
          Row(
            children: [
              Expanded(
                child: NebulaButton.fill(
                  text: context.translate(Translations.userRequestDeny),
                  buttonStyle: NebulaButtonStyle.error(context),
                  prefixChild: FaIcon(
                    FontAwesomeIcons.xmark,
                    size: 16,
                    color: NebulaButtonStyle.error(context)
                        .textStyle
                        .color,
                  ),
                  onPress: onDeny,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: NebulaButton.fill(
                  text: context.translate(Translations.userRequestApprove),
                  buttonStyle: NebulaButtonStyle.primary(context),
                  prefixChild: FaIcon(
                    FontAwesomeIcons.check,
                    size: 16,
                    color: NebulaButtonStyle.primary(context)
                        .textStyle
                        .color,
                  ),
                  onPress: onApprove,
                ),
              ),
            ],
          )
        else if (request.requestStatus == UserRequestStatus.approved
            && request.requestType != UserRequestType.adoption
            && currentUser.role != UserRole.user)
          NebulaButton.fill(
            text: context.translate(Translations.userRequestAnimalReturned),
            onPress: onReturn,
          )
        else if (request.requestStatus == UserRequestStatus.pending && currentUser.role == UserRole.user)
          NebulaButton.fill(
            text: context.translate(Translations.userRequestCancelRequest),
            onPress: onCancel,
          ),
      ],
    ),
  );
}
