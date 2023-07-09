import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_circular_button.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';

class ModalLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ModalLayout({
    required this.title,
    required this.child,
    this.padding = const EdgeInsetsDirectional.all(16),
    super.key,
  });

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    expand: false,
    minChildSize: 0.9,
    initialChildSize: 0.9,
    builder: (context, scrollController) => SingleChildScrollView(
      padding: padding,
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: NebulaText(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography
                      .withFontSize(AppFontSize.large)
                      .withFontWeight(FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
              NebulaCircularButton(
                onPress: () => context.popRoute(),
                buttonStyle: NebulaCircularButtonStyle.clear(context),
                child: const FaIcon(
                  FontAwesomeIcons.xmark,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ),
  );
}

Future<T?> showNebulaBottomModal<T>({
  required BuildContext context,
  required Widget child,
  EdgeInsetsGeometry padding = const EdgeInsetsDirectional.all(16),
  String title = '',
  bool useRootNavigator = false,
}) => showModalBottomSheet<T>(
  isScrollControlled: true,
  context: context,
  elevation: 0,
  useSafeArea: true,
  useRootNavigator: useRootNavigator,
  backgroundColor: context.colors.containerColor,
  constraints: BoxConstraints(
    maxHeight: MediaQuery.of(context).size.height / 1.75,
  ),
  builder: (_) => ModalLayout(
    title: title,
    padding: padding,
    child: child,
  ),
);
