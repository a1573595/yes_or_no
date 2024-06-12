import 'dart:math';

import 'package:flutter/material.dart';
import 'package:yes_or_no/src/widget/swipe_cards/enum/slide_direction.dart';
import 'package:yes_or_no/src/widget/swipe_cards/enum/slide_region.dart';

class DraggableCard extends StatefulWidget {
  final bool upSwipeAllowed;
  final bool leftSwipeAllowed;
  final bool rightSwipeAllowed;
  final bool isDraggable;
  final bool isBackCard;
  final Widget card;
  final Widget? upTag;
  final Widget? leftTag;
  final Widget? rightTag;
  final Function(double distance)? onSlideUpdate;
  final Function(SlideRegion slideRegion)? onSlideRegionUpdate;
  final Function(SlideDirection direction)? onSlideOutComplete;

  const DraggableCard({
    super.key,
    this.upSwipeAllowed = false,
    this.leftSwipeAllowed = true,
    this.rightSwipeAllowed = true,
    this.isDraggable = true,
    this.isBackCard = false,
    required this.card,
    this.upTag,
    this.leftTag,
    this.rightTag,
    this.onSlideUpdate,
    this.onSlideOutComplete,
    this.onSlideRegionUpdate,
  });

  @override
  State<DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard> with TickerProviderStateMixin {
  GlobalKey profileCardKey = GlobalKey(debugLabel: 'profile_card_key');
  Offset? cardOffset = const Offset(0.0, 0.0);
  Offset? dragStart;
  Offset? dragPosition;
  Offset? slideBackStart;
  SlideDirection slideOutDirection = SlideDirection.none;
  SlideRegion slideRegion = SlideRegion.none;
  late AnimationController slideBackAnimation;
  Tween<Offset>? slideOutTween;
  late AnimationController slideOutAnimation;

  RenderBox? box;
  Rect? anchorBounds;

  bool isAnchorInitialized = false;

  @override
  void initState() {
    super.initState();

    slideBackAnimation = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )
      ..addListener(() => setState(() {
            cardOffset = Offset.lerp(
              slideBackStart,
              const Offset(0.0, 0.0),
              Curves.linear.transform(slideBackAnimation.value),
            );

            if (null != widget.onSlideUpdate) {
              widget.onSlideUpdate!(cardOffset!.distance);
            }

            if (null != widget.onSlideRegionUpdate) {
              widget.onSlideRegionUpdate!(slideRegion);
            }
          }))
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            dragStart = null;
            slideBackStart = null;
            dragPosition = null;
          });

          slideRegion = SlideRegion.none;
          if (null != widget.onSlideRegionUpdate) {
            widget.onSlideRegionUpdate!(slideRegion);
          }
        }
      });

    slideOutAnimation = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )
      ..addListener(() {
        setState(() {
          cardOffset = slideOutTween!.evaluate(slideOutAnimation);

          if (null != widget.onSlideUpdate) {
            widget.onSlideUpdate!(cardOffset!.distance);
          }

          if (null != widget.onSlideRegionUpdate) {
            widget.onSlideRegionUpdate!(slideRegion);
          }
        });
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            dragStart = null;
            dragPosition = null;
            slideOutTween = null;

            if (widget.onSlideOutComplete != null) {
              widget.onSlideOutComplete!(slideOutDirection);
            }
          });
        }
      });
  }

  @override
  void didUpdateWidget(DraggableCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.card.key != oldWidget.card.key) {
      cardOffset = const Offset(0.0, 0.0);
      slideOutDirection = SlideDirection.none;
      slideRegion = SlideRegion.none;
    }
  }

  @override
  void dispose() {
    slideOutAnimation.dispose();
    slideBackAnimation.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    dragStart = details.globalPosition;

    if (slideBackAnimation.isAnimating) {
      slideBackAnimation.stop(canceled: true);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final isInLeftRegion = (cardOffset!.dx / context.size!.width) < -0.15;
    final isInRightRegion = (cardOffset!.dx / context.size!.width) > 0.15;
    final isInTopRegion = (cardOffset!.dy / context.size!.height) < -0.1;

    setState(() {
      if (isInLeftRegion || isInRightRegion) {
        slideRegion = isInLeftRegion ? SlideRegion.inLeft : SlideRegion.inRight;
      } else if (isInTopRegion) {
        slideRegion = SlideRegion.inTop;
      } else {
        slideRegion = SlideRegion.none;
      }

      dragPosition = details.globalPosition;
      cardOffset = Offset(dragPosition!.dx - dragStart!.dx, 0);

      if (null != widget.onSlideUpdate) {
        widget.onSlideUpdate!(cardOffset!.distance);
      }

      if (null != widget.onSlideRegionUpdate) {
        widget.onSlideRegionUpdate!(slideRegion);
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final dragVector = cardOffset! / cardOffset!.distance;

    final isInLeftRegion = (cardOffset!.dx / context.size!.width) < -0.35;
    final isInRightRegion = (cardOffset!.dx / context.size!.width) > 0.35;
    final isInTopRegion = (cardOffset!.dy / context.size!.height) < -0.35;

    setState(() {
      if (isInLeftRegion) {
        if (widget.leftSwipeAllowed) {
          slideOutTween = Tween(begin: cardOffset, end: dragVector * (2 * context.size!.width));
          slideOutAnimation.forward(from: 0.0);

          slideOutDirection = SlideDirection.left;
        } else {
          slideBackStart = cardOffset;
          slideBackAnimation.forward(from: 0.0);
        }
      } else if (isInRightRegion) {
        if (widget.rightSwipeAllowed) {
          slideOutTween = Tween(begin: cardOffset, end: dragVector * (2 * context.size!.width));
          slideOutAnimation.forward(from: 0.0);

          slideOutDirection = SlideDirection.right;
        } else {
          slideBackStart = cardOffset;
          slideBackAnimation.forward(from: 0.0);
        }
      } else if (isInTopRegion) {
        if (widget.upSwipeAllowed) {
          slideOutTween = Tween(begin: cardOffset, end: dragVector * (2 * context.size!.height));
          slideOutAnimation.forward(from: 0.0);

          slideOutDirection = SlideDirection.up;
        } else {
          slideBackStart = cardOffset;
          slideBackAnimation.forward(from: 0.0);
        }
      } else {
        slideBackStart = cardOffset;
        slideBackAnimation.forward(from: 0.0);
      }

      if (null != widget.onSlideRegionUpdate) {
        widget.onSlideRegionUpdate!(slideRegion);
      }
    });
  }

  double _rotation(Rect? dragBounds) {
    if (dragStart != null) {
      return (pi / 8) * (cardOffset!.dx / dragBounds!.width);
    } else {
      return 0.0;
    }
  }

  Offset _rotationOrigin(Rect? dragBounds) {
    if (dragStart != null) {
      return dragStart! - dragBounds!.topLeft;
    } else {
      return const Offset(0.0, 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isAnchorInitialized) {
      _initAnchor();
    }

    // Disables dragging card while slide out animation is in progress. Solves
    // issue that fast swipes cause the back card not loading
    if (widget.isBackCard && anchorBounds != null && cardOffset!.dx < anchorBounds!.height) {
      cardOffset = Offset.zero;
    }

    final angle = _rotation(anchorBounds);
    final opacity = _calculateOpacity(angle);

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform(
          transform: Matrix4.translationValues(cardOffset!.dx, cardOffset!.dy, 0.0)..rotateZ(angle),
          origin: _rotationOrigin(anchorBounds),
          child: SizedBox(
            key: profileCardKey,
            width: anchorBounds?.width,
            height: anchorBounds?.height,
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: widget.card,
            ),
          ),
        ),
        if (widget.upTag != null)
          Positioned(
            top: 32,
            child: Visibility(
              visible: slideRegion == SlideRegion.inTop,
              child: widget.upTag!,
            ),
          ),
        if (widget.leftTag != null)
          Positioned(
            left: 24,
            child: Visibility(
              visible: slideRegion == SlideRegion.inLeft,
              child: Opacity(
                opacity: opacity,
                child: widget.leftTag!,
              ),
            ),
          ),
        if (widget.rightTag != null)
          Positioned(
            right: 20,
            child: Visibility(
              visible: slideRegion == SlideRegion.inRight,
              child: Opacity(
                opacity: opacity,
                child: widget.rightTag!,
              ),
            ),
          ),
      ],
    );
  }

  _initAnchor() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      box = context.findRenderObject() as RenderBox?;
      final topLeft = box!.size.topLeft(box!.localToGlobal(const Offset(0.0, 0.0)));
      final bottomRight = box!.size.bottomRight(box!.localToGlobal(const Offset(0.0, 0.0)));
      anchorBounds = Rect.fromLTRB(
        topLeft.dx,
        topLeft.dy,
        bottomRight.dx,
        bottomRight.dy,
      );

      setState(() {
        isAnchorInitialized = true;
      });
    });
  }

  double _calculateOpacity(double angle) {
    if (angle < 0) {
      angle = -angle;
    }

    angle *= 5;

    return angle >= 1
        ? 1.0
        : angle <= 0
            ? 0.0
            : angle;
  }
}
