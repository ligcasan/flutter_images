import 'package:flutter/material.dart';
import 'package:fluttery/layout.dart';
import 'decision.dart';
import 'image_card.dart';

class CardStack extends StatefulWidget {
  final DecisionEngine decisionEngine;

  CardStack({
    this.decisionEngine
  });

  @override
  _CardStackState createState() => _CardStackState();
}

class _CardStackState extends State<CardStack> {
  Key _frontCard;
  Decision _currentDecision;
  double _nextCardScale = 0.9;

  @override
  void initState() {
    super.initState();
    widget.decisionEngine.addListener(_onDecisionEngineChange);

    _currentDecision = widget.decisionEngine.currentDecision;
    _currentDecision.addListener(_onDecisionChange);

    _frontCard = new Key(_currentDecision.cardBody.title);
  }

  @override
  void didUpdateWidget(CardStack oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.decisionEngine != oldWidget.decisionEngine) {
      oldWidget.decisionEngine.removeListener(_onDecisionEngineChange);
      widget.decisionEngine.addListener(_onDecisionEngineChange);

      if (_currentDecision != null) {
        _currentDecision.removeListener(_onDecisionChange);
      }
      _currentDecision = widget.decisionEngine.currentDecision;

      if (_currentDecision != null) {
        _currentDecision.addListener(_onDecisionChange);
      }
    }
  }

  @override
  void dispose() {
    if (_currentDecision != null) {
      _currentDecision.removeListener(_onDecisionChange);
    }
    widget.decisionEngine.removeListener(_onDecisionEngineChange);
    super.dispose();

  }

  void _onDecisionEngineChange() {

      if (_currentDecision != null) {
        _currentDecision.removeListener(_onDecisionChange);
      }

      _currentDecision = widget.decisionEngine.currentDecision;
      if (_currentDecision != null) {
        _currentDecision.addListener(_onDecisionChange);
      }

      _frontCard = new Key(_currentDecision.cardBody.title);

      setState(() {});
  }

  void _onDecisionChange() {
    setState(() {
    });
  }

  Widget _buildNextCard() {
    return new Transform(
      transform: Matrix4.identity()..scale(_nextCardScale, _nextCardScale),
      alignment: Alignment.center,
      child: new ImageCard(
        cardBody: widget.decisionEngine.nextDecision.cardBody
      ),
    );
  }

  Widget _buildCurrentCard() {
    return new ImageCard(
      key: _frontCard,
      cardBody: widget.decisionEngine.currentDecision.cardBody
    );
  }

  void _onSlideUpdate(double distance) {
    setState(() {
      _nextCardScale = 0.9 + (0.1 * (distance / 100)).clamp(0.0, 0.1);
    });
  }

  void _onSlideOutComplete(SlideDirection direction) {
    Decision currentDecision = widget.decisionEngine.currentDecision;
    switch (direction) {
      case SlideDirection.right:
        currentDecision.like();
        break;
      case SlideDirection.left:
        currentDecision.disLike();
        break;
    }

    widget.decisionEngine.engineCycle();
  }

  @override
  Widget build(BuildContext context) {

    return new Stack(
      children: <Widget>[
        new CardContainer(
          card: _buildNextCard(),
          isDraggable: false,
        ),
        new CardContainer(
          card: _buildCurrentCard(),
          onSlideUpdate: _onSlideUpdate,
          onSlideOutComplete: _onSlideOutComplete,

        ),
      ],
    );
  }
}

enum SlideDirection {
  left,
  right
}

class CardContainer extends StatefulWidget {
  final Widget card;
  final bool isDraggable;
  final SlideDirection slideTo;
  final Function(double distance) onSlideUpdate;
  final Function(SlideDirection direction) onSlideOutComplete;
  final DecisionEngine decisionEngine;

  CardContainer({
    this.card,
    this.isDraggable = true,
    this.slideTo,
    this.onSlideUpdate,
    this.onSlideOutComplete,
    this.decisionEngine
  });

  @override
  _CardContainerState createState() => _CardContainerState();
}

class _CardContainerState extends State<CardContainer> with TickerProviderStateMixin {
  Offset cardOffset = const Offset(0.0, 0.0);
  Offset dragStart;
  Offset dragEnd;
  Offset slingBackStart;
  SlideDirection slideOutDirection;
  AnimationController slingBack;
  Tween<Offset> slingOutTween;
  AnimationController slingOut;

  @override
  void didUpdateWidget(CardContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.card.key != oldWidget.card.key) {
      cardOffset = const Offset(0.0, 0.0);
    }
  }

  @override
  void initState() {
    super.initState();
    slingBack = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this
    )
    ..addListener(() => setState(() {
      cardOffset = Offset.lerp(
        slingBackStart,
        Offset(0.0, 0.0),
        Curves.elasticOut.transform(slingBack.value)
      );

      if (widget.onSlideUpdate != null) {
        widget.onSlideUpdate(cardOffset.distance);
      }
    }))
    ..addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          dragStart = null;
          dragEnd = null;
          slingBackStart = null;
        });
      }
    });

    slingOut = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this
    )
    ..addListener(() {
      setState(() {
        cardOffset = slingOutTween.evaluate(slingOut);

        if (widget.onSlideUpdate != null) {
          widget.onSlideUpdate(cardOffset.distance);
        }
      });
    })
    ..addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          dragStart = null;
          dragEnd = null;
          slingOutTween = null;

          if (widget.onSlideOutComplete != null) {
            widget.onSlideOutComplete(slideOutDirection);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    slingBack.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails position) {
    setState(() {
      dragStart = position.globalPosition;
    });

    if (slingBack.isAnimating) {
      slingBack.stop(canceled: true);
    }
  }

  void _onPanUpdate(DragUpdateDetails position) {
    setState(() {
      dragEnd = position.globalPosition;
      cardOffset = dragEnd - dragStart;

      if (widget.onSlideUpdate != null) {
        widget.onSlideUpdate(cardOffset.distance);
      }
    });
  }

  void _onPanEnd(DragEndDetails offset) {
    final dragVector = cardOffset / cardOffset.distance;
    final isDisLike = (cardOffset.dx / context.size.width) < -0.45;
    final isLike = (cardOffset.dx / context.size.width) > 0.45;

    setState(() {
      if (isDisLike || isLike) {
        slingOutTween = Tween(begin: cardOffset, end: dragVector * (context.size.width * 2));
        slingOut.forward(from: 0.0);

        slideOutDirection = isLike ? SlideDirection.right : SlideDirection.left;
      } else {
        slingBackStart = cardOffset;
        slingBack.forward(from: 0.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return new AnchoredOverlay(
      showOverlay: true,
      child: Center(),
      overlayBuilder: (BuildContext context, Rect anchorBounds, Offset anchor){
        return new CenterAbout(
          position: anchor,
          child: Transform(
            transform: Matrix4.translationValues(cardOffset.dx, cardOffset.dy, 0.0),
            child: Container(
              //decoration: BoxDecoration(border: Border.all(color: Colors.green)),
              width: anchorBounds.width,
              height: anchorBounds.height,
              //padding: EdgeInsets.all(16.0),
              child: GestureDetector(
                child: widget.card,
                onPanStart: widget.isDraggable ? _onPanStart : null,
                onPanUpdate: widget.isDraggable ? _onPanUpdate : null,
                onPanEnd: widget.isDraggable ? _onPanEnd : null,
              )
            )
          ),
        );
      },
    );
  }
}

//56 rotation
//1:04
//1:13
//1:39
//1:55