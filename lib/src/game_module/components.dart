// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

const num spacing = 20;
num get xSpace => spacing;
num get ySpace => Math.sin(Math.PI * (1 / 3)) * spacing;
final Math.Point offset = new Math.Point(-30 * xSpace, -30 * ySpace);

Math.Point coordToPoint(Coordinate coord) => new Math.Point(coord.x * xSpace + ((xSpace / 2) * (coord.y % 2)) + offset.x, coord.y * ySpace + offset.y);

const Math.Point DEFAULT_CENTER = const Math.Point(0, 0);
List<Math.Point> ringOfPoints({Math.Point center: DEFAULT_CENTER, num radius: spacing, int count: 3}) {
  List<Math.Point> points = new List<Math.Point>();
  num arc = 2 * Math.PI / count;
  for(int i = 0; i < count; i++) {
    points.add(new Math.Point(
      center.x + Math.cos((i * arc)) * radius,
      center.y + Math.sin((i * arc)) * radius
    ));
  }
  return points;
}

final num tileOpacity = 0.4;
final num expOpacity = 0.4;
final String waterColor = 'rgba(15, 117, 188, ${expOpacity})';
final String activeColor = 'rgba(0, 0, 0, .4)';

String terrainTypeToColor(TerrainType type) {
  switch(type) {
    case TerrainType.Desert:
      return 'rgba(246, 220, 107, ${tileOpacity})';
    case TerrainType.Pasture:
      return 'rgba(158, 189, 46, ${tileOpacity})';
    case TerrainType.Field:
      return 'rgba(246, 167, 75, ${tileOpacity})';
    case TerrainType.Forest:
      return 'rgba(10, 128, 65, ${tileOpacity})';
    case TerrainType.Hill:
      return 'rgba(134, 44, 18, ${tileOpacity})';
    case TerrainType.Mountain:
      return 'rgba(151, 148, 136, ${tileOpacity})';
  }
}
String utilityGradientColor(int val, int average, int max) {
  num delta = (val - average) / (max - average);
  num opacity = val > average ? .4 : .1;
  return 'rgba(${(255 - (255 * delta)).toInt()}, ${(255 * delta).toInt()}, 0, ${opacity})';
}

class GameComponents extends ModuleComponents {
  GameActions _actions;
  GameStore _store;
  GameComponents(this._actions, this._store);

  content() => BoardComponent({'actions': _actions, 'store': _store});
}

var ResourceComponent = React.registerComponent(() => new _ResourceComponent());
class _ResourceComponent extends FluxComponent<GameActions, GameStore> {
  ResourceType get type => props['type'];
  num get chance => props['chance'];

