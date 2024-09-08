import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wt_interactive_web_view/interactive_web_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EventBusFlutter', () {
    late EventBusFlutter eventBusFlutter;

    setUp(() {
      eventBusFlutter = EventBusFlutter.getInstance('test');
    });

    test('should initialize the EventBusFlutter instance', () {
      expect(eventBusFlutter, isNotNull);
    });

    test('should add and remove flutter listeners', () {
      void listener(String event) {};
      eventBusFlutter.addFlutterListener(listener);
      expect(eventBusFlutter.flutterListeners.length, 1);
      eventBusFlutter.removeFlutterListener(listener);
      expect(eventBusFlutter.flutterListeners.length, 0);
    });

    test('should add and remove event bus listeners', () {
      void listener(Map<String, dynamic> event) {};
      eventBusFlutter.addEventBusListener(listener);
      expect(eventBusFlutter.eventBusListeners.length, 1);
      eventBusFlutter.removeEventBusListener(listener);
      expect(eventBusFlutter.eventBusListeners.length, 0);
    });

    test('should emit an event to Flutter', () {
      const eventString = '{"type": "testEvent", "data": {"key": "value"}, "source": "web"}';
      final listener = MockListener<String>();
      eventBusFlutter.addFlutterListener(listener.call);
      eventBusFlutter.emitToFlutter(eventString);
      verify(listener.call(eventString)).called(1);
    });

    test('should not emit an event to Flutter if the source is Flutter', () {
      const eventString = '{"type": "testEvent", "data": {"key": "value"}, "source": "flutter"}';
      final listener = MockListener<String>();
      eventBusFlutter.addFlutterListener(listener.call);
      eventBusFlutter.emitToFlutter(eventString);
      verifyNever(listener.call(eventString));
    });

    test('should emit an event from Flutter', () {
      final listener = MockListener<String>();
      eventBusFlutter.addFlutterListener(listener.call);
      const event = GenericEvent(type: 'testEvent', data: {'key': 'value'});
      eventBusFlutter.emitFromFlutter(event);
      verify(listener.call(jsonEncode(event.toJson()))).called(1);
    });

    test('should publish event to Flutter', () {
      final listener = MockListener<String>();
      eventBusFlutter.addFlutterListener(listener.call);
      const event = GenericEvent(type: 'testEvent', data: {'key': 'value'});
      eventBusFlutter.publishEvent(event);
      verify(listener.call(jsonEncode(event.toJson()))).called(1);
    });
  });
}

class MockListener<T> extends Mock {
  void call(T event);
}
