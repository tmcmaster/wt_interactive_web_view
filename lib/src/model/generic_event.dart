import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wt_models/wt_models.dart';

part 'generic_event.freezed.dart';
part 'generic_event.g.dart';

@freezed
class GenericEvent extends BaseModel<GenericEvent> with _$GenericEvent {
  static final convert = DslConvert<GenericEvent>(
      titles: ['type', 'data'],
      jsonToModel: GenericEvent.fromJson,
      none: GenericEvent.empty());

  const factory GenericEvent({
    required String type,
    required Map<String, dynamic> data,
  }) = _GenericEvent;

  const GenericEvent._();

  factory GenericEvent.empty() => const GenericEvent(type: 'null-event', data: {});

  factory GenericEvent.fromString(jsonString) {
    return GenericEvent.fromJson(jsonDecode(jsonString));
  }

  factory GenericEvent.fromJson(Map<String, dynamic> json) => _$GenericEventFromJson(json);

  @override
  String getId() => type;

  @override
  String getTitle() => type;

  @override
  List<String> getTitles() => convert.titles();
}
