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

class TileControlPaletteConfig extends ControlPaletteConfig {
  factory TileControlPaletteConfig(Tile tile, GameActions actions) {
    List<PaletteOption> options = [
      new PaletteOption('theme', () => print('change type')),
      new PaletteOption('cube', () => print('change roll')),
      new PaletteOption('user', () => actions.moveThiefToActiveTile()),
      new PaletteOption('remove', () => actions.removeTile(tile.key)),
    ];
    return new TileControlPaletteConfig._internal(options);
  }

  TileControlPaletteConfig._internal(List<PaletteOption> options) : super(options);
}


var ControlPalette = react.registerComponent(() => new _ControlPalette());
class _ControlPalette extends w_flux.FluxComponent<GameActions, GameStore> {
  List<StreamSubscription> _subs = new List<StreamSubscription>();

  Map<String, Function> _handlers = new Map<String, Function>();

  Point get startPoint => state['startPoint'];
  Point get currentPoint => state['currentPoint'];
  ControlPaletteConfig get config => state['config'];

  getInitialState() => stateFromStore();

  stateFromStore() {
    Map<String, dynamic> storeState = new Map<String, dynamic>();
    if (store.currentDimmer == DimmerType.TileOptions) {
      Tile activeTile = store.boardStore.activeTile;
      storeState['config'] = new TileControlPaletteConfig(activeTile, actions);
    } else if (store.currentDimmer == DimmerType.PlotOptions) {
      print('PLOT CONFIG');
      Tile activeTile = store.boardStore.activeTile;
      storeState['config'] = new TileControlPaletteConfig(activeTile, actions);
    }
    storeState['startPoint'] = store.boardStore.activatePoint;
    storeState['currentPoint'] = store.boardStore.activatePoint;
    return storeState;
  }

  setStateFromStore() => setState(stateFromStore());

  Map<w_flux.Store, Function> getStoreHandlers() => { store: (_) => setStateFromStore() };

  bool shouldComponentUpdate(_, nextState) => nextState['currentPoint'] != currentPoint;

  componentWillMount() {
    super.componentWillMount();

    // _handlers['_handleMouseDown'] = _handleMouseDown;
    _handlers['_handleMouseMove'] = _handleMouseMove;
    _handlers['_handleMouseUp'] = _handleMouseUp;
    // _handlers['_handleTouchStart'] = _handleTouchStart;
    _handlers['_handleTouchMove'] = _handleTouchMove;
    _handlers['_handleTouchEnd'] = _handleTouchEnd;
    _handlers['_handleTouchCancel'] = _handleTouchCancel;

    // _subs.add(document.onMouseDown.listen(_handlers['_handleMouseDown']));
    _subs.add(document.onMouseMove.listen(_handlers['_handleMouseMove']));
    _subs.add(document.onMouseUp.listen(_handlers['_handleMouseUp']));
    // _subs.add(document.onTouchStart.listen(_handlers['_handleTouchStart']));
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
    List<Point> points = _getOptionPoints(config.options);
    List optionItems = new List();
    config.options.forEach((opt) {
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

  // _handleMouseDown(MouseEvent e) => interactionBegan(e.client, false);
  _handleMouseMove(MouseEvent e) => interactionMoved(e.client);
  _handleMouseUp(MouseEvent e) => interactionEnded(e.client);

  // _handleTouchStart(TouchEvent e) => interactionBegan(e.touches.first.client, true);
  _handleTouchMove(TouchEvent e) => interactionMoved(e.touches.first.client);
  _handleTouchEnd(TouchEvent e) => interactionEnded(e.touches.first.client);
  _handleTouchCancel(TouchEvent e) => interactionEnded(e.touches.first.client);

  // Generic Handlers

  // interactionBegan(Point p, bool touch) {
  //   if (store.paletteConfig == null) return;
  //   setState({'startPoint': p, 'currentPoint': p});
  //   if (touch) showPalette();
  //   else startTimer();
  // }

  interactionMoved(Point p) {
    if (store.currentDimmer == DimmerType.TileOptions || store.currentDimmer == DimmerType.PlotOptions) {
      if (startPoint.x == 0 && startPoint.y == 0) {
        print('Need a better way of getting startPoint for control palette!');
        setState({'currentPoint': p, 'startPoint': p});
      } else {
        setState({'currentPoint': p});
      }
    }
  }

  interactionEnded(Point p) {
    callbackSelectedOption();
    actions.hideDimmer();
  }

  callbackSelectedOption() {
    int optIndex = 0;
    List<Point> points = _getOptionPoints(config.options);
    points.forEach((point) {
      num dist = point.distanceTo(currentPoint);
      if (dist < ROUND_BUTTON_RADIUS) config.options[optIndex].callback();
      optIndex++;
    });
  }
}
