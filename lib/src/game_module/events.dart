// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

class GameEvents {
  w_module.Event<String> showModel;
  w_module.Event<String> hideModel;

  GameEvents(w_module.DispatchKey dispatch) {
    showModel = new w_module.Event<String>(dispatch);
    hideModel = new w_module.Event<String>(dispatch);
  }
}
