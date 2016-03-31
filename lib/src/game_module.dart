// Copyright (c) 2015, Jerold Albertson. All rights reserved.

library catan.game_module;

import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'dart:js';

import 'package:react/react.dart' as React;
import 'package:w_flux/w_flux.dart';
import 'package:w_module/w_module.dart';

import 'base_model.dart';

part 'game_module/actions.dart';
part 'game_module/api.dart';
part 'game_module/components.dart';
part 'game_module/events.dart';
part 'game_module/store.dart';

part 'game_module/components/board_setup.dart';
part 'game_module/components/board_svg.dart';
part 'game_module/components/editing_state_selector.dart';
part 'game_module/components/editing.dart';
part 'game_module/components/main_menu.dart';
part 'game_module/components/new_game_modal.dart';
part 'game_module/components/pie_chart.dart';
part 'game_module/components/player_setup.dart';
part 'game_module/components/round_game_button.dart';

class GameModule extends Module {
  GameApi _api;
  GameComponents _components;
  GameEvents _events;

  GameApi get api => _api;
  GameComponents get components => _components;
  GameEvents get events => _events;

  GameModule() {
    GameActions actions = new GameActions();
    _events = new GameEvents();
    GameStore store = new GameStore(actions, _events);

    _api = new GameApi(actions);
    _components = new GameComponents(actions, store);
  }
}
