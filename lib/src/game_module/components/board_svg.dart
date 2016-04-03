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
    store.gameBoard.tiles.values.forEach((tile) {
      String text = tile.type != TileType.Desert ? tile.roll.toString() : '';
      children.add(RoundGameButton({
        'text': text,
        'pipCount': chances(tile.roll),
        'fill': tileTypeToColor(tile.type),
        'radius': distance_between_coords / 1.5,
        'center': scaledPoint(tile.coordinate, store.viewport),
        'selected': store.activeTile == tile,
        'onClick': (e) => _tileClicked(e, tile),
        'onMouseDown': (e) => _tileMouseDown(e, tile),
      }));
    });

    // Expansions
    if (store.gameState == EditingState) {
      store.gameBoard.expansionTiles.forEach((coordKey) {
        Coordinate expCoord = Coordinate.fromKey(coordKey);
        children.add(RoundGameButton({
          'pipCount': 0,
          'fill': waterColor,
          'radius': distance_between_coords / 2,
          'center': scaledPoint(expCoord, store.viewport),
          'selected': false,
          'onClick': (e) => _expansionClicked(e, coordKey),
        }));
      });
    }

    // Plots
    store.gameBoard.plots.forEach((coordKey) {
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

    Rectangle viewBox = new Rectangle(
      store.viewport.left * distance_between_coords,
      store.viewport.top * distance_between_coords,
      store.viewport.width * distance_between_coords,
      store.viewport.height * distance_between_coords
    );
    return React.svg({
      'version': '1.1',
      'xmlns': 'http://www.w3.org/2000/svg',
      'width': viewBox.width,
      'height': viewBox.height,
      'viewBox': '${viewBox.left} ${viewBox.top} ${viewBox.width} ${viewBox.height}',
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

  void _tileClicked(React.SyntheticMouseEvent e, Tile tile) {
    if (store.gameState == EditingState && e.shiftKey) actions.removeTile(tile.key);
  }

  void _tileMouseDown(React.SyntheticMouseEvent e, Tile tile) {
    actions.changeActiveTile(tile);
    if (store.gameState == EditingState && !e.shiftKey) _startOverlayTimer();
  }

  void _expansionClicked(React.SyntheticMouseEvent e, int key) {
    actions.addTile(key);
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
