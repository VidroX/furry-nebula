import 'package:flutter/material.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/widgets/layout/expandable_scroll_view.dart';

class ScreenLayout extends StatelessWidget {
  final Widget child;
  final BoxDecoration decoration;
  final bool scrollable;
  final Widget? bottomNavigationBar;
  final bool loading;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;

  static const defaultPadding = EdgeInsetsDirectional.all(16);

  const ScreenLayout({
    required this.child,
    this.decoration = const BoxDecoration(),
    this.scrollable = false,
    this.bottomNavigationBar,
    this.loading = false,
    this.padding = defaultPadding,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: backgroundColor ?? context.colors.backgroundColor,
    bottomNavigationBar: loading ? null : bottomNavigationBar,
    resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    body: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: decoration,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, _) {
            if (loading) {
              return const Center(
                child: CircularProgressIndicator(strokeWidth: 3),
              );
            }

            if (scrollable) {
              return ExpandableScrollView(
                child: Padding(
                  padding: padding,
                  child: Align(
                    alignment: AlignmentDirectional.topStart,
                    child: child,
                  ),
                ),
              );
            }

            return Padding(
              padding: padding,
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
