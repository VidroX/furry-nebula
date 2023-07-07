import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:furry_nebula/models/pagination/graph_page.dart';
import 'package:furry_nebula/widgets/layout/expandable_scroll_view.dart';

class NebulaApiGrid<T> extends StatefulWidget {
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
  final SliverGridDelegate gridDelegate;

  const NebulaApiGrid({
    required this.itemBuilder,
    this.gridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
    ),
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
  State<NebulaApiGrid<T>> createState() => NebulaApiGridState();
}

class NebulaApiGridState<T> extends State<NebulaApiGrid<T>> {
  static const _animationDuration = Duration(milliseconds: 200);

  final _gridKey = GlobalKey<SliverAnimatedGridState>();

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_loadNextPage);

    _gridKey.currentState?.insertAllItems(0, widget.items?.length ?? 0);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_loadNextPage);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NebulaApiGrid<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.items == widget.items) {
      return;
    }

    final addedItems = widget.items
        ?.where((item) => !(oldWidget.items?.contains(item) ?? false))
        .toList() ?? [];

    if (addedItems.isEmpty) {
      return;
    }

    for (final item in addedItems) {
      _gridKey.currentState?.insertItem(
        widget.items?.indexOf(item) ?? 0,
        duration: _animationDuration,
      );
    }
  }

  void removeItem(int index) {
    if ((widget.items?.length ?? 0) - 1 < index) {
      return;
    }

    final itemIndex = min(index, widget.items!.length - 1);

    _gridKey.currentState?.removeItem(
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

  void resetAll() {
    _gridKey.currentState?.removeAllItems(
      (context, animation) => FadeTransition(
        opacity: animation,
        child: const SizedBox.shrink(),
      ),
      duration: Duration.zero,
    );

    _gridKey.currentState?.insertAllItems(
      0,
      widget.items?.length ?? 0,
      duration: _animationDuration,
    );
  }

  void resetIndex(int index) {
    if (index < 0 || index >= (widget.items?.length ?? 0)) {
      return;
    }

    _gridKey.currentState?.removeItem(
      index,
      (context, animation) => FadeTransition(
        opacity: animation,
        child: const SizedBox.shrink(),
      ),
      duration: Duration.zero,
    );

    _gridKey.currentState?.insertItem(
      0,
      duration: _animationDuration,
    );
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

    return _NebulaGridView<T>(
      gridKey: _gridKey,
      scrollController: _scrollController,
      gridDelegate: widget.gridDelegate,
      items: widget.items,
      pageInfo: widget.pageInfo,
      itemBuilder: widget.itemBuilder,
      headerBuilder: widget.headerBuilder,
      physics: widget.physics,
      padding: widget.padding,
      loading: widget.itemsLoading,
    );
  }
}

class _NebulaGridView<T> extends StatelessWidget {
  final List<T>? items;
  final GraphPageInfo? pageInfo;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context)? headerBuilder;
  final ScrollPhysics physics;
  final EdgeInsetsGeometry? padding;
  final Key gridKey;
  final ScrollController scrollController;
  final SliverGridDelegate gridDelegate;
  final int initialItemCount;
  final bool loading;

  const _NebulaGridView({
    required this.gridKey,
    required this.scrollController,
    required this.itemBuilder,
    required this.gridDelegate,
    this.initialItemCount = 0,
    this.physics = const BouncingScrollPhysics(),
    this.loading = false,
    this.items,
    this.headerBuilder,
    this.pageInfo,
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) => CustomScrollView(
    physics: physics,
    controller: scrollController,
    slivers: [
      if (headerBuilder != null)
        SliverPadding(
          padding: EdgeInsetsDirectional.only(
            start: (padding?.vertical ?? 0) / 2,
            end: (padding?.horizontal ?? 0) / 2,
            top: (padding?.horizontal ?? 0) / 2,
          ),
          sliver: SliverToBoxAdapter(
            child: headerBuilder!(context),
          ),
        ),
      SliverPadding(
        padding: EdgeInsetsDirectional.only(
          start: (padding?.vertical ?? 0) / 2,
          end: (padding?.horizontal ?? 0) / 2,
          bottom: (padding?.horizontal ?? 0) / 2,
        ),
        sliver: SliverAnimatedGrid(
          key: gridKey,
          gridDelegate: gridDelegate,
          initialItemCount: items?.length ?? 0,
          itemBuilder: (context, index, animation) {
            if (items?.isEmpty ?? true) {
              return const SizedBox.shrink();
            }

            return FadeTransition(
              opacity: animation,
              child: itemBuilder(context, items![index], index),
            );
          },
        ),
      ),
      if (loading)
        SliverToBoxAdapter(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 100),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
    ],
  );
}
