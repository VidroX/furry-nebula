import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';

class DetailsList extends StatelessWidget {
  final List<String> titles;
  final List<String> details;

  const DetailsList({
    this.titles = const [],
    this.details = const [],
    super.key,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: titles.mapIndexed((index, title) => Padding(
          padding: index == titles.length
              ? EdgeInsets.zero
              : const EdgeInsetsDirectional.only(end: 24, bottom: 6),
          child: NebulaText(
            '$title:',
          ),
        ),).toList(),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: details.mapIndexed((index, detail) => Padding(
            padding: index == titles.length
                ? EdgeInsets.zero
                : const EdgeInsetsDirectional.only(bottom: 6),
            child: NebulaText(
              detail,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),).toList(),
        ),
      ),
    ],
  );
}
