// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

class TileControlPaletteConfig extends ControlPaletteConfig {
  factory TileControlPaletteConfig(Tile tile, GameActions actions, GameStore store) {
    List<PaletteOption> options = new List<PaletteOption>();

    if (store.gameState == GameState.Editing) {
      options.add(new PaletteOption('theme', () => actions.showDimmer(DimmerType.PickTileTerrain)));
      options.add(new PaletteOption('cube', () => actions.showDimmer(DimmerType.PickTileRoll)));
      options.add(new PaletteOption('remove', () => store.board.actions.removePiece(tile)));
    }

    if (store.gameState == GameState.Playing) {
      options.add(new PaletteOption(
        'user',
        () => store.board.actions.moveThief(tile.key)));
    }

    return new TileControlPaletteConfig._internal(options);
  }

  TileControlPaletteConfig._internal(List<PaletteOption> options) : super(options);
}