  render() {
    List<Terrain> tiles = store.tilesWithResource(type);
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

var GameOverlayComponent = React.registerComponent(() => new _GameOverlayComponent());
class _GameOverlayComponent extends FluxComponent<GameActions, GameStore> {
  render() {

    List stateChangeButtons = new List();
    [BoardSetupState, PlayerSetupState, PlayingState].forEach((state) {
      stateChangeButtons.add(React.button({
        'disabled': store.gameState == state,
        'onClick': (_) => _handleStateChangeButtonClick(state),
      }, state));
    });
    var stateButtonGroup = React.div({}, stateChangeButtons);

    var resources = ResourcesComponent({'actions': actions, 'store': store});

    return React.div({
      'style': {
        'position': 'absolute',
        'paddingLeft': '10',
        'fontSize': 18,
        'fontFamily': '"Century Gothic", CenturyGothic, AppleGothic, sans-serif',
        'color': 'darkGray',
      }
    }, [
      stateButtonGroup,
      resources
    ]);
  }

  _handleStateChangeButtonClick(String stateString) {
    actions.changeState(stateString);
  }
}

var TileOverlayComponent = React.registerComponent(() => new _TileOverlayComponent());
class _TileOverlayComponent extends FluxComponent<GameActions, GameStore> {
  render() {
    Math.Point center = coordToPoint(store.activeTerrain.coordinate);
    List circles = new List();

    // Background
    circles.add(React.circle({
      'cx': center.x,
      'cy': center.y,
      'r': spacing * 4,
      'fill': 'white',
      'stroke': 'darkGray',
      'strokeWidth': 2,
      'style': {
        'opacity': '.95',
      }
    }));

    // TerrainType
    List<TerrainType> types = new List<TerrainType>.from(TerrainType.values);
    List<Math.Point> typePoints = ringOfPoints(center: center, radius: spacing * 1.5, count: types.length);
    for (int i = 0; i < types.length; i++) {
      circles.add(RoundGameButton({
        'fill': terrainTypeToColor(types[i]),
        'radius': spacing / 1.5,
        'center': typePoints[i],
        'selected': true,
        'onMouseUp': (_) => _terrainTypeMouseUp(types[i]),
      }));
    }

    // Token
    List<int> tokens = [2, 3, 4, 5, 6, 8, 9, 10, 11, 12];
    List<Math.Point> tokenPoints = ringOfPoints(center: center, radius: spacing * 3, count: tokens.length);
    for (int i = 0; i < tokens.length; i++) {
      circles.add(RoundGameButton({
        'text': tokens[i].toString(),
        'pipCount': chances(tokens[i]),
        'fill': 'rgba(200, 200, 200, .3)',
        'radius': spacing / 1.5,
        'center': tokenPoints[i],
        'selected': true,
        'onMouseUp': (_) => _tokenMouseUp(tokens[i]),
      }));
    }

    return React.g({}, circles);
  }

  _terrainTypeMouseUp(TerrainType type) {
    actions.changeActiveTileTerrainType(type);
  }

  _tokenMouseUp(int token) {
    actions.changeActiveTileToken(token);
  }
}

const OVERLAY_TIMEOUT = const Duration(milliseconds: 100);
var BoardComponent = React.registerComponent(() => new _BoardComponent());
class _BoardComponent extends FluxComponent<GameActions, GameStore> {
  Async.Timer tileOverlayTimer;

  Async.StreamSubscription sub;

  void componentWillMount() {
    sub = Html.document.onMouseUp.listen(_hideOverlay);

    super.componentWillMount();
  }

  void componentWillUnmount() {
    sub.cancel();

    super.componentWillMount();
  }

  render() {
    List children = new List();
    // Tiles
    store.gameBoard.map.values.forEach((terrain) {
      String text = terrain.type != TerrainType.Desert ? terrain.token.toString() : '';
      children.add(RoundGameButton({
        'text': text,
        'pipCount': chances(terrain.token),
        'fill': terrainTypeToColor(terrain.type),
        'radius': spacing / 1.5,
        'center': coordToPoint(terrain.coordinate),
        'selected': store.activeTerrain == terrain,
        'onClick': (e) => _tileClicked(e, terrain),
        'onMouseDown': (_) => _tileMouseDown(terrain),
        'onMouseMove': null,
        'onMouseUp': null,
      }));
    });

    // Expansions
    if (store.gameState == BoardSetupState) {
      store.gameBoard.expansionTiles().forEach((coordKey) {
        Coordinate expCoord = new Coordinate.fromKey(coordKey);
        children.add(RoundGameButton({
          'pipCount': 0,
          'fill': waterColor,
          'radius': spacing / 2,
          'center': coordToPoint(expCoord),
          'selected': false,
          'onClick': (e) => _expansionClicked(e, expCoord),
          'onMouseDown': null,
          'onMouseMove': null,
          'onMouseUp': null,
        }));
      });
    }

    // Plots
    store.gameBoard.openPlots().forEach((coordKey) {
      Coordinate plotCoord = new Coordinate.fromKey(coordKey);
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
      'viewBox': '0 0 ${20 * xSpace} ${20 * ySpace}',
      'style': {
        // 'transform': 'scale(3.0)',
        'outline': '1px solid rgba(200, 200, 200, .75)',
      }
    }, children);

    var gameOverlay = GameOverlayComponent({
      'actions': actions,
      'store': store,
    });

    return React.div({
      'style': {
        'position': 'absolute',
        'top': '0',
        'left': '0',
        'width': '100%',
        'height': '100%',
        'overflow': 'hidden',
        'outline': '1px solid rgba(200, 200, 200, .75)',

        'WebkitTouchCallout': 'none',
        'WebkitUserSelect': 'none',
        'KhtmlUserSelect': 'none',
        'MozUserSelect': 'none',
        'MsUserSelect': 'none',
        'userSelect': 'none',
      }
    }, [gameOverlay, boardSvg]);
  }

  void _tileClicked(React.SyntheticMouseEvent e, Terrain tile) {
    if (store.gameState == BoardSetupState && e.shiftKey) actions.removeTile(tile.coordinate);
  }

  void _tileMouseDown(Terrain tile) {
    actions.changeActiveTile(tile);
    if (store.gameState == BoardSetupState) _startOverlayTimer();
  }

  void _expansionClicked(React.SyntheticMouseEvent e, Coordinate coord) {
    actions.addTile(coord);
  }

  void _startOverlayTimer() {
    if (tileOverlayTimer != null) tileOverlayTimer.cancel();
    tileOverlayTimer = new Async.Timer(OVERLAY_TIMEOUT, _showOverlay);
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
  Terrain get building => props['building'];

  render() {
    int utility = store.plotUtility(coord);
    List<int> allUtilities = new List<int>.from(store.plotUtilities().values);
    int maxUtility = allUtilities.fold(utility, (val, util) => util > val ? util : val);
    int sumUtility = allUtilities.fold(utility, (val, util) => val + util);
    int avgUtility = sumUtility ~/ allUtilities.length;

    Math.Point loc = coordToPoint(coord);
    num radius = spacing / 6;
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

typedef void ComponentCallback(React.SyntheticMouseEvent e);
var RoundGameButton = React.registerComponent(() => new _RoundGameButton());
class _RoundGameButton extends React.Component {
  String get text => props['text'] ?? '';
  int get pipCount => props['pipCount'] ?? 0;
  String get fill => props['fill'] ?? 'darkGray';
  num get radius => props['radius'] ?? spacing / 1.5;
  Math.Point get center => props['center'] ?? new Math.Point(0, 0);
  bool get selected => props['selected'] ?? false;

  ComponentCallback get onClickCallback => props['onClick'];
  ComponentCallback get onMouseDownCallback => props['onMouseDown'];
  ComponentCallback get onMouseMoveCallback => props['onMouseMove'];
  ComponentCallback get onMouseUpCallback => props['onMouseUp'];

  render() {
    String stroke = selected ? activeColor : 'none';
    int strokeWidth = selected ? 2 : 0;

    List children = new List();
    children.add(React.circle({
      'cx': center.x,
      'cy': center.y,
      'r': radius,
      'fill': fill,
      'stroke': stroke,
      'strokeWidth': strokeWidth,
      'onClick': onClickCallback,
      'onMouseDown': onMouseDownCallback,
      'onMouseMove': onMouseMoveCallback,
      'onMouseUp': onMouseUpCallback,
    }));

    List<Math.Point> pipPoints = ringOfPoints(center: center, radius: radius * 2 / 3, count: pipCount);
    pipPoints.forEach((point) {
      children.add(React.circle({
        'cx': point.x,
        'cy': point.y,
        'r': 2,
        'fill': activeColor,
      }));
    });

    children.add(React.text({
      'textAnchor': 'middle',
      'x': center.x,
      'y': center.y,
      'dy': '.3em',
      'fill': activeColor,
      'style': {
        'pointerEvents': 'none',
        'fontSize': 8,
        'fontWeight': 'bold',
        'fontFamily': '"Century Gothic", CenturyGothic, AppleGothic, sans-serif',
      }
    }, text));
    return React.g({}, children);
  }
}
