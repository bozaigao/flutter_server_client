import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OpacityButton extends StatefulWidget {
  final double opacityValue;
  final Widget child;
  final bool disabled;
  final Function onTap;
  final Function onTapDown;
  final Function onTapUp;
  final Function onTapCancel;

  const OpacityButton(
      {Key key,
      this.opacityValue = 0.5,
      this.disabled = false,
      this.onTapDown,
      this.onTapUp,
      this.onTapCancel,
      @required this.child,
      this.onTap})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _OpacityButtonState();
  }
}

class _OpacityButtonState extends State<OpacityButton> {
  double opacity = 1;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        if (widget.onTapDown != null) {
          widget.onTapDown();
        }
        setState(() {
          opacity = widget.opacityValue;
        });
      },
      onTapUp: (TapUpDetails details) {
        if (widget.onTapUp != null) {
          widget.onTapUp();
        }
        setState(() {
          opacity = 1;
        });
      },
      onTapCancel: () {
        if (widget.onTapCancel != null) {
          widget.onTapCancel();
        }
        setState(() {
          opacity = 1;
        });
      },
      onTap: () {
        if (!widget.disabled) {
          widget.onTap();
        }
      },
      child: Opacity(
          opacity: widget.disabled ? widget.opacityValue : opacity,
          child: widget.child),
    );
  }
}
