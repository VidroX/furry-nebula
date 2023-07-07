import 'package:flutter/material.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/widgets/ui/nebula_text.dart';

class LoadingBarrier extends StatelessWidget {
  final bool loading;
  final String? title;
  final double opacity;
  final Widget child;

  const LoadingBarrier({
    required this.child,
    this.loading = false,
    this.opacity = 0.85,
    this.title,
    super.key,
  }) : assert(opacity >= 0 && opacity <= 1);

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      child,
      if (loading)
        Positioned.fill(
          child: ModalBarrier(
            dismissible: false,
            color: context.colors.inverseBackgroundColor.withOpacity(opacity),
          ),
        ),
      if (loading)
        Positioned.fill(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(strokeWidth: 5),
                ),
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: NebulaText(
                      title!,
                      textAlign: TextAlign.center,
                      style: context.typography
                          .withColor(context.colors.alternativeText)
                          .withFontWeight(FontWeight.w500),
                    ),
                  ),
              ],
            ),
          ),
        ),
    ],
  );
}
