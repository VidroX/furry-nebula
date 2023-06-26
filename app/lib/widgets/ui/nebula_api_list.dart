import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:furry_nebula/models/pagination/graph_page.dart';
import 'package:furry_nebula/widgets/layout/expandable_scroll_view.dart';

class NebulaApiList<T> extends StatefulWidget {
  final List<T>? items;
  final GraphPageInfo? pageInfo;
  final bool itemsLoading;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context)? headerBuilder;
  final Widget Function(BuildContext context)? noItemsBuilder;
  final Function(T item, int index)? onItemRemoved;
  final VoidCallback? onLoadNextPage;
  final ScrollPhysics physics;
  final EdgeInsetsGeometry? padding;

  const NebulaApiList({
    required this.itemBuilder,
    this.physics = const BouncingScrollPhysics(),
    this.itemsLoading = false,
    this.noItemsBuilder,
    this.onLoadNextPage,
    this.onItemRemoved,
    this.items,
    this.headerBuilder,
    this.pageInfo,
    this.padding,
    super.key,
  });

  @override
  State<NebulaApiList<T>> createState() => NebulaApiListState();
}

class NebulaApiListState<T> extends State<NebulaApiList<T>> {
  static const _animationDuration = Duration(milliseconds: 200);

  final _listKey = GlobalKey<AnimatedListState>();
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_loadNextPage);

    _listKey.currentState?.insertAllItems(0, widget.items?.length ?? 0);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_loadNextPage);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NebulaApiList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.items != widget.items) {
      final addedItems = widget.items
          ?.where((item) => !(oldWidget.items?.contains(item) ?? false))
          .toList() ?? [];

      if (addedItems.isNotEmpty) {
        for (final item in addedItems) {
          _listKey.currentState?.insertItem(
            widget.items?.indexOf(item) ?? 0,
            duration: _animationDuration,
          );
        }
      }
    }
  }

  void removeItem(int index) {
    if ((widget.items?.length ?? 0) - 1 < index) {
      return;
    }

    final itemIndex = min(index, widget.items!.length - 1);

    _listKey.currentState?.removeItem(
      index + 1,
      duration: _animationDuration,
      (context, animation) => FadeTransition(
        opacity: animation,
        child: widget.itemBuilder(
          context,
          widget.items![itemIndex],
          itemIndex,
        ),
      ),
    );

    Timer(_animationDuration, () {
      widget.onItemRemoved?.call(widget.items![itemIndex], itemIndex);
    });
  }

  void _loadNextPage() {
    if ((widget.items?.isEmpty ?? true) ||
        !(widget.pageInfo?.hasNextPage ?? false)) {
      return;
    }

    final position = _scrollController.position;
    final pageLoadTrigger = 0.7 * position.maxScrollExtent;
    final shouldLoadNextPage = position.pixels > pageLoadTrigger
        && !widget.itemsLoading;

    if (!shouldLoadNextPage) {
      return;
    }

    widget.onLoadNextPage?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.noItemsBuilder != null &&
        (widget.items?.isEmpty ?? true) &&
        !widget.itemsLoading) {
      return ExpandableScrollView(
        padding: widget.padding ?? EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.headerBuilder != null)
              widget.headerBuilder!(context),
            Expanded(
              child: widget.noItemsBuilder!(context),
            ),
          ],
        ),
      );
    }

    return AnimatedList(
      key: _listKey,
      padding: widget.padding,
      controller: _scrollController,
      physics: widget.physics,
      initialItemCount: (widget.items?.length ?? 0)
          + ((widget.pageInfo?.hasNextPage ?? true) ? 1 : 0)
          + (widget.headerBuilder != null ? 1 : 0),
      itemBuilder: (context, index, animation) {
        if (index == 0 && widget.headerBuilder != null) {
          return widget.headerBuilder!(context);
        }

        final itemIndex = index - (widget.headerBuilder != null ? 1 : 0);

        if (widget.items?.isEmpty ?? true) {
          return const SizedBox.shrink();
        }

        if (itemIndex >= widget.items!.length && (widget.pageInfo?.hasNextPage ?? true)) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (itemIndex >= widget.items!.length) {
          return const SizedBox.shrink();
        }

        return FadeTransition(
          opacity: animation,
          child: widget.itemBuilder(context, widget.items![itemIndex], itemIndex),
        );
      },
    );
  }
}
