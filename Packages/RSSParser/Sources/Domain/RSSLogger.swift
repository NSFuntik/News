//
//  RSSLogger.swift
//  RSSParser
//
//  Created by NSFuntik on 11/18/24.
//
import Foundation
import OSLog

/// Custom logger for RSS parsing operations
@available(macOS 12.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
public final class RSSLogger {
  /// Private logger and signposter instances.
  private let logger: Logger
  private let signposter: OSSignposter
  /// Initializes a new `RSSLogger` instance with the specified subsystem and category.
  /// The subsystem defaults to the application's bundle identifier and the category defaults to "RSSParser".
  ///
  /// - Parameters:
  ///   - subsystem: The subsystem identifier for the logger. Defaults to the main bundle identifier.
  ///   - category: The category identifier for the logger. Defaults to "RSSParser".
  public init(
    subsystem: String = Bundle.main.bundleIdentifier ?? "com.rssparser",
    category: String = "RSSParser"
  ) {
    self.logger = Logger(subsystem: subsystem, category: category)
    self.signposter = OSSignposter(subsystem: subsystem, category: category)
  }

  /// Logs a debug message along with the file and line number where it was called.
  ///
  /// - Parameters:
  ///   - message: The message to log.
  ///   - file: The file name from which the log was called.
  ///   - line: The line number from which the log was called.
  public func debug(_ message: String, file: String = #file, line: Int = #line) {
    logger.debug("\(message) [\(file):\(line)]")
  }

  /// Logs an informational message along with the file and line number where it was called.
  ///
  /// - Parameters:
  ///   - message: The message to log.
  ///   - file: The file name from which the log was called.
  ///   - line: The line number from which the log was called.
  public func info(_ message: String, file: String = #file, line: Int = #line) {
    logger.info("\(message) [\(file):\(line)]")
  }

  /// Logs a warning message along with the file and line number where it was called.
  ///
  /// - Parameters:
  ///   - message: The message to log.
  ///   - file: The file name from which the log was called.
  ///   - line: The line number from which the log was called.
  public func warning(_ message: String, file: String = #file, line: Int = #line) {
    logger.warning("\(message) [\(file):\(line)]")
  }

  /// Logs an error message with an optional error object, along with the file and line number where it was called.
  ///
  /// - Parameters:
  ///   - message: The message to log.
  ///   - error: An optional error object to include in the log.
  ///   - file: The file name from which the log was called.
  ///   - line: The line number from which the log was called.
  public func error(_ message: String, error: Error? = nil, file: String = #file, line: Int = #line) {
    if let error = error {
      logger.error("\(message): \(error.localizedDescription) [\(file):\(line)]")
    } else {
      logger.error("\(message) [\(file):\(line)]")
    }
  }

  /// Begins a signpost interval for performance measurement.
  ///
  /// - Parameters:
  ///   - name: The name of the signpost event to emit.
  /// - Returns: An identifier for the signpost.

  public func beginInterval(_ name: StaticString) -> OSSignpostID {
    let id = signposter.makeSignpostID()
    signposter.emitEvent(name, "begin")
    return id
  }

  /// Ends a signpost interval for performance measurement.
  ///
  /// - Parameters:
  ///   - name: The name of the signpost event to emit.
  ///   - id: The identifier for the signpost to terminate.
  public func endInterval(_ name: StaticString, _ id: OSSignpostID) {
    signposter.emitEvent(name, "end")
  }

  /// Logs statistics related to the RSS parsing process.
  ///
  /// - Parameters:
  ///   - metrics: An `RSS.Metrics` object containing various statistics about the parsing.
  public func logParserStats(_ metrics: RSS.Metrics) {
    let message = """
      RSS Parser Statistics:
      - Parsing duration: \(String(format: "%.3f", metrics.parsingDuration))s
      - Items parsed: \(metrics.itemCount)
      - Items per second: \(String(format: "%.1f", metrics.itemsPerSecond))
      - Data size: \(metrics.dataSize) bytes
      - Processing speed: \(String(format: "%.1f", metrics.bytesPerSecond)) bytes/s
      """
    info(message)
  }
}
