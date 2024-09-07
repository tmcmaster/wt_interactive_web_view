import 'dart:convert';

import 'package:wt_interactive_web_view/src/utils/log.dart';
import 'package:js/js.dart' as js;
import 'package:js/js_util.dart' as js_util;

class EventBusFlutter {
  static final log = Log.d();

  static final instances = <String, EventBusFlutter>{};

  // Event Bus listening to the Flutter
  final flutterListeners = <void Function(String event)>[];
  // Flutter listening to the Event Bus
  final eventBusListeners = <void Function(Map<String, dynamic> event)>[];

  EventBusFlutter._(String name) {
    log.d('EventBusFlutter: Initialising the event bus adapter');
    // TODO: need to integrate the name into the state name.
    const stateName = '_EventBusState';
    final export = js_util.createDartExport(this);
    try {
      js_util.setProperty(js_util.globalThis, stateName, export);
      // TODO: need to make this _EventBusInitialise use the stateName arg
      js_util.callMethod<void>(js_util.globalThis, '_EventBusInitialise', []);
    } catch (error) {
      log.e('EventBusFlutter: Could not create the Javascript bridge: $error');
    }
  }

  factory EventBusFlutter.getInstance(String name) {
    if (!instances.containsKey(name)) {
      log.d('EventBusFlutter: Creating new adapter: $name');
      instances[name] = EventBusFlutter._(name);
    }
    return instances[name]!;
  }

  @js.JSExport()
  void addFlutterListener(void Function(String event) listener) {
    log.d('EventBusFlutter: Event Bus adding listener to Flutter');
    flutterListeners.add(listener);
  }

  @js.JSExport()
  void removeFlutterListener(void Function(String event) listener) {
    log.d('EventBusFlutter: Event Bus removing listener from Flutter');
    flutterListeners.remove(listener);
  }

  void addEventBusListener(void Function(Map<String, dynamic> event) listener) {
    log.d('EventBusFlutter: Flutter adding listener to the Event Bus');
    eventBusListeners.add(listener);
  }

  void removeEventBusListener(void Function(String event) listener) {
    log.d('EventBusFlutter: Flutter removing listening from the Event Bus');
    eventBusListeners.remove(listener);
  }

  @js.JSExport()
  void emitToFlutter(String eventString) {
    final event = jsonDecode(eventString);

    if (event['source'] != 'flutter') {
      log.d('EventBusFlutter: Emitting event to Flutter: $eventString');
      for (var listener in eventBusListeners) {
        listener(event);
      }
    }
  }

  void emitFromFlutter(Map<String, dynamic> event) {
    log.d('EventBusFlutter: Emitting event from Flutter: $event');
    for (var listener in flutterListeners) {
      final eventString = jsonEncode(event);
      listener(eventString);
    }
  }

  void publishEvent(Map<String, dynamic> event) {
    emitFromFlutter(event);
  }
}