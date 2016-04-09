// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

class WaterControlPaletteConfig extends ControlPaletteConfig {
  factory WaterControlPaletteConfig(int tileKey, GameActions actions) {
    List<PaletteOption> options = [
      new PaletteOption('map', () => actions.addTile(tileKey)),
      new PaletteOption('anchor', () => print('add port ${tileKey}')),
      new PaletteOption('repeat', () => print('rotate port ${tileKey}')),
      new PaletteOption('remove', () => print('remove port ${tileKey}')),
    ];
    return new WaterControlPaletteConfig._internal(options);
  }

  WaterControlPaletteConfig._internal(List<PaletteOption> options) : super(options);
}
