// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

class PortControlPaletteConfig extends ControlPaletteConfig {
  factory PortControlPaletteConfig(Port port, GameActions actions, GameStore store) {
    List<PaletteOption> options = new List<PaletteOption>();

    if (store.gameState == GameState.Editing) {
      options.add(new PaletteOption('theme', () => actions.showDimmer(DimmerType.PickTileTerrain)));
      options.add(new PaletteOption('repeat', () => store.board.actions.rotateActivePort()));
      options.add(new PaletteOption('remove', () => store.board.actions.removePiece(port)));
    }

    return new PortControlPaletteConfig._internal(options);
  }

  PortControlPaletteConfig._internal(List<PaletteOption> options) : super(options);
}
