import 'package:flutter/material.dart';
import 'package:furry_nebula/app_colors.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/widgets/ui/nebula_text.dart';

class NebulaNotification extends StatelessWidget {
  final String title;
  final String? description;
  final Duration animationDuration;
  final Duration? hideAfter;
  final AppColorsType? bannerColor;

  const NebulaNotification({
    required this.title,
    this.animationDuration = const Duration(milliseconds: 600),
    this.hideAfter = const Duration(seconds: 3),
    this.description,
    this.bannerColor,
    super.key,
  });

  factory NebulaNotification.error({
    required String title,
    String? description,
    Duration animationDuration = const Duration(milliseconds: 600),
    Duration? hideAfter = const Duration(seconds: 3),
  }) => NebulaNotification(
    title: title,
    description: description,
    animationDuration: animationDuration,
    hideAfter: hideAfter,
    bannerColor: AppColorsType.error,
  );

  factory NebulaNotification.primary({
    required String title,
    String? description,
    Duration animationDuration = const Duration(milliseconds: 600),
    Duration? hideAfter = const Duration(seconds: 3),
  }) => NebulaNotification(
    title: title,
    description: description,
    animationDuration: animationDuration,
    hideAfter: hideAfter,
    bannerColor: AppColorsType.primary,
  );

  @override
  Widget build(BuildContext context) {
    final boxConstraints = context.isLandscape
        ? const BoxConstraints(
            maxHeight: 90,
            minHeight: 50,
            maxWidth: 300,
            minWidth: 100,
          )
        : const BoxConstraints(maxHeight: 90, minHeight: 50);

    return Container(
      constraints: boxConstraints,
      decoration: BoxDecoration(
        boxShadow: context.colors.shadow,
        color: context.colors.surfaceColor,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            if (bannerColor != null)
              Container(
                color: context.colors.primaryColors[bannerColor!],
                width: 8,
              ),
            Padding(
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
                        style: context.colors.isLight
                            ? context.typography
                            : context.typographyAlt,
                      ),
                    ),
                ],
              ),
            ),
          ],
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

  Future? _hideNotificationFuture;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.notification.animationDuration,
    );

    _animation = CurveTween(curve: Curves.fastOutSlowIn)
        .animate(_animationController);

    _animationController.forward();

    if (widget.notification.hideAfter != null) {
      _hideNotificationFuture = Future.delayed(widget.notification.hideAfter!)
          .whenComplete(() => _animationController.reverse())
          .whenComplete(_hideNotification);
    }

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _hideNotification() {
    widget.onNotificationHidden();
    _hideNotificationFuture?.ignore();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _animation,
    child: widget.notification,
  );
}


mixin NebulaNotificationHandler<T extends StatefulWidget> on State<T> {
  OverlayEntry? _overlayEntry;

  Widget _buildNotificationOverlay(NebulaNotification notification) =>
      Stack(
        children: [
          Positioned(
            bottom: 24,
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
