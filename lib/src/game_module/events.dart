// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

class GameEvents {
  w_module.Event<bool> setDimmerVisibility;

  GameEvents(w_module.DispatchKey dispatch) {
    setDimmerVisibility = new w_module.Event(dispatch);
  }
}
