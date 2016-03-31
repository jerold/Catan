import 'dart:html' as Html;

import 'package:react/react_client.dart' as ReactClient;
import 'package:react/react_dom.dart' as ReactDom;

import 'package:catan/catan.dart';

main() async {
  GameModule module = new GameModule();
  await module.load();

  ReactClient.setClientConfiguration();
  ReactDom.render(module.components.content(), Html.querySelector('#content'));
}
