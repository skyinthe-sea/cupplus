import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

abstract final class AppLogger {
  static void debug(String message, [String tag = 'CupPlus']) {
    if (kDebugMode) {
      developer.log(message, name: tag, level: 500);
    }
  }

  static void info(String message, [String tag = 'CupPlus']) {
    if (kDebugMode) {
      developer.log(message, name: tag, level: 800);
    }
  }

  static void warning(String message, [String tag = 'CupPlus']) {
    if (kDebugMode) {
      developer.log(message, name: tag, level: 900);
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      developer.log(
        message,
        name: 'CupPlus',
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
