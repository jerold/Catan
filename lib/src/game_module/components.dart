// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

class GameComponents extends ModuleComponents {
  GameActions _actions;
  GameStore _store;
  GameComponents(this._actions, this._store);

  content() => BoardComponent({'actions': _actions, 'store': _store});
}

const num distance_between_coords = 36;

Point scaledPoint(Coordinate coord, Rectangle view) => new Point(
  (coord.point.x) * distance_between_coords,
  (coord.point.y) * distance_between_coords);

const Point DEFAULT_CENTER = const Point(0, 0);
List<Point> ringOfPoints({Point center: DEFAULT_CENTER, num radius: distance_between_coords, int count: 3}) {
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

final num tileOpacity = 0.4;
final num expOpacity = 0.4;
final String waterColor = 'rgba(15, 117, 188, ${expOpacity})';
final String activeColor = 'rgba(0, 0, 0, .4)';

String tileTypeToColor(TileType type) {
  switch(type) {
    case TileType.Desert:
      return 'rgba(246, 220, 107, ${tileOpacity})';
    case TileType.Pasture:
      return 'rgba(158, 189, 46, ${tileOpacity})';
    case TileType.Field:
      return 'rgba(246, 167, 75, ${tileOpacity})';
    case TileType.Forest:
      return 'rgba(10, 128, 65, ${tileOpacity})';
    case TileType.Hill:
      return 'rgba(134, 44, 18, ${tileOpacity})';
    case TileType.Mountain:
      return 'rgba(151, 148, 136, ${tileOpacity})';
  }
}

String utilityGradientColor(int val, int average, int max) {
  num delta = max - average != 0 ? (val - average) / (max - average) : 0;
  num opacity = val > average ? .4 : .1;
  return 'rgba(${(255 - (255 * delta)).toInt()}, ${(255 * delta).toInt()}, 0, ${opacity})';
}


var ResourceComponent = React.registerComponent(() => new _ResourceComponent());
class _ResourceComponent extends FluxComponent<GameActions, GameStore> {
  ResourceType get type => props['type'];
  num get chance => props['chance'];

  render() {
    List<Tile> tiles = store.tilesWithResource(type);
    List tileSpans = new List()..add('${chance.toString().padLeft(2, "0")} ${stringFromResourceType(type)}: ');
    tiles.forEach((tile) {
      tileSpans.add(React.span({
        'onClick': (_) => actions.changeActiveTile(tile)
      }, '[${chances(tile.token)}] '));
    });
    return React.div({}, tileSpans);
  }
}

var ResourcesComponent = React.registerComponent(() => new _ResourcesComponent());
class _ResourcesComponent extends FluxComponent<GameActions, GameStore> {
  render() {
    List resourceGroup = new List();
    Map<ResourceType, int> chanceMap = store.resourceChances();
    chanceMap.forEach((type, chance) {
      if (type != ResourceType.None) {
        resourceGroup.add(ResourceComponent({'actions': actions, 'store': store, 'type': type, 'chance': chance}));
      }
    });
    return React.div({}, resourceGroup);
  }
}

var TileOverlayComponent = React.registerComponent(() => new _TileOverlayComponent());
class _TileOverlayComponent extends FluxComponent<GameActions, GameStore> {
  render() {
    Point center = scaledPoint(store.activeTile.coordinate, store.viewport);
    List circles = new List();

    // Background
    circles.add(React.circle({
      'cx': center.x,
      'cy': center.y,
      'r': distance_between_coords * 4,
      'fill': 'white',
      'stroke': 'darkGray',
      'strokeWidth': 2,
      'style': {
        'opacity': '.95',
      }
    }));

    // TileTypes
    List<TileType> types = new List<TileType>.from(TileType.values);
    List<Point> typePoints = ringOfPoints(center: center, radius: distance_between_coords * 1.5, count: types.length);
    for (int i = 0; i < types.length; i++) {
      circles.add(RoundGameButton({
        'fill': tileTypeToColor(types[i]),
        'radius': distance_between_coords / 1.5,
        'center': typePoints[i],
        'selected': true,
        'onMouseUp': (_) => _tileTypeMouseUp(types[i]),
      }));
    }

    // Tokens
    List<int> tokens = [2, 3, 4, 5, 6, 8, 9, 10, 11, 12];
    List<Point> tokenPoints = ringOfPoints(center: center, radius: distance_between_coords * 3, count: tokens.length);
    for (int i = 0; i < tokens.length; i++) {
      circles.add(RoundGameButton({
        'text': tokens[i].toString(),
        'pipCount': chances(tokens[i]),
        'fill': 'rgba(200, 200, 200, .3)',
        'radius': distance_between_coords / 1.5,
        'center': tokenPoints[i],
        'selected': true,
        'onMouseUp': (_) => _tokenMouseUp(tokens[i]),
      }));
    }

    return React.g({}, circles);
  }

  _tileTypeMouseUp(TileType type) {
    actions.changeActiveTileType(type);
  }

  _tokenMouseUp(int token) {
    actions.changeActiveTileToken(token);
  }
}

const OVERLAY_TIMEOUT = const Duration(milliseconds: 100);
var BoardComponent = React.registerComponent(() => new _BoardComponent());
class _BoardComponent extends FluxComponent<GameActions, GameStore> {
  Timer tileOverlayTimer;

  StreamSubscription sub;

  void componentWillMount() {
    sub = document.onMouseUp.listen(_hideOverlay);

    super.componentWillMount();
  }

  void componentWillUnmount() {
    sub.cancel();

    super.componentWillMount();
  }

  render() {
    List children = new List();
    // Tiles
    store.gameBoard.map.values.forEach((tile) {
      String text = tile.type != TileType.Desert ? tile.token.toString() : '';
      children.add(RoundGameButton({
        'text': text,
        'pipCount': chances(tile.token),
        'fill': tileTypeToColor(tile.type),
        'radius': distance_between_coords / 1.5,
        'center': scaledPoint(tile.coordinate, store.viewport),
        'selected': store.activeTile == tile,
        'onClick': (e) => _tileClicked(e, tile),
        'onMouseDown': (e) => _tileMouseDown(e, tile),
        'onMouseMove': null,
        'onMouseUp': null,
      }));
    });

    // Expansions
    if (store.gameState == BoardSetupState) {
      store.gameBoard.expansionTiles().forEach((coordKey) {
        Coordinate expCoord = Coordinate.fromKey(coordKey);
        children.add(RoundGameButton({
          'pipCount': 0,
          'fill': waterColor,
          'radius': distance_between_coords / 2,
          'center': scaledPoint(expCoord, store.viewport),
          'selected': false,
          'onClick': (e) => _expansionClicked(e, coordKey),
          'onMouseDown': null,
          'onMouseMove': null,
          'onMouseUp': null,
        }));
      });
    }

    // Plots
    store.gameBoard.openPlots().forEach((coordKey) {
      Coordinate plotCoord = Coordinate.fromKey(coordKey);
      children.add(PlotComponent({
        'actions': actions,
        'store': store,
        'coord': plotCoord,
      }));
    });

    // Tile Overlay
    if (store.showTileOverlay) {
      children.add(TileOverlayComponent({
        'actions': actions,
        'store': store,
      }));
    }

    var boardSvg = React.svg({
      'version': '1.1',
      'xmlns': 'http://www.w3.org/2000/svg',
      'width': '100%',
      'height': '100%',
      'viewBox': '0 0 ${20 * distance_between_coords} ${20 * distance_between_coords}',
      'style': {
        // 'transform': 'scale(3.0)',
        'outline': '1px solid rgba(200, 200, 200, .75)',
      }
    }, children);

    var chartDiv = React.div({
      'style': {
        'position': 'absolute',
        'top': '200px',
        'left': '100px',
        'width': '50px',
        'height': '50px',
      }
    }, PieChart({
      'callback': _pieChartPressed,
      'center': new Point(40, 40),
      'radius': 20,
      'data': [38, 20, 10],
      'strokes': ['rgba(200, 50, 50, .5)', 'rgba(50, 200, 50, .5)', 'rgba(50, 50, 200, .5)'],
    }));

    return React.div({'className': 'content'}, [
      MainMenu({'actions': actions, 'store': store}),
      store.gameState == EditingState ? Editing({'actions': actions, 'store': store}) : null,
      // NewGameModal({'actions': actions, 'store': store}),
    ]);

    // return React.div({
    //   'style': {
    //     'position': 'absolute',
    //     'top': '0',
    //     'left': '0',
    //     'width': '100%',
    //     'height': '100%',
    //     'overflow': 'hidden',
    //     'outline': '1px solid rgba(200, 200, 200, .75)',
    //
    //     'WebkitTouchCallout': 'none',
    //     'WebkitUserSelect': 'none',
    //     'KhtmlUserSelect': 'none',
    //     'MozUserSelect': 'none',
    //     'MsUserSelect': 'none',
    //     'userSelect': 'none',
    //   }
    // }, [gameOverlay, boardSvg, chartDiv]);
  }

  void _pieChartPressed(int index) {
    print(index);
  }

  void _tileClicked(React.SyntheticMouseEvent e, Tile tile) {
    if (store.gameState == BoardSetupState && e.shiftKey) actions.removeTile(tile.key);
  }

  void _tileMouseDown(React.SyntheticMouseEvent e, Tile tile) {
    actions.changeActiveTile(tile);
    if (store.gameState == BoardSetupState && !e.shiftKey) _startOverlayTimer();
  }

  void _expansionClicked(React.SyntheticMouseEvent e, int key) {
    actions.addTile(key);
  }

  void _startOverlayTimer() {
    if (tileOverlayTimer != null) tileOverlayTimer.cancel();
    tileOverlayTimer = new Timer(OVERLAY_TIMEOUT, _showOverlay);
  }

  void _showOverlay() {
    if (store.gameState == BoardSetupState) {
      actions.setShowTileOverlay(true);
    }
  }

  void _hideOverlay(_) {
    if (tileOverlayTimer != null) tileOverlayTimer.cancel();
    tileOverlayTimer = null;

    if (store.gameState == BoardSetupState) {
      actions.setShowTileOverlay(false);
    }
  }
}

var PlotComponent = React.registerComponent(() => new _PlotComponent());
class _PlotComponent extends FluxComponent<GameActions, GameStore> {
  Coordinate get coord => props['coord'];

  render() {
    int utility = store.plotUtility(coord);
    List<int> allUtilities = new List<int>.from(store.plotUtilities().values);
    int maxUtility = allUtilities.fold(utility, (val, util) => util > val ? util : val);
    int sumUtility = allUtilities.fold(0, (val, util) => val + util);
    int avgUtility = sumUtility ~/ allUtilities.length;

    Point loc = scaledPoint(coord, store.viewport);
    num radius = distance_between_coords / 6;
    String color = utilityGradientColor(utility, avgUtility, maxUtility);
    String stroke = 'darkGray';
    int strokeWidth = utility == maxUtility ? 1 : 0;

    return React.circle({
      'cx': loc.x,
      'cy': loc.y,
      'r': utility > avgUtility ? radius : radius / 2,
      'fill': color,
      'stroke': stroke,
      'strokeWidth': strokeWidth,
      'onClick': _handleClick,
    });
  }

  _handleClick(React.SyntheticMouseEvent e) {
    int utility = store.plotUtility(coord);
    List<int> allUtilities = store.plotUtilities().values;
    int maxUtility = allUtilities.fold(utility, (val, util) => util > val ? util : val);
    int minUtility = allUtilities.fold(utility, (val, util) => util < val ? util : val);
    int sumUtility = allUtilities.fold(utility, (val, util) => val + util);
    int avgUtility = sumUtility ~/ allUtilities.length;
    print('Utility:${utility}, min(${minUtility}), max(${maxUtility}), avg:(${avgUtility})');
    print(utilityGradientColor(utility, avgUtility, maxUtility));
  }
}
