// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

final num spacing = 20;
num get xSpace => spacing;
num get ySpace => Math.sin(Math.PI * (1 / 3)) * spacing;
final Math.Point offset = new Math.Point(-30 * xSpace, -30 * ySpace);

Math.Point coordToPoint(Coordinate coord) => new Math.Point(coord.x * xSpace + ((xSpace / 2) * (coord.y % 2)) + offset.x, coord.y * ySpace + offset.y);

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

class GameComponents extends ModuleComponents {
  GameActions _actions;
  GameStore _store;
  GameComponents(this._actions, this._store);

  content() => BoardComponent({'actions': _actions, 'store': _store});
}


var OverlayComponent = React.registerComponent(() => new _OverlayComponent());

class _OverlayComponent extends FluxComponent<GameActions, GameStore> {
  render() {

    List stateChangeButtons = new List();
    [BoardSetupState, FrequencySetupState, PlayerSetupState, PlayingState].forEach((state) {
      stateChangeButtons.add(React.button({
        'disabled': store.gameState == state,
        'onClick': (_) => _handleStateChangeButtonClick(state),
      }, state));
    });
    var stateButtonGroup = React.div({}, stateChangeButtons);

    List harvestButtons = new List();
    if (store.activeTerrain != null) {
      for(int i = 2; i < 13; i++) {
        harvestButtons.add(React.button({
          'disabled': store.activeTerrain.harvest == i,
          'onClick': (_) => _handleHarvestChangeButtonClick(i),
        }, '${i}'));
      }
    }
    var harvestButtonGroup = React.div({}, harvestButtons);

    return React.div({
      'style': {
        'position': 'absolute',
        'paddingLeft': '10',
        'fontSize': 24,
        'fontFamily': '"Century Gothic", CenturyGothic, AppleGothic, sans-serif',
        'color': 'darkGray',
      }
    }, [
      stateButtonGroup,
      harvestButtonGroup,
    ]);
  }

  _handleStateChangeButtonClick(String stateString) {
    actions.changeState(stateString);
  }

  _handleHarvestChangeButtonClick(int newHarvest) {
    actions.changeActiveTileHarvest(newHarvest);
  }
}


var BoardComponent = React.registerComponent(() => new _BoardComponent());

class _BoardComponent extends FluxComponent<GameActions, GameStore> {
  render() {
    List children = new List();
    store.gameBoard.map.values.forEach((terrain) {
      children.add(TileComponent({
        'actions': actions,
        'store': store,
        'coord': terrain.coordinate,
        'terrain': terrain
      }));
    });
    if (store.gameState == BoardSetupState) {
      store.gameBoard.expansionTiles().forEach((coordKey) {
        Coordinate expCoord = new Coordinate.fromKey(coordKey);
        children.add(TileComponent({
          'actions': actions,
          'store': store,
          'coord': expCoord,
        }));
      });
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
    var overlay = OverlayComponent({
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
    }, [overlay, boardSvg]);
  }
}


var TileComponent = React.registerComponent(() => new _TileComponent());

class _TileComponent extends FluxComponent<GameActions, GameStore> {
  Coordinate get coord => props['coord'];
  Terrain get terrain => props['terrain'];

  render() {
    Math.Point loc = coordToPoint(coord);
    num radius = terrain != null ? spacing / 1.5 : spacing / 2;
    String color = terrain != null ? terrainTypeToColor(terrain.type) : waterColor;
    String stroke = terrain != null && store.activeTerrain == terrain ? activeColor : color;
    int strokeWidth = terrain == null || store.activeTerrain == terrain ? 2 : 0;

    List circles = new List();
    circles.add(React.circle({
      'cx': loc.x,
      'cy': loc.y,
      'r': radius,
      'fill': color,
      'stroke': stroke,
      'strokeWidth': strokeWidth,
      'onClick': _handleClick,
    }));

    if (terrain != null) {
      num arc = 2 * Math.PI / terrain.harvest;
      for(int i = 0; i < terrain.harvest; i++) {
        circles.add(React.circle({
          'cx': loc.x + Math.cos((i * arc)) * (radius * 2 / 3),
          'cy': loc.y + Math.sin((i * arc)) * (radius * 2 / 3),
          'r': 2,
          'fill': activeColor,
        }));
      }
    }

    return React.g({}, circles);

    // return React.circle({
    //   'cx': loc.x,
    //   'cy': loc.y,
    //   'r': radius,
    //   'fill': color,
    //   'stroke': stroke,
    //   'strokeWidth': strokeWidth,
    //   'onClick': _handleClick,
    // });
  }

  _handleClick(React.SyntheticMouseEvent e) {
    switch(store.gameState) {
      case BoardSetupState:
        if (terrain != null && e.shiftKey) actions.removeTile(coord);
        else if (terrain != null) actions.changeTileType(coord);
        else actions.addTile(coord);
        break;
      case FrequencySetupState:
        if (terrain != null) actions.changeActiveTile(terrain);
        break;
      default:
        break;
    }
  }
}
