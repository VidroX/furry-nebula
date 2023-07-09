import 'package:flutter/material.dart';

typedef OverlayBuilder = Widget Function(BuildContext context, OverlayFollowerActions controller);

class OverlayFollower extends StatefulWidget {
  final OverlayBuilder targetBuilder;
  final OverlayBuilder overlayBuilder;
  final double? width;
  final double? height;
  final OverlayPosition position;
  final bool barrierDismissible;

  const OverlayFollower({
    required this.targetBuilder,
    required this.overlayBuilder,
    this.position = OverlayPosition.auto,
    this.height = 230,
    this.barrierDismissible = true,
    this.width,
    super.key,
  });

  @override
  State<OverlayFollower> createState() => _OverlayFollowerState();
}

class _OverlayFollowerState extends State<OverlayFollower> with OverlayFollowerActions {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => CompositedTransformTarget(
    key: _target,
    link: _link,
    child: widget.targetBuilder(context, this),
  );
}

mixin OverlayFollowerActions on State<OverlayFollower> {
  static const _overlayOffset = 8.0;

  final _target = GlobalKey();
  final _link = LayerLink();

  OverlayEntry? _overlayEntry;
  bool isShown = false;

  void toggleOverlay() {
    setState(() => isShown = !isShown);

    _updateOverlay();
  }

  void setVisibility({ bool visible = false }) {
    setState(() => isShown = visible);

    _updateOverlay();
  }

  void _buildOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          if (widget.barrierDismissible)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: setVisibility,
              ),
            ),
          Positioned(
            width: widget.width ?? _targetSize?.width,
            height: widget.height,
            child: CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              targetAnchor: _position == OverlayPosition.top
                  ? Alignment.topLeft
                  : Alignment.bottomLeft,
              offset: Offset(
                0,
                _position == OverlayPosition.top
                    ? -((widget.height ?? 0) + _overlayOffset)
                    : _overlayOffset,
              ),
              child: Material(
                color: Colors.transparent,
                child: widget.overlayBuilder(context, this),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateOverlay() {
    if (!isShown) {
      _overlayEntry?.remove();
      _overlayEntry = null;

      return;
    }

    if (_overlayEntry == null) {
      _buildOverlay();
    }

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    super.dispose();
  }

  Size? get _targetSize {
    if (_target.currentContext == null) {
      return null;
    }

    final targetContext = _target.currentContext!;
    final targetRenderObject = targetContext.findRenderObject();

    if (targetRenderObject == null) {
      return null;
    }

    final targetRenderBox = targetRenderObject as RenderBox;

    return targetRenderBox.size;
  }

  OverlayPosition get _position {
    if (widget.position != OverlayPosition.auto) {
      return widget.position;
    }

    if (_target.currentContext == null) {
      return OverlayPosition.bottom;
    }

    final targetContext = _target.currentContext!;
    final targetRenderObject = targetContext.findRenderObject();

    if (targetRenderObject == null) {
      return OverlayPosition.bottom;
    }

    final targetRenderBox = targetRenderObject as RenderBox;

    final targetSize = targetRenderBox.size;
    final targetOffset = targetRenderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

    final distanceToBottom = screenSize.height
        - (targetOffset.dy + targetSize.height);

    final remainingDistanceToBottom = distanceToBottom
        - _overlayOffset
        - (widget.height ?? 0);

    return remainingDistanceToBottom >= 12
        ? OverlayPosition.bottom
        : OverlayPosition.top;
  }
}

enum OverlayPosition {
  auto,
  top,
  bottom;
}
