import 'package:flutter/material.dart';
import 'package:furry_nebula/widgets/layout/expandable_scroll_view.dart';

class ScreenLayout extends StatelessWidget {
  final Widget child;
  final BoxDecoration decoration;
  final bool scrollable;

  const ScreenLayout({
    required this.child,
    this.decoration = const BoxDecoration(),
    this.scrollable = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: decoration,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, _) {
            if (scrollable) {
              return ExpandableScrollView(
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(16),
                  child: Align(
                    alignment: AlignmentDirectional.topStart,
                    child: child,
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsetsDirectional.all(16),
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: child,
              ),
            );
          },
        ),
      ),
    ),
  );
}
