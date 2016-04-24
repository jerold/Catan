// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


const int ROUND_BUTTON_RADIUS = 32;
const int OPTION_RADIUS = 70;
const num EXTRA_RADIUS_LIMIT = 50;
const num MAX_EXTRA_RADIUS = 15;

class PaletteOption {
  final String icon;
  final Function callback;

  PaletteOption(this.icon, this.callback);

  component(Point p, String c) => react.button({
    'className': 'ui ${c} big icon circular button',
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

var ControlPalette = react.registerComponent(() => new _ControlPalette());
class _ControlPalette extends w_flux.FluxComponent<GameActions, GameStore> {
  List<StreamSubscription> _subs = new List<StreamSubscription>();

  Map<String, Function> _handlers = new Map<String, Function>();

  int get windowWidth => state['windowWidth'] ?? 1;
  Point get startPoint => state['startPoint'];
  Point get currentPoint => state['currentPoint'];
  ControlPaletteConfig get config => state['config'];

  getInitialState() => stateFromStore();

  stateFromStore() {
    Map<String, dynamic> storeState = new Map<String, dynamic>();
    if (store.currentDimmer == DimmerType.TileOptions) {
      storeState['config'] = new TileControlPaletteConfig(store.boardStore.activeTile, actions, store);
    } else if (store.currentDimmer == DimmerType.PlotOptions) {
      storeState['config'] = new PlotControlPaletteConfig(store.boardStore.activePlotKey, actions, store);
    } else if (store.currentDimmer == DimmerType.WaterOptions) {
      storeState['config'] = new WaterControlPaletteConfig(store.boardStore.activeTileKey, actions, store);
    }
    storeState['startPoint'] = store.boardStore.activatePoint;
    storeState['currentPoint'] = store.boardStore.activatePoint;
    return storeState;
  }

  setStateFromStore() => setState(stateFromStore());

  Map<w_flux.Store, Function> getStoreHandlers() => { store: (_) => setStateFromStore() };

  bool shouldComponentUpdate(_, nextState) {
    return state['windowWidth'] != windowWidth
        || state['startPoint'] != startPoint
        || nextState['currentPoint'] != currentPoint
        || nextState['config'] != config;
  }

  componentWillMount() {
    super.componentWillMount();

    _handlers['_handleKeyDown'] = _handleKeyDown;
    _handlers['_handleMouseMove'] = _handleMouseMove;
    _handlers['_handleMouseUp'] = _handleMouseUp;
    _handlers['_handleTouchMove'] = _handleTouchMove;
    _handlers['_handleTouchEnd'] = _handleTouchEnd;
    _handlers['_handleTouchCancel'] = _handleTouchCancel;

    _subs.add(document.onKeyDown.listen(_handlers['_handleKeyDown']));
    _subs.add(document.onMouseMove.listen(_handlers['_handleMouseMove']));
    _subs.add(document.onMouseUp.listen(_handlers['_handleMouseUp']));
    _subs.add(document.onTouchMove.listen(_handlers['_handleTouchMove']));
    _subs.add(document.onTouchEnd.listen(_handlers['_handleTouchEnd']));
    _subs.add(document.onTouchCancel.listen(_handlers['_handleTouchCancel']));
  }

  void componentDidMount(DivElement rootNode) {
    setState({'windowWidth': rootNode.getBoundingClientRect().width});
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
    if (options != null) {
      num arc = PI / 4;
      num totalArc = PI / 5 * (options.length - 1);
      num initialAngle = PI / 2 + totalArc * (startPoint.x / windowWidth);
      options.forEach((opt) {
        num angle = arc * optIndex - initialAngle;
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
    }
    return points;
  }

  // Specific Handlers

  // TEMP keyboard event handling until better tile config UX is in
  _handleKeyDown(KeyboardEvent e) {
    if (e.keyCode == KeyCode.ONE) actions.setActiveTileTerrain(TERRAINS[1]);
    if (e.keyCode == KeyCode.TWO) actions.setActiveTileTerrain(TERRAINS[2]);
    if (e.keyCode == KeyCode.THREE) actions.setActiveTileTerrain(TERRAINS[3]);
    if (e.keyCode == KeyCode.FOUR) actions.setActiveTileTerrain(TERRAINS[4]);
    if (e.keyCode == KeyCode.FIVE) actions.setActiveTileTerrain(TERRAINS[5]);
    if (e.keyCode == KeyCode.SIX) actions.setActiveTileTerrain(TERRAINS[0]);

    if (e.keyCode == KeyCode.TAB) actions.setActiveTileRoll(0);
    if (e.keyCode == KeyCode.Q) actions.setActiveTileRoll(2);
    if (e.keyCode == KeyCode.W) actions.setActiveTileRoll(3);
    if (e.keyCode == KeyCode.E) actions.setActiveTileRoll(4);
    if (e.keyCode == KeyCode.R) actions.setActiveTileRoll(5);
    if (e.keyCode == KeyCode.T) actions.setActiveTileRoll(6);
    if (e.keyCode == KeyCode.Y) actions.setActiveTileRoll(8);
    if (e.keyCode == KeyCode.U) actions.setActiveTileRoll(9);
    if (e.keyCode == KeyCode.I) actions.setActiveTileRoll(10);
    if (e.keyCode == KeyCode.O) actions.setActiveTileRoll(11);
    if (e.keyCode == KeyCode.P) actions.setActiveTileRoll(12);
  }

  _handleMouseMove(MouseEvent e) => interactionMoved(e.client);
  _handleMouseUp(_) => interactionEnded();

  _handleTouchMove(TouchEvent e) {
    e.preventDefault();
    interactionMoved(e.touches.first.client);
  }
  _handleTouchEnd(_) => interactionEnded();
  _handleTouchCancel(_) => interactionEnded();

  // Generic Handlers

  interactionMoved(Point p) {
    if (store.currentDimmer == DimmerType.TileOptions
        || store.currentDimmer == DimmerType.PlotOptions
        || store.currentDimmer == DimmerType.WaterOptions) {
      setState({'currentPoint': p});
    }
  }

  interactionEnded() {
    actions.hideDimmer();
    callbackSelectedOption();
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
