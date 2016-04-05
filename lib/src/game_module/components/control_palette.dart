// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

class ControlPaletteConfig {

  ControlPaletteConfig();
}

const SHOW_PALETTE_DELAY = const Duration(milliseconds: 200);


var ControlPalette = react.registerComponent(() => new _ControlPalette());
class _ControlPalette extends w_flux.FluxComponent<GameActions, GameStore> {
  Timer _showPaletteTimer;
  List<StreamSubscription> _subs = new List<StreamSubscription>();

  Map<String, Function> _handlers = new Map<String, Function>();

  Point get startPoint => state['startPoint'];
  void set startPoint(Point newPoint) => setState({'startPoint': newPoint});

  Point get currentPoint => state['currentPoint'];
  void set currentPoint(Point newPoint) => setState({'currentPoint': newPoint});

  getInitialState() => {
    'startPoint': new Point(0, 0),
    'currentPoint': new Point(0, 0),
  };

  componentWillMount() {
    super.componentWillMount();

    _handlers['_handleMouseDown'] = _handleMouseDown;
    _handlers['_handleMouseMove'] = _handleMouseMove;
    _handlers['_handleMouseUp'] = _handleMouseUp;
    _handlers['_handleTouchStart'] = _handleTouchStart;
    _handlers['_handleTouchMove'] = _handleTouchMove;
    _handlers['_handleTouchEnd'] = _handleTouchEnd;
    _handlers['_handleTouchCancel'] = _handleTouchCancel;

    _subs.add(document.onMouseDown.listen(_handlers['_handleMouseDown']));
    _subs.add(document.onMouseMove.listen(_handlers['_handleMouseMove']));
    _subs.add(document.onMouseUp.listen(_handlers['_handleMouseUp']));
    _subs.add(document.onTouchStart.listen(_handlers['_handleTouchStart']));
    _subs.add(document.onTouchMove.listen(_handlers['_handleTouchMove']));
    _subs.add(document.onTouchEnd.listen(_handlers['_handleTouchEnd']));
    _subs.add(document.onTouchCancel.listen(_handlers['_handleTouchCancel']));
  }

  componentWillUnmount() {
    super.componentWillUnmount();

    _subs.forEach((sub) => sub.cancel());
  }

  render() {
    return react.div({'style': {
      'position': 'absolute',
      'top': 0,
      'left': 0,
      'width': '100%',
      'height': '100%',
      'color': 'white',
    }}, [
      react.button({
        'className': 'circular ui icon button',
        'style': {
          'position': 'absolute',
          'top': startPoint.y - 18,
          'left': startPoint.x - 18,
        }
      }, react.i({'className': 'icon settings'})),
      react.button({
        'className': 'circular ui icon button',
        'style': {
          'position': 'absolute',
          'top': currentPoint.y - 18,
          'left': currentPoint.x - 18,
        }
      }, react.i({'className': 'icon settings'})),
    ]);
  }

  // Specific Handlers

  _handleMouseDown(MouseEvent e) => interactionBegan(e.client);
  _handleMouseMove(MouseEvent e) => interactionMoved(e.client);
  _handleMouseUp(MouseEvent e) => interactionEnded(e.client);

  _handleTouchStart(TouchEvent e) => interactionBegan(e.touches.first.client);
  _handleTouchMove(TouchEvent e) => interactionMoved(e.touches.first.client);
  _handleTouchEnd(TouchEvent e) => interactionEnded(e.touches.first.client);
  _handleTouchCancel(TouchEvent e) => interactionEnded(e.touches.first.client);

  // Generic Handlers

  interactionBegan(Point p) {
    print('interactionBegan ${p}');
    startPoint = p;
    if (store.confirmNewGameDimmerVisible) return;
    if (store.paletteConfig != null) startTimer();
  }

  interactionMoved(Point p) {
    currentPoint = p;
  }

  interactionEnded(Point p) {
    print('interactionEnded ${p}');
    currentPoint = p;
    cancelTimer();
    if (store.controlPaletteDimmerVisible) hidePalette();
    actions.configureControlPalette(null);
  }

  // Timer Methods

  startTimer() {
    _showPaletteTimer = new Timer(SHOW_PALETTE_DELAY, showPalette);
  }

  cancelTimer() {
    if (_showPaletteTimer != null) _showPaletteTimer.cancel();
  }

  // Palette Visibility Methods

  showPalette() {
    setState({'paletteVisible': true});
    actions.showControlPaletteDimmer(true);
  }

  hidePalette() {
    setState({'paletteVisible': false});
    actions.showControlPaletteDimmer(false);
  }
}
