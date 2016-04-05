// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

class GameApi {
  GameActions _actions;
  GameApi(this._actions);

  dimmerVisibilitySet(bool show) {
    _actions.dimmerVisibilitySet(show);
  }
}
