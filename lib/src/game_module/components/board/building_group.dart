part of catan.game_module;

var BuildingGroup = react.registerComponent(() => new _BuildingGroup());

class _BuildingGroup extends w_flux.FluxComponent<GameActions, GameStore> {
  Board get board => store.board;

  @override
  List<w_flux.Store> redrawOn() {
    if (store is GameStore)
      return [store.board];
    else
      return [];
  }

  render() {
    List children = new List();

    board.edges.forEach((eKey, edge) {
      if (edge is Road) {
        // Edge edge = Edge.fromKey(eKey);
        List<Coordinate> ends = edge.edge.ends();
        Point c0 = scaledPoint(ends[0]);
        Point c1 = scaledPoint(ends[1]);

        children.add(react.line({
          'x1': (c0.x * .4 + c1.x * .6),
          'y1': (c0.y * .4 + c1.y * .6),
          'x2': (c0.x * .6 + c1.x * .4),
          'y2': (c0.y * .6 + c1.y * .4),
          'stroke': 'white',
          'strokeLinecap': 'round',
          'strokeWidth': COORD_SPACING / 5,
          'pointerEvents': 'none',
        }));

        children.add(react.line({
          'x1': (c0.x * .4 + c1.x * .6),
          'y1': (c0.y * .4 + c1.y * .6),
          'x2': (c0.x * .6 + c1.x * .4),
          'y2': (c0.y * .6 + c1.y * .4),
          'stroke': edge.owner.color,
          'strokeLinecap': 'round',
          'strokeWidth': COORD_SPACING / 5 - 4,
          'pointerEvents': 'none',
        }));
      }
    });

    board.plots.forEach((pKey, plot) {
      if (plot is Building) {
        Building building = plot as Building;
        Coordinate coord = Coordinate.fromKey(building.key);
        Point center = scaledPoint(coord);
        if (building.production > 1) {
          children.add(react.circle({
            'cx': center.x,
            'cy': center.y,
            'r': COORD_SPACING / 3,
            'fill': building.owner.color,
            'stroke': 'white',
            'strokeWidth': 2,
            'pointerEvents': 'none',
          }));
        }
        if (building.production > 0) {
          children.add(react.circle({
            'cx': center.x,
            'cy': center.y,
            'r': COORD_SPACING / 5,
            'fill': building.owner.color,
            'stroke': 'white',
            'strokeWidth': 2,
            'pointerEvents': 'none',
          }));
        }
      }
    });
    return react.g({}, children);
  }
}
