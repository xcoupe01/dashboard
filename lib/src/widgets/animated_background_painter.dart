part of dashboard;

class RRectTween extends Tween<RRect?> {
  RRectTween({ super.begin, super.end });

  @override
  RRect? lerp(double t) => RRect.lerp(begin, end, t);
}

class _AnimatedBackgroundPainter extends StatefulWidget {
  const _AnimatedBackgroundPainter(
      {Key? key,
      required this.layoutController,
      required this.editModeSettings,
      required this.offset})
      : super(key: key);

  final _DashboardLayoutController layoutController;
  final EditModeSettings editModeSettings;
  final ViewportOffset offset;

  @override
  State<_AnimatedBackgroundPainter> createState() =>
      _AnimatedBackgroundPainterState();
}

class _AnimatedBackgroundPainterState extends State<_AnimatedBackgroundPainter>
    with SingleTickerProviderStateMixin {
  _ViewportDelegate get viewportDelegate =>
      widget.layoutController._viewportDelegate;

  RRect? fillRect;

  late double offset;

  late AnimationController _animationController;

  Animation<RRect?>? _animation;

  @override
  void initState() {
    offset = widget.offset.pixels;
    _animationController = AnimationController(
        vsync: this, duration: widget.editModeSettings.duration);
    super.initState();
  }

  bool onAnimation = false;

  RRect? _last;

  DateTime? _start;

  @override
  Widget build(BuildContext context) {
    if (widget.editModeSettings.fillEditingBackground &&
        widget.layoutController.editSession != null) {
      var pos = widget.layoutController.editSession?.editing._currentPosition(
          viewportDelegate: widget.layoutController._viewportDelegate,
          slotEdge: widget.layoutController.slotEdge,
          verticalSlotEdge: widget.layoutController.verticalSlotEdge);
      var rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(pos!.x - viewportDelegate.padding.left,
              pos.y - offset - viewportDelegate.padding.top, pos.width, pos.height),
          Radius.circular(widget.editModeSettings.backgroundStyle.fillRadius));

      if (fillRect != null && fillRect != rect) {
        var begin = fillRect!;

        if (onAnimation && _last != null && _start != null) {
          begin = _last!;

          _animationController.duration = (widget.editModeSettings.duration -
                  DateTime.now().difference(_start!).abs())
              .abs();
        } else {
          _start = DateTime.now();
          _last = fillRect;
          _animationController.duration = widget.editModeSettings.duration;
        }
        _animationController.reset();
        _animation = RRectTween(begin: begin, end: rect).animate(CurvedAnimation(
            parent: _animationController,
            curve: widget.editModeSettings.curve));
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          onAnimation = true;
          _animationController.forward().then((value) {
            _animationController.duration = widget.editModeSettings.duration;
            onAnimation = false;
            _last = null;
            _start = null;
          });
        });
      }
      fillRect = rect;
    }

    if (widget.layoutController.editSession == null ||
        !widget.editModeSettings.fillEditingBackground) {
      fillRect = null;
      _animation = null;
      onAnimation = false;
      _last = null;
      _animationController.duration = widget.editModeSettings.duration;
      _start = null;
    }

    if (_animation != null && offset == widget.offset.pixels) {
      offset = widget.offset.pixels;
      return AnimatedBuilder(
          animation: _animation!,
          builder: (context, child) {
            _last = _animation!.value;
            return CustomPaint(
              painter: _EditModeBackgroundPainter(
                  verticalSlotEdge: widget.layoutController.verticalSlotEdge,
                  fillPosition: _animation!.value,
                  slotCount: widget.layoutController.slotCount,
                  style: widget.editModeSettings.backgroundStyle,
                  slotEdge: widget.layoutController.slotEdge,
                  offset: widget.offset.pixels,
                  viewportDelegate: widget.layoutController._viewportDelegate),
              isComplex: true,
            );
          });
    } else {
      _last = null;
      onAnimation = false;
      _start = null;
      _animationController.duration = widget.editModeSettings.duration;
      offset = widget.offset.pixels;
      return CustomPaint(
        painter: _EditModeBackgroundPainter(
            fillPosition: fillRect,
            verticalSlotEdge: widget.layoutController.verticalSlotEdge,
            slotCount: widget.layoutController.slotCount,
            style: widget.editModeSettings.backgroundStyle,
            slotEdge: widget.layoutController.slotEdge,
            offset: widget.offset.pixels,
            viewportDelegate: widget.layoutController._viewportDelegate),
        isComplex: false,
      );
    }
  }
}
