import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/widgets/ui/nebula_text.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final Offset offset;

  const AuthHeader({
    required this.title,
    this.showBackButton = true,
    this.offset = const Offset(-8, 0),
    super.key,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (showBackButton)
        Transform.translate(
          offset: offset,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(top: 4),
            child: IconButton(
              iconSize: 20,
              splashRadius: 20,
              onPressed: () => kIsWeb ? context.back() : context.popRoute(),
              icon: FaIcon(
                FontAwesomeIcons.arrowLeftLong,
                size: 20,
                color: context.colors.text,
              ),
            ),
          ),
        ),
      Expanded(
        child: NebulaText(
          title,
          style: context.typography
              .withFontSize(AppFontSize.large)
              .withFontWeight(FontWeight.w500),
          maxLines: 2,
        ),
      ),
    ],
  );
}
