part of catan.game_module;

const num PLOT_RADIUS = COORD_SPACING * 1 / 3;

String utilityGradient(num val, num average, num max) {
  num delta = max - average != 0 ? (val - average) / (max - average) : 0;
  return 'rgb(100, ${(255 * delta).toInt()}, ${(255 - (255 * delta)).toInt()})';
}

var PlotGroup = react.registerComponent(() => new _PlotGroup());

class _PlotGroup extends w_flux.FluxComponent<GameActions, GameStore> {
  Board get board => store.board;

  @override
  List<w_flux.Store> redrawOn() {
    if (store is GameStore)
      return [store.board];
    else
      return [];
  }

  render() {
    Statistic utilityStats = board.plotUtilityStats();
    num utilityRange = utilityStats.getMax() - utilityStats.getMin();

    List children = new List();
    board.openPlots().forEach((key) {
      Coordinate coord = Coordinate.fromKey(key);
      int utility = board.utilityOfPlot(key);
      Point center = scaledPoint(coord);

      children.add(react.circle({
        'cx': center.x,
        'cy': center.y,
        'r': PLOT_RADIUS,
        'fill': 'white',
        'stroke': 'rgba(0, 0, 0, 0.1)',
        'strokeWidth': '1',
        'onMouseDown': (react.SyntheticMouseEvent e) =>
            _handleMouseDown(e, key),
        'onTouchStart': (react.SyntheticTouchEvent e) =>
            _handleTouchStart(e, key),
      }));

      num opacity = utilityRange > 0
          ? (utility - utilityStats.getMin()) / utilityRange
          : 0.0;
      List<Point> hexPoints = ringOfPoints(
          center: center, radius: (PLOT_RADIUS * 2 / 3) * opacity, count: 6);
      children.add(react.polygon({
        'points':
            new List<String>.from(hexPoints.map((hex) => '${hex.x},${hex.y}'))
                .join(' '),
        'fill': utilityGradient(
            utility, utilityStats.getAvg(), utilityStats.getMax()),
        'opacity': opacity,
        'stroke': activeColor,
        'strokeWidth': utility == utilityStats.getMax() ? '3' : '0',
        'style': {'pointerEvents': 'none'},
      }));
    });

    return react.g({}, children);
  }

  _handleMouseDown(react.SyntheticMouseEvent e, int key) {
    Point client = new Point(e.clientX, e.clientY);
    interactionBegan(e.shiftKey, client, key);
  }

  _handleTouchStart(react.SyntheticTouchEvent e, int key) {
    e.preventDefault();
    // React dart does not fully convert the touches JsObject to a List<Touch>...
    Point client = new Point(e.touches[0]['clientX'], e.touches[0]['clientY']);
    interactionBegan(e.shiftKey, client, key);
  }

  interactionBegan(bool shiftKey, Point client, int key) {
    board.actions.setActiveKey(key);
    actions.setInteractionPoint(client);
    actions.showDimmer(DimmerType.PlotOptions);
  }
}
