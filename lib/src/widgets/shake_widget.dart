/*
Added shake animation while in editing mode.
 */

import 'package:flutter/cupertino.dart';
import 'dart:math';

class ShakeWidget extends StatefulWidget {
  const ShakeWidget({
    super.key,
    required this.duration,
    required this.deltaR,
    this.curve = Curves.ease,
    required this.child,
    this.synced = true,
  });

  final Duration duration;
  final double deltaR;
  final Widget child;
  final Curve curve;
  final bool synced;

  @override
  ShakeWidgetState createState() => ShakeWidgetState();
}

class ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    if(!widget.synced){
      controller.value = Random().nextDouble();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) => Transform.rotate(
        angle: controller.isAnimating ?
          widget.deltaR * (widget.curve.transform(controller.value) * 2 - 1):
          0,
        child: child,
      ),
      child: widget.child,
    );
  }
}