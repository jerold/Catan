@JS('catannet')
library catannet;

import "package:js/js.dart";
import "dart:async";

part "src/catannet/catannet.dart";


enum EventType {
    Connected,
    Disconnected,
    LoadGame,
    SaveGame,
    ListenEvent
}

class NetEvent {
    EventType type;
    Object state;

    NetEvent({this.type, this.state});
}

class DartClient {
    Client _client;
    Stream events;
    StreamController _eventController;

    LoadGame(LoadGameRequest r) {
        _client.LoadGame(r);
    }

    SaveGame(SaveGameRequest r) {
        _client.SaveGame(r);
    }

    JoinGame(JoinGame r) {
        _client.JoinGame(r);
    }

    DartClient(String url) {
        _eventController = new StreamController();
        events = _eventController.stream;
        this._client = NewClient();
        var _jsevents = this._client.Events();
        _jsevents.OnConnect(allowInterop(this._onConnect));
        _jsevents.OnSaveGame(allowInterop((msg) => _onMessage(msg, EventType.SaveGame)));
        _jsevents.OnLoadGame(allowInterop((msg) => _onMessage(msg, EventType.LoadGame)));
        _jsevents.OnListenEvent(allowInterop((msg) => _onMessage(msg, EventType.ListenEvent)));

        this._client.Dial(url);
    }

    _onConnect() {
        _eventController.add(new NetEvent(type: EventType.Connected, state: true));
    }

    _onMessage(dynamic msg, EventType et) {
        _eventController.add(new NetEvent(type:et, state: msg));
    }
}

@JS()
external Client NewClient();

typedef OnSaveFunction(SaveGameResponse sgr);
typedef OnLoadFunction(LoadGameResponse lgr);
typedef OnEventFunction(ListenEvent li);

@JS()
class Client {
    external void LoadGame(LoadGameRequest lg);
    external void SaveGame(SaveGameRequest sg);
    external void JoinGame(JoinGame ls);

    external void Dial(String url);

    external ClientEvents Events();
}

@JS()
class ClientEvents {
    external void OnSaveGame(OnSaveFunction handle);
    external void OnLoadGame(OnLoadFunction handle);
    external void OnConnect(Function handle);
    external void OnListenEvent(OnEventFunction handle);
}
