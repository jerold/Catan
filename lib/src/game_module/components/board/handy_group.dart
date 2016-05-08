// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


var HandyGroup = react.registerComponent(() => new _HandyGroup());
class _HandyGroup extends w_flux.FluxComponent<GameActions, GameStore> {
  Board get board => store.board;

  @override
  List<w_flux.Store> redrawOn() {
    if (store is GameStore) return [store.board];
    else return [];
  }

  render() {
    List children = new List();
    if (board.activePlayer != null && store.gameState == GameState.Playing) {
      board.handyEdges(board.activePlayer).forEach((eKey) {
        Edge edge = Edge.fromKey(eKey);
        List<Coordinate> ends = edge.ends();
        Point c0 = scaledPoint(ends[0]);
        Point c1 = scaledPoint(ends[1]);

        children.add(react.circle({
          'cx': (c0.x + c1.x) / 2,
          'cy': (c0.y + c1.y) / 2,
          'r': COORD_SPACING / 5,
          'fill': 'white',
          'stroke': 'white',
          'strokeWidth': 2,
          'onMouseDown': (react.SyntheticMouseEvent e) => _handleMouseDown(e, eKey),
          'onTouchStart': (react.SyntheticTouchEvent e) => _handleTouchStart(e, eKey),
        }));

        // children.add(react.line({
        //   'x1': c0.x,
        //   'y1': c0.y,
        //   'x2': c1.x,
        //   'y2': c1.y,
        //   'fill': 'white',
        //   'stroke': 'white',
        //   'strokeLinecap': 'round',
        //   'strokeWidth': COORD_SPACING / 5 * 2,
        //   'pointerEvents': 'none',
        // }));
      });

      board.handyPlots(board.activePlayer).forEach((pKey) {
        Coordinate coord = Coordinate.fromKey(pKey);
        Point center = scaledPoint(coord);
        children.add(react.circle({
          'cx': center.x,
          'cy': center.y,
          'r': COORD_SPACING / 5,
          'fill': 'white',
          'stroke': 'white',
          'strokeWidth': 2,
          'pointerEvents': 'none',
          'onMouseDown': (react.SyntheticMouseEvent e) => _handleMouseDown(e, pKey),
          'onTouchStart': (react.SyntheticTouchEvent e) => _handleTouchStart(e, pKey),
        }));
      });
    }

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
    if (Coordinate.validKey(key)) actions.showDimmer(DimmerType.PlotOptions);
    if (Edge.validKey(key)) actions.showDimmer(DimmerType.EdgeOptions);
  }
}
