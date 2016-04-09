// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

class TileControlPaletteConfig extends ControlPaletteConfig {
  factory TileControlPaletteConfig(Tile tile, GameActions actions) {
    List<PaletteOption> options = [
      new PaletteOption('theme', () => print('change type')),
      new PaletteOption('cube', () => print('change roll')),
      new PaletteOption('user', () => actions.moveThief()),
      new PaletteOption('remove', () => actions.removeTile(tile.key)),
    ];
    return new TileControlPaletteConfig._internal(options);
  }

  TileControlPaletteConfig._internal(List<PaletteOption> options) : super(options);
}
