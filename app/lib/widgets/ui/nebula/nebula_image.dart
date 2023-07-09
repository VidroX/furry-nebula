import 'package:dio/dio.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:transparent_image/transparent_image.dart';

class NebulaImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const NebulaImage({
    this.url,
    this.fit,
    this.width,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final missingImageSize = constraints.maxHeight / 3;

      if (url == null || url!.trim().isEmpty) {
        return _MissingImage(size: missingImageSize);
      }

      return FastCachedImage(
        url: url!,
        errorBuilder: (_, __, ___) => FutureBuilder<Uint8List?>(
          future: _fetchRawImage(url),
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
              fit: fit,
              width: width,
              height: height,
            );
          },
        ),
        loadingBuilder: (_, __) =>
            _MissingImage(size: missingImageSize),
        fit: fit,
        width: width,
        height: height,
      );
    },
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
