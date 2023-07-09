import 'package:flutter/material.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_image.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';
import 'package:furry_nebula/widgets/ui/neumorphic_container.dart';

class ImageCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const ImageCard({
    required this.title,
    this.imageUrl,
    this.onTap,
    this.width,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: NeumorphicContainer.borderRadius,
    child: NeumorphicContainer(
      width: width,
      height: height,
      child: Stack(
        children: [
          NebulaImage(
            url: imageUrl,
            fit: BoxFit.cover,
            width: double.maxFinite,
            height: double.maxFinite,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ColoredBox(
              color: context.colors.containerColor.withOpacity(0.6),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  vertical: 4,
                  horizontal: 8,
                ),
                child: NebulaText(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
