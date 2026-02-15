import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// A utility class for logging messages in a structured format.
///
/// This logger uses the `logger` package to provide different log levels
/// such as verbose, debug, info, warning, and error. Logs are only printed
/// in non-release modes (`debug` and `profile` modes) to avoid unnecessary
/// console output in production.
///
/// The logger supports two modes:
/// - **Standard Mode**: Includes method calls and additional metadata.
/// - **Only Value Mode**: Logs only the message value without additional metadata.
class AppLogger {
  /// Private instance of `Logger` with full logging details.
  static final _logger = Logger(
    printer: PrettyPrinter(
      printEmojis: true, // Enables emoji symbols for log levels.
      dateTimeFormat: DateTimeFormat.onlyTime, // Logs time only, no date.
      methodCount: 3, // Shows the last 3 method calls in stack trace.
      lineLength: 160, // Maximum line length for formatting.
    ),
  );

  /// Private instance of `Logger` that logs only values without metadata.
  static final _onlyValueLogger = Logger(
    printer: PrettyPrinter(
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none, // No timestamp in logs.
      methodCount: 0, // No method trace, only logs the value.
      lineLength: 160,
    ),
  );

  /// Logs a verbose message.
  ///
  /// Verbose logs are meant for detailed debugging information.
  /// They include full stack traces and are useful for diagnosing issues.
  ///
  /// - [value]: The message or object to log.
  /// - [print]: Controls whether the log is printed (default: `true`).
  /// - [onlyValue]: If `true`, logs only the message without metadata.
  static void verbose(
    dynamic value, {
    bool print = true,
    bool onlyValue = false,
  }) {
    if (!kReleaseMode && print) {
      onlyValue ? _onlyValueLogger.t(value) : _logger.t(value);
    }
  }

  /// Logs a highlighted (fatal) message.
  ///
  /// This log level is used for important messages that should stand out.
  ///
  /// - [value]: The message or object to log.
  /// - [print]: Controls whether the log is printed (default: `true`).
  /// - [onlyValue]: If `true`, logs only the message without metadata.
  static void highlight(
    dynamic value, {
    bool print = true,
    bool onlyValue = false,
  }) {
    if (!kReleaseMode && print) {
      onlyValue ? _onlyValueLogger.f(value) : _logger.f(value);
    }
  }

  /// Logs a debug message.
  ///
  /// Debug logs provide insights into manager execution and are useful
  /// for general development and testing.
  ///
  /// - [value]: The message or object to log.
  /// - [print]: Controls whether the log is printed (default: `true`).
  /// - [onlyValue]: If `true`, logs only the message without metadata.
  static void debug(
    dynamic value, {
    bool print = true,
    bool onlyValue = false,
  }) {
    if (!kReleaseMode && print) {
      onlyValue ? _onlyValueLogger.d(value) : _logger.d(value);
    }
  }

  /// Logs a warning message.
  ///
  /// Warnings indicate potential issues that may require attention
  /// but are not necessarily errors.
  ///
  /// - [value]: The message or object to log.
  /// - [print]: Controls whether the log is printed (default: `true`).
  /// - [onlyValue]: If `true`, logs only the message without metadata.
  static void warning(
    dynamic value, {
    bool print = true,
    bool onlyValue = false,
  }) {
    if (!kReleaseMode && print) {
      onlyValue ? _onlyValueLogger.w(value) : _logger.w(value);
    }
  }

  /// Logs an informational message.
  ///
  /// Info logs are used for general informational messages that help
  /// in understanding the manager's flow.
  ///
  /// - [value]: The message or object to log.
  /// - [print]: Controls whether the log is printed (default: `true`).
  /// - [onlyValue]: If `true`, logs only the message without metadata.
  static void info(dynamic value, {bool print = true, bool onlyValue = false}) {
    if (!kReleaseMode && print) {
      onlyValue ? _onlyValueLogger.i(value) : _logger.i(value);
    }
  }

  /// Logs an error message.
  ///
  /// Error logs are used for unexpected issues and should always be logged,
  /// even in release mode, for debugging and monitoring purposes.
  ///
  /// - [e]: The exception or error message to log.
  static void error(dynamic e) {
    _logger.e(e);
  }
}
