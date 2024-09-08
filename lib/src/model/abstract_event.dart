import 'package:wt_interactive_web_view/src/model/generic_event.dart';

mixin AbstractEvent {
  GenericEvent toGenericEvent();
  Map<String, dynamic> toJson();
}