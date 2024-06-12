import 'package:flutter/material.dart';
import 'package:yes_or_no/src/widget/swipe_cards/draggable_card.dart';
import 'package:yes_or_no/src/widget/swipe_cards/enum/slide_direction.dart';
import 'package:yes_or_no/src/widget/swipe_cards/enum/slide_region.dart';
import 'package:yes_or_no/src/widget/swipe_cards/match_engine.dart';

class SwipeCards extends StatefulWidget {
  final MatchEngine matchEngine;
  final bool fillSpace;
  final bool upSwipeAllowed;
  final bool leftSwipeAllowed;
  final bool rightSwipeAllowed;
  final Widget? upTag;
  final Widget? leftTag;
  final Widget? rightTag;
  final IndexedWidgetBuilder itemBuilder;
  final Function(int index, SlideRegion region)? onSlideRegionUpdate;
  final Function(int index, SlideDirection direction) onItemSlided;
  final Function onStackFinished;

  const SwipeCards({
    super.key,
    required this.matchEngine,
    this.fillSpace = true,
    this.upSwipeAllowed = false,
    this.leftSwipeAllowed = true,
    this.rightSwipeAllowed = true,
    this.upTag,
    this.leftTag,
    this.rightTag,
    required this.itemBuilder,
    this.onSlideRegionUpdate,
    required this.onItemSlided,
    required this.onStackFinished,
  });

  @override
  State<SwipeCards> createState() => _SwipeCardsState();
}

class _SwipeCardsState extends State<SwipeCards> {
  late UniqueKey _frontCardKey = UniqueKey();
  late UniqueKey _backCardKey = UniqueKey();

  int? _currentIndex;

  // SwipeItem? _currentItem;
  double _nextCardScale = 0.9;
  SlideRegion _slideRegion = SlideRegion.none;

  @override
  void initState() {
    widget.matchEngine.addListener(_onMatchEngineChange);
    _currentIndex = widget.matchEngine.index;

    _frontCardKey = UniqueKey();
    _backCardKey = UniqueKey();

    super.initState();
  }

  @override
  void didUpdateWidget(SwipeCards oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.matchEngine != oldWidget.matchEngine) {
      oldWidget.matchEngine.removeListener(_onMatchEngineChange);
      widget.matchEngine.addListener(_onMatchEngineChange);
    }

    _nextCardScale = 0.9;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: widget.fillSpace == true ? StackFit.expand : StackFit.loose,
      children: <Widget>[
        if (!widget.matchEngine.isLast )
          DraggableCard(
            isDraggable: false,
            card: _buildBackCard(),
            isBackCard: true,
          ),
        if (!widget.matchEngine.isFinish)
          DraggableCard(
            card: _buildFrontCard(),
            upTag: widget.upTag,
            leftTag: widget.leftTag,
            rightTag: widget.rightTag,
            onSlideUpdate: _onSlideUpdate,
            onSlideRegionUpdate: _onSlideRegion,
            onSlideOutComplete: _onSlideOutComplete,
            upSwipeAllowed: widget.upSwipeAllowed,
            leftSwipeAllowed: widget.leftSwipeAllowed,
            rightSwipeAllowed: widget.rightSwipeAllowed,
            isBackCard: false,
          ),
      ],
    );
  }

  @override
  void dispose() {
    widget.matchEngine.removeListener(_onMatchEngineChange);

    super.dispose();
  }

  void _onMatchEngineChange() {
    setState(() {
      final isNext = _currentIndex == widget.matchEngine.previousIndex;
      final isPrevious = _currentIndex == widget.matchEngine.nextIndex;

      if (isNext) {
        _frontCardKey = _backCardKey;
        _backCardKey = UniqueKey();
      } else if (isPrevious) {
        _frontCardKey = UniqueKey();
        _backCardKey = _frontCardKey;
      } else {
        _frontCardKey = UniqueKey();
        _backCardKey = UniqueKey();
      }
    });
  }

  Widget _buildFrontCard() {
    return Container(
      key: _frontCardKey,
      child: widget.itemBuilder(context, widget.matchEngine.index),
    );
  }

  Widget _buildBackCard() {
    return Transform(
      key: _backCardKey,
      transform: Matrix4.identity()..scale(_nextCardScale, _nextCardScale),
      alignment: Alignment.center,
      child: widget.itemBuilder(context, widget.matchEngine.nextIndex!),
    );
  }

  void _onSlideUpdate(double distance) {
    setState(() {
      _nextCardScale = 0.9 + (0.1 * (distance / 100.0)).clamp(0.0, 0.1);
    });
  }

  void _onSlideRegion(SlideRegion region) {
    if (_slideRegion != region) {
      _slideRegion = region;

      final index = widget.matchEngine.index;
      widget.onSlideRegionUpdate?.call(index, region);
    }
  }

  void _onSlideOutComplete(SlideDirection direction) {
    widget.onItemSlided(widget.matchEngine.index, direction);

    widget.matchEngine.match();
    if (widget.matchEngine.isFinish) {
      widget.onStackFinished();
    }
  }
}
