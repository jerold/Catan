// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var BoardSvg = React.registerComponent(() => new _BoardSvg());
class _BoardSvg extends FluxComponent<GameActions, GameStore> {
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
    store.gameBoard.map.values.forEach((terrain) {
      String text = terrain.type != TerrainType.Desert ? terrain.token.toString() : '';
      children.add(RoundGameButton({
        'text': text,
        'pipCount': chances(terrain.token),
        'fill': terrainTypeToColor(terrain.type),
        'radius': distance_between_coords / 1.5,
        'center': scaledPoint(terrain.coordinate),
        'selected': store.activeTerrain == terrain,
        'onClick': (e) => _tileClicked(e, terrain),
        'onMouseDown': (e) => _tileMouseDown(e, terrain),
      }));
    });

    // Expansions
    if (store.gameState == EditingState) {
      store.gameBoard.expansionTiles().forEach((coordKey) {
        Coordinate expCoord = Coordinate.fromKey(coordKey);
        children.add(RoundGameButton({
          'pipCount': 0,
          'fill': waterColor,
          'radius': distance_between_coords / 2,
          'center': scaledPoint(expCoord),
          'selected': false,
          'onClick': (e) => _expansionClicked(e, expCoord),
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

    return React.svg({
      'version': '1.1',
      'xmlns': 'http://www.w3.org/2000/svg',
      'width': '100%',
      'height': '100%',
      'viewBox': '0 0 ${20 * distance_between_coords} ${20 * distance_between_coords}',
      'style': {
        'WebkitTouchCallout': 'none',
        'WebkitUserSelect': 'none',
        'KhtmlUserSelect': 'none',
        'MozUserSelect': 'none',
        'MsUserSelect': 'none',
        'userSelect': 'none',
        // 'transform': 'scale(3.0)',
        // 'outline': '1px solid rgba(200, 200, 200, .75)',
      }
    }, children);
  }

  void _tileClicked(React.SyntheticMouseEvent e, Terrain tile) {
    if (store.gameState == EditingState && e.shiftKey) actions.removeTile(tile.coordinate);
  }

  void _tileMouseDown(React.SyntheticMouseEvent e, Terrain tile) {
    actions.changeActiveTile(tile);
    if (store.gameState == EditingState && !e.shiftKey) _startOverlayTimer();
  }

  void _expansionClicked(React.SyntheticMouseEvent e, Coordinate coord) {
    actions.addTile(coord);
  }

  void _startOverlayTimer() {
    if (tileOverlayTimer != null) tileOverlayTimer.cancel();
    tileOverlayTimer = new Timer(OVERLAY_TIMEOUT, _showOverlay);
  }

  void _showOverlay() {
    if (store.gameState == EditingState) {
      actions.setShowTileOverlay(true);
    }
  }

  void _hideOverlay(_) {
    if (tileOverlayTimer != null) tileOverlayTimer.cancel();
    tileOverlayTimer = null;

    if (store.gameState == EditingState) {
      actions.setShowTileOverlay(false);
    }
  }
}
