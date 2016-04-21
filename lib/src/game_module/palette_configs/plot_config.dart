// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

class PlotControlPaletteConfig extends ControlPaletteConfig {
  factory PlotControlPaletteConfig(int plot, GameActions actions) {
    List<PaletteOption> options = [
      new PaletteOption('road', () => actions.build(GamePieceType.Road)),
      new PaletteOption('home', () => actions.build(GamePieceType.Settlement)),
      new PaletteOption('university', () => actions.build(GamePieceType.City)),
      // new PaletteOption('remove', () => actions.unbuild()), // YO, BRING THIS BACK!
    ];
    return new PlotControlPaletteConfig._internal(options);
  }

  PlotControlPaletteConfig._internal(List<PaletteOption> options) : super(options);
}
