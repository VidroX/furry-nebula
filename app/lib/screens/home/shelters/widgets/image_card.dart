import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/widgets/ui/nebula_text.dart';
import 'package:furry_nebula/widgets/ui/neumorphic_container.dart';
import 'package:transparent_image/transparent_image.dart';

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final missingImageSize = constraints.maxHeight / 3;

          return Stack(
            children: [
              if (imageUrl != null)
                FastCachedImage(
                  url: imageUrl!,
                  errorBuilder: (_, __, ___) => FutureBuilder<Uint8List?>(
                    future: _fetchRawImage(imageUrl),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return _MissingImage(size: missingImageSize);
                      }

                      return FadeInImage(
                        image: MemoryImage(snapshot.data!),
                        placeholder: MemoryImage(kTransparentImage),
                        placeholderErrorBuilder: (_, __, ___) =>
                            _MissingImage(size: missingImageSize),
                        imageErrorBuilder: (_, __, ___) =>
                            _MissingImage(size: missingImageSize),
                        fit: BoxFit.cover,
                        width: double.maxFinite,
                        height: double.maxFinite,
                      );
                    },
                  ),
                  loadingBuilder: (_, __) =>
                      _MissingImage(size: missingImageSize),
                  fit: BoxFit.cover,
                  width: double.maxFinite,
                  height: double.maxFinite,
                )
              else
                _MissingImage(size: missingImageSize),
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
          );
        },
      ),
    ),
  );

  Future<Uint8List?>? _fetchRawImage(String? url) async {
    if (url == null || url.trim().isEmpty) {
      return null;
    }

    final res = await Dio().get<Uint8List>(
      url.trim(),
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );

    return res.data;
  }
}

class _MissingImage extends StatelessWidget {
  final double? size;

  const _MissingImage({
    this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: FaIcon(
      FontAwesomeIcons.image,
      size: size,
      color: context.colors.text,
    ),
  );
}
