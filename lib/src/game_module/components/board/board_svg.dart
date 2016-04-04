// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


var BoardSvg = react.registerComponent(() => new _BoardSvg());
class _BoardSvg extends w_flux.FluxComponent<GameActions, GameStore> {
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

    // Expansions
    if (store.gameState == EditingState) {
      children.add(WaterGroup({'actions': actions, 'store': store}));
    }

    // Tiles
    store.gameBoard.tiles.values.forEach((tile) {
      children.add(TileGroup({
        'actions': actions,
        'store': store,
        'tile': tile}));
    });

    // Plots
    children.add(PlotGroup({'actions': actions, 'store': store}));

    // Tile Overlay
    // if (store.showTileOverlay) {
    //   children.add(TileOverlayComponent({
    //     'actions': actions,
    //     'store': store,
    //   }));
    // }

    Rectangle viewBox = new Rectangle(
      store.viewport.left * COORD_SPACING,
      store.viewport.top * COORD_SPACING,
      store.viewport.width * COORD_SPACING,
      store.viewport.height * COORD_SPACING
    );
    return react.svg({
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

  void _tileClicked(react.SyntheticMouseEvent e, Tile tile) {
    if (store.gameState == EditingState && e.shiftKey) actions.removeTile(tile.key);
  }

  void _tileMouseDown(react.SyntheticMouseEvent e, Tile tile) {
    actions.changeActiveTile(tile);
    if (store.gameState == EditingState && !e.shiftKey) _startOverlayTimer();
  }

  void _expansionClicked(react.SyntheticMouseEvent e, int key) {
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
