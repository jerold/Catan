// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


const num COORD_SPACING = 36;
const Point DEFAULT_CENTER = const Point(0, 0);


class GameComponents extends w_module.ModuleComponents {
  GameActions _actions;
  GameStore _store;
  GameComponents(this._actions, this._store);

  content() => HelperComponent({'actions': _actions, 'store': _store});

  newGameDimmer() => NewGameDimmer({'actions': _actions, 'store': _store});

  controlPaletteDimmer() => PieChart({'data': [10.0, 20.0, 30.0], 'strokes': ['rgb(50,50,50)', 'rgb(100,100,100)', 'rgb(150,150,150)']});
}

Point scaledPoint(Coordinate coord, Rectangle view) => new Point(
  (coord.point.x) * COORD_SPACING,
  (coord.point.y) * COORD_SPACING);

List<Point> pipPoints({Point center: DEFAULT_CENTER, num radius: COORD_SPACING, int count: 1}) {
  List<Point> points = new List<Point>();
  num arc = (PI / 2) / 3;
  num totalArc = arc * (count - 1);
  num centerArcOffset = (PI - totalArc) / 2;
  for (int i = 0; i < count; i++) {
    points.add(new Point(
      center.x + cos((i * arc + centerArcOffset)) * radius,
      center.y + (radius / 4) + (sin((i * arc + centerArcOffset)) * radius) * 2 / 3
    ));
  }
  return points;
}

List<Point> ringOfPoints({Point center: DEFAULT_CENTER, num radius: COORD_SPACING, int count: 3}) {
  List<Point> points = new List<Point>();
  num arc = 2 * PI / count;
  for(int i = 0; i < count; i++) {
    points.add(new Point(
      center.x + cos((i * arc)) * radius,
      center.y + sin((i * arc)) * radius
    ));
  }
  return points;
}

final num tileOpacity = 0.6;
final num expOpacity = 0.4;
final String waterColor = 'rgba(38, 169, 224, 0.2)';
final String activeColor = 'rgba(0, 0, 0, .4)';

String tileTypeToColor(TileType type) {
  switch(type) {
    case TileType.Desert:
      return '#f9da6c';
    case TileType.Pasture:
      return '#9ebc2e';
    case TileType.Field:
      return '#f4a54b';
    case TileType.Forest:
      return '#008042';
    case TileType.Hill:
      return '#be6447';
    case TileType.Mountain:
      return '#606060';
  }
}

var HelperComponent = react.registerComponent(() => new _HelperComponent());
class _HelperComponent extends w_flux.FluxComponent<GameActions, GameStore> {
  render() {
    return react.div({'className': 'content'}, [
      MainMenu({'actions': actions, 'store': store}),
      store.gameState == EditingState ? Editing({'actions': actions, 'store': store}) : null,
      // NewGameDimmer({'actions': actions, 'store': store}),
    ]);
  }
}
