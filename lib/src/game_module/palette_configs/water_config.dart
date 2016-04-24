// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

class WaterControlPaletteConfig extends ControlPaletteConfig {
  factory WaterControlPaletteConfig(int tileKey, GameActions actions, GameStore store) {
    List<PaletteOption> options = new List<PaletteOption>();

    if (store.gameState == GameState.Editing) {
      options.add(new PaletteOption('map', () => actions.addTile(tileKey)));
      options.add(new PaletteOption('anchor', () => print('add port ${tileKey}')));
      options.add(new PaletteOption('repeat', () => print('rotate port ${tileKey}')));
      options.add(new PaletteOption('remove', () => print('remove port ${tileKey}')));
    }

    return new WaterControlPaletteConfig._internal(options);
  }

  WaterControlPaletteConfig._internal(List<PaletteOption> options) : super(options);
}
