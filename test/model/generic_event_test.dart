import 'package:flutter_test/flutter_test.dart';
import 'package:wt_interactive_web_view/src/model/generic_event.dart';

void main() {
  group('GenericEvent', () {
    test('should create a GenericEvent instance', () {
      const event = GenericEvent(
        type: 'exampleType',
        data: {'key1': 'value1', 'key2': 2},
      );

      expect(event.type, 'exampleType');
      expect(event.data, isA<Map<String, dynamic>>());
      expect(event.data['key1'], 'value1');
      expect(event.data['key2'], 2);
    });

    test('should convert a GenericEvent to JSON', () {
      const event = GenericEvent(
        type: 'exampleType',
        data: {'key1': 'value1', 'key2': 2},
      );

      final json = event.toJson();
      expect(json, isA<Map<String, dynamic>>());
      expect(json['type'], 'exampleType');
      expect(json['data'], isA<Map<String, dynamic>>());
      expect(json['data']['key1'], 'value1');
      expect(json['data']['key2'], 2);
    });

    test('should create a GenericEvent from JSON', () {
      final json = {
        'type': 'exampleType',
        'data': {'key1': 'value1', 'key2': 2},
      };

      final event = GenericEvent.fromJson(json);

      expect(event.type, 'exampleType');
      expect(event.data, isA<Map<String, dynamic>>());
      expect(event.data['key1'], 'value1');
      expect(event.data['key2'], 2);
    });

    test('should create a GenericEvent from JSON string', () {
      const jsonString =
          '{"type": "exampleType", "data": {"key1": "value1", "key2": 2}}';

      final event = GenericEvent.fromString(jsonString);

      expect(event.type, 'exampleType');
      expect(event.data, isA<Map<String, dynamic>>());
      expect(event.data['key1'], 'value1');
      expect(event.data['key2'], 2);
    });
  });
}
