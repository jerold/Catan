// Copyright (c) 2015, Jerold Albertson. All rights reserved.

library catan.game_module;

import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'package:react/react.dart' as react;
import 'package:w_flux/w_flux.dart' as w_flux;
import 'package:w_module/w_module.dart' as w_module;

import 'base_model.dart';

part 'game_module/actions.dart';
part 'game_module/components.dart';
part 'game_module/store.dart';

part 'game_module/components/board_setup.dart';
part 'game_module/components/current_turn_options.dart';
part 'game_module/components/editing_state_selector.dart';
part 'game_module/components/editing.dart';
part 'game_module/components/helper.dart';
part 'game_module/components/history_list.dart';
part 'game_module/components/main_menu.dart';
part 'game_module/components/payer_segment.dart';
part 'game_module/components/pie_chart.dart';
part 'game_module/components/player_setup.dart';
part 'game_module/components/playing.dart';
part 'game_module/components/players.dart';

part 'game_module/components/board/board_svg.dart';
part 'game_module/components/board/building_group.dart';
part 'game_module/components/board/plot_group.dart';
part 'game_module/components/board/tile_group.dart';
part 'game_module/components/board/water_group.dart';

part 'game_module/components/dimmers/confirm_new_game.dart';
part 'game_module/components/dimmers/control_palette.dart';
part 'game_module/components/dimmers/dimmer.dart';
part 'game_module/components/dimmers/pick_tile_roll.dart';
part 'game_module/components/dimmers/pick_tile_terrain.dart';
part 'game_module/components/dimmers/roll.dart';
part 'game_module/components/dimmers/trade.dart';

part 'game_module/palette_configs/plot_config.dart';
part 'game_module/palette_configs/tile_config.dart';
part 'game_module/palette_configs/water_config.dart';

class GameModule extends w_module.Module {
  GameComponents _components;
  GameComponents get components => _components;

  GameModule() {
    GameActions actions = new GameActions();
    GameStore store = new GameStore(actions);

    _components = new GameComponents(actions, store);
  }
}
