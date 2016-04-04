// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

class GameEvents {
  w_module.Event showPaletteModel;
  w_module.Event hidePaletteModel;

  GameEvents(w_module.DispatchKey dispatch) {
    showPaletteModel = new w_module.Event(dispatch);
    hidePaletteModel = new w_module.Event(dispatch);
  }
}
