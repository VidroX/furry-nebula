import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/app_colors.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/widgets/ui/nebula_text.dart';

class NebulaNotification extends StatelessWidget {
  final bool closeable;
  final String title;
  final String? description;
  final Duration animationDuration;
  final Duration? hideAfter;
  final AppColorsType? bannerColor;
  final VoidCallback? onHideNotification;

  const NebulaNotification({
    required this.title,
    this.closeable = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.hideAfter = const Duration(seconds: 3),
    this.description,
    this.bannerColor,
    this.onHideNotification,
    super.key,
  });

  factory NebulaNotification.error({
    required String title,
    String? description,
    bool closeable = true,
    Duration animationDuration = const Duration(milliseconds: 200),
    Duration? hideAfter = const Duration(seconds: 3),
  }) => NebulaNotification(
    title: title,
    description: description,
    closeable: closeable,
    animationDuration: animationDuration,
    hideAfter: hideAfter,
    bannerColor: AppColorsType.error,
  );

  factory NebulaNotification.primary({
    required String title,
    String? description,
    bool closeable = true,
    Duration animationDuration = const Duration(milliseconds: 200),
    Duration? hideAfter = const Duration(seconds: 3),
  }) => NebulaNotification(
    title: title,
    description: description,
    closeable: closeable,
    animationDuration: animationDuration,
    hideAfter: hideAfter,
    bannerColor: AppColorsType.primary,
  );

  @override
  Widget build(BuildContext context) {
    final boxConstraints = context.isLandscape
        ? const BoxConstraints(
            maxHeight: 150,
            minHeight: 50,
            maxWidth: 500,
            minWidth: 100,
          )
        : const BoxConstraints(maxHeight: 150, minHeight: 50);

    return Container(
      constraints: boxConstraints,
      decoration: BoxDecoration(
        boxShadow: context.colors.shadow,
      ),
      width: double.maxFinite,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.surfaceColor,
            border: bannerColor != null ? Border(
              left: BorderSide(
                color: context.colors.primaryColors[bannerColor!]!,
                width: 8,
              ),
            ) : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NebulaText(
                    title,
                    style: context.colors.isLight
                        ? context.typography.withFontWeight(FontWeight.w600)
                        : context.typographyAlt.withFontWeight(FontWeight.w600),
                  ),
                  if (description != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: 4),
                      child: NebulaText(
                        description!,
                        maxLines: 3,
                        style: context.colors.isLight
                            ? context.typography
                            : context.typographyAlt,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _NebulaNotificationContainer extends StatefulWidget {
  final NebulaNotification notification;
  final VoidCallback onNotificationHidden;

  const _NebulaNotificationContainer({
    required this.notification,
    required this.onNotificationHidden,
    // ignore: unused_element
    super.key,
  });

  @override
  State<_NebulaNotificationContainer> createState() =>
      _NebulaNotificationContainerState();
}

class _NebulaNotificationContainerState extends State<_NebulaNotificationContainer> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  Timer? _timer;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.notification.animationDuration,
    );

    _animation = CurveTween(curve: Curves.linear)
        .animate(_animationController);

    _animationController.forward();

    if (widget.notification.hideAfter != null) {
      _timer = Timer(
        widget.notification.hideAfter!,
        () => _animationController.reverse()
            .whenCompleteOrCancel(_hideNotification),
      );
    }

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _hideNotification() {
    _timer?.cancel();
    widget.onNotificationHidden();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _animation,
    child: Stack(
      children: [
        widget.notification,
        if (widget.notification.closeable)
          Positioned(
            top: 2,
            right: 2,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _animationController.reverse()
                    .whenCompleteOrCancel(_hideNotification),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: FaIcon(
                    FontAwesomeIcons.xmark,
                    size: 20,
                    color: context.colors.isLight
                        ? context.colors.text
                        : context.colors.alternativeText,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}


mixin NebulaNotificationHandler<T extends StatefulWidget> on State<T> {
  OverlayEntry? _overlayEntry;

  Widget _buildNotificationOverlay(NebulaNotification notification) =>
      Stack(
        children: [
          Positioned(
            top: context.isLandscape ? 24 : null,
            bottom: context.isLandscape ? null : 24,
            right: 12,
            left: context.mounted && context.isLandscape
                ? null
                : 12,
            child: _NebulaNotificationContainer(
              notification: notification,
              onNotificationHidden: cancelNotification,
            ),
          ),
        ],
      );

  void showNotification(NebulaNotification notification) {
    if (!context.mounted || _overlayEntry != null) {
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (_) => _buildNotificationOverlay(notification),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;

    super.dispose();
  }

  void cancelNotification() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class NebulaGlobalNotificationProvider {
  final Function(NebulaNotification notification) showNotification;
  final VoidCallback cancelNotification;

  NebulaGlobalNotificationProvider({
    required this.showNotification,
    required this.cancelNotification,
  });
}
