import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_circular_button.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';

class DialogLayout extends StatelessWidget {
  final String title;
  final bool dismissible;
  final VoidCallback? onDismiss;
  final EdgeInsetsGeometry padding;
  final BoxConstraints? constraints;
  final BoxDecoration decoration;
  final Widget child;

  const DialogLayout({
    required this.title,
    required this.child,
    this.dismissible = true,
    this.padding = const EdgeInsetsDirectional.all(16),
    this.decoration = const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    this.constraints,
    this.onDismiss,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: constraints ?? BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height / 1.25,
      ),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width - 32,
              decoration: decoration.copyWith(
                color: context.colors.containerColor,
                boxShadow: context.colors.shadow,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        bottom: 12,
                        end: 48,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: NebulaText(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.fade,
                              style: context.typography
                                  .withFontSize(AppFontSize.large)
                                  .withFontWeight(FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    child,
                  ],
                ),
              ),
            ),
            if (dismissible)
              PositionedDirectional(
                top: 8,
                end: 8,
                child: NebulaCircularButton(
                  onPress: () => _dismissDialog(context),
                  buttonStyle: NebulaCircularButtonStyle.clear(context),
                  child: const FaIcon(
                    FontAwesomeIcons.xmark,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );

  void _dismissDialog(BuildContext context) {
    onDismiss?.call();

    context.popRoute();
  }
}

Future<T?> showNebulaDialog<T>({
  required BuildContext context,
  required Widget child,
  VoidCallback? onDismiss,
  EdgeInsetsGeometry padding = const EdgeInsetsDirectional.all(16),
  BoxConstraints? constraints,
  BoxDecoration decoration = const BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  ),
  String title = '',
  bool useRootNavigator = true,
  bool dismissible = true,
}) => showDialog<T>(
  context: context,
  useRootNavigator: useRootNavigator,
  barrierDismissible: dismissible,
  barrierColor: context.colors.inverseBackgroundColor.withOpacity(0.8),
  builder: (_) => DialogLayout(
    title: title,
    decoration: decoration,
    constraints: constraints,
    dismissible: dismissible,
    padding: padding,
    child: child,
  ),
).then((value) {
  if (value == null) {
    onDismiss?.call();
  }

  return value;
});
