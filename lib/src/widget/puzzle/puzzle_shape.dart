import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:yes_or_no/src/widget/puzzle/enum/chimera.dart';

class PuzzleShape extends ShapeBorder {
  final double? holeGap;
  final Chimera? top;
  final Chimera? left;
  final Chimera? right;
  final Chimera? bottom;

  const PuzzleShape({
    this.holeGap,
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder scale(double t) => this;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    const radius = Radius.circular(16);

    final holeGap = this.holeGap ?? (rect.height > rect.width ? rect.width : rect.height) * .1;

    final rRect = RRect.fromRectAndCorners(
      rect.deflate(holeGap),
      bottomLeft: radius,
      bottomRight: radius,
      topLeft: radius,
      topRight: radius,
    );

    Path path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRRect(rRect);

    if (top != null) {
      path.addArc(
        Rect.fromCircle(
          center: Offset(rRect.left + rRect.width / 2, rRect.top),
          radius: holeGap,
        ),
        top == Chimera.convex ? 2 * pi / 2 : 4 * pi / 2,
        pi,
      );
    }

    if (left != null) {
      path.addArc(
        Rect.fromCircle(
          center: Offset(rRect.left, rRect.top + rRect.height / 2),
          radius: holeGap,
        ),
        left == Chimera.convex ? -3 * pi / 2 : 3 * pi / 2,
        pi,
      );
    }

    if (right != null) {
      path.addArc(
        Rect.fromCircle(
          center: Offset(rRect.right, rRect.top + rRect.height / 2),
          radius: holeGap,
        ),
        right == Chimera.convex ? 3 * pi / 2 : -3 * pi / 2,
        pi,
      );
    }

    if (bottom != null) {
      path.addArc(
        Rect.fromCircle(
          center: Offset(rRect.left + rRect.width / 2, rRect.bottom),
          radius: holeGap,
        ),
        bottom == Chimera.convex ? 4 * pi / 2 : 2 * pi / 2,
        pi,
      );
    }

    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}
}
