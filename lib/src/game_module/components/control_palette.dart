// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


const int ROUND_BUTTON_RADIUS = 18;
const int OPTION_RADIUS = 70;
const num EXTRA_RADIUS_LIMIT = 50;
const num MAX_EXTRA_RADIUS = 15;

class PaletteOption {
  final String icon;
  final Function callback;

  PaletteOption(this.icon, this.callback);

  component(Point p, String c) => react.button({
    'className': 'circular ui ${c} icon button',
    'style': {
      'position': 'absolute',
      'top': p.y - ROUND_BUTTON_RADIUS,
      'left': p.x - ROUND_BUTTON_RADIUS,
    }
  }, react.i({'className': 'icon ${icon}'}));
}

class ControlPaletteConfig {
  final List<PaletteOption> options;

  ControlPaletteConfig(this.options);
}

const SHOW_PALETTE_DELAY = const Duration(milliseconds: 200);


var ControlPalette = react.registerComponent(() => new _ControlPalette());
class _ControlPalette extends w_flux.FluxComponent<GameActions, GameStore> {
  Timer _showPaletteTimer;
  List<StreamSubscription> _subs = new List<StreamSubscription>();

  Map<String, Function> _handlers = new Map<String, Function>();

  Point get startPoint => state['startPoint'];

  Point get currentPoint => state['currentPoint'];

  getInitialState() => {
    'startPoint': new Point(0, 0),
    'currentPoint': new Point(0, 0),
  };

  Element get startIcon => react.findDOMNode(ref('start-icon'));

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
    int optIndex = 0;
    List<Point> points = _getOptionPoints(store.paletteConfig?.options);
    List optionItems = new List();
    if (store.paletteConfig != null) store.paletteConfig.options.forEach((opt) {
      num dist = points[optIndex].distanceTo(currentPoint);
      optionItems.add(opt.component(points[optIndex], dist < ROUND_BUTTON_RADIUS ? 'white' : 'blue'));
      optIndex++;
    });

    return react.div({'style': {
      'position': 'absolute',
      'top': 0,
      'left': 0,
      'width': '100%',
      'height': '100%',
      'color': 'white',
    }}, optionItems);
  }

  List<Point> _getOptionPoints(List<PaletteOption> options) {
    int optIndex = 0;
    List<Point> points = new List<Point>();
    if (options != null) options.forEach((opt) {
      num angle = PI / 5 * optIndex - PI / 2;
      Point basePoint = new Point(
        cos(angle) * OPTION_RADIUS + startPoint.x,
        sin(angle) * OPTION_RADIUS + startPoint.y
      );
      num dist = basePoint.distanceTo(currentPoint);
      num extraRadius = (EXTRA_RADIUS_LIMIT - (dist.clamp(0, EXTRA_RADIUS_LIMIT))) / EXTRA_RADIUS_LIMIT * MAX_EXTRA_RADIUS;
      points.add(new Point(
        cos(angle) * (OPTION_RADIUS + extraRadius) + startPoint.x,
        sin(angle) * (OPTION_RADIUS + extraRadius) + startPoint.y
      ));
      optIndex++;
    });
    return points;
  }

  // Specific Handlers

  _handleMouseDown(MouseEvent e) => interactionBegan(e.client, false);
  _handleMouseMove(MouseEvent e) => interactionMoved(e.client);
  _handleMouseUp(MouseEvent e) => interactionEnded(e.client);

  _handleTouchStart(TouchEvent e) => interactionBegan(e.touches.first.client, true);
  _handleTouchMove(TouchEvent e) => interactionMoved(e.touches.first.client);
  _handleTouchEnd(TouchEvent e) => interactionEnded(e.touches.first.client);
  _handleTouchCancel(TouchEvent e) => interactionEnded(e.touches.first.client);

  // Generic Handlers

  interactionBegan(Point p, bool touch) {
    if (store.paletteConfig == null) return;
    setState({'startPoint': p, 'currentPoint': p});
    if (touch) showPalette();
    else startTimer();
  }

  interactionMoved(Point p) {
    if (store.paletteConfig == null) return;
    setState({'currentPoint': p});
  }

  interactionEnded(Point p) {
    if (store.paletteConfig == null) return;
    // callbackSelectedOption();
    cancelTimer();
    if (store.dimmerVisible) hidePalette();
    actions.configureControlPalette(null);
  }

  // callbackSelectedOption() {
  //   int optIndex = 0;
  //   List<Point> points = _getOptionPoints(store.paletteConfig.options);
  //   points.forEach((point) {
  //     num dist = point.distanceTo(currentPoint);
  //     if (dist < ROUND_BUTTON_RADIUS) store.paletteConfig.options[optIndex].callback();
  //     optIndex++;
  //   });
  // }

  // Timer Methods

  startTimer() {
    _showPaletteTimer = new Timer(SHOW_PALETTE_DELAY, showPalette);
  }

  cancelTimer() {
    if (_showPaletteTimer != null) _showPaletteTimer.cancel();
    _showPaletteTimer = null;
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
