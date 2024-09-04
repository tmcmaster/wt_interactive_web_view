import 'package:logger/logger.dart';

class Log {
  static Logger d() {
    return Logger(level: Level.debug, printer: SimplePrinter());
  }
}
