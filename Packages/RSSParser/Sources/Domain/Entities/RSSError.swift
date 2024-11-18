//
//  RSSError.swift
//
//
//  Created by NSFuntik on 11/18/24.
//

import Foundation
import os.log

/// An enumeration representing various error types that may occur in the RSS parsing process.
public enum RSSError: LocalizedError {
  /// Indicates that the data returned is empty.
  case emptyData
  /// Indicates that the provided URL is invalid.
  case invalidURL(URL?)
  /// Indicates that a network error occurred, potentially with a status code.
  case networkError(underlying: Error, statusCode: Int?)
  /// Indicates that a parsing error occurred.
  case parsingError(underlying: Error)
  /// Indicates that the data is invalid for a specified reason.
  case invalidData(reason: String)
  /// Indicates that a required field is missing from the data.
  case missingRequiredField(field: String)
  /// Indicates that the date format is invalid along with attempted formats.
  case invalidDateFormat(dateString: String, attemptedFormats: [String])
  /// Indicates a timeout occurred during parsing after a specific duration.
  case parsingTimeout(duration: TimeInterval)
  /// Indicates that the feed format is unsupported, providing the detected format.
  case unsupportedFormat(detected: String)
  /// The unique error code associated with the specific error case.
  public var errorCode: Int {
    switch self {
    case .emptyData: return 1001
    case .invalidURL: return 1002
    case .networkError: return 1003
    case .parsingError: return 1004
    case .invalidData: return 1005
    case .missingRequiredField: return 1006
    case .invalidDateFormat: return 1007
    case .parsingTimeout: return 1008
    case .unsupportedFormat: return 1009
    }
  }

  /// A localized description of the error, providing details about the error's cause.
  public var errorDescription: String? {
    switch self {
    case .emptyData:
      return "The RSS feed data is empty."

    case .invalidURL(let url):
      return "Invalid URL: \(url?.absoluteString ?? "nil")"

    case .networkError(let error, let statusCode):
      if let code = statusCode {
        return "Network error (status code: \(code)): \(error.localizedDescription)"
      } else {
        return "Network error: \(error.localizedDescription)"
      }

    case .parsingError(let error):
      return "Parsing error: \(error.localizedDescription)"

    case .invalidData(let reason):
      return "Invalid data: \(reason)"

    case .missingRequiredField(let field):
      return "Missing required field: \(field)"

    case .invalidDateFormat(let dateString, let formats):
      return "Could not parse date '\(dateString)' using formats: \(formats.joined(separator: ", "))"

    case .parsingTimeout(let duration):
      return "Parsing timed out after \(String(format: "%.1f", duration)) seconds"

    case .unsupportedFormat(let format):
      return "Unsupported feed format: \(format)"
    }
  }

  /// A reason that explains why the error occurred.
  public var failureReason: String? {
    switch self {
    case .emptyData:
      return "The provided data contains no content"
    case .invalidURL:
      return "The URL format is not valid"
    case .networkError:
      return "Failed to fetch data from the network"
    case .parsingError:
      return "Failed to parse the RSS feed content"
    case .invalidData:
      return "The data format is not valid"
    case .missingRequiredField:
      return "A required field is missing from the feed"
    case .invalidDateFormat:
      return "The date format in the feed is not recognized"
    case .parsingTimeout:
      return "The parsing operation took too long"
    case .unsupportedFormat:
      return "The feed format is not supported"
    }
  }

  /// A suggestion for recovering from the error, if applicable.
  public var recoverySuggestion: String? {
    switch self {
    case .emptyData:
      return "Please ensure the RSS feed URL returns content"
    case .invalidURL:
      return "Please check the URL format and try again"
    case .networkError:
      return "Please check your internet connection and try again"
    case .parsingError:
      return "Please verify that the feed contains valid RSS content"
    case .invalidData:
      return "Please ensure the feed follows RSS specification"
    case .missingRequiredField:
      return "Please ensure all required fields are present in the feed"
    case .invalidDateFormat:
      return "Please ensure the feed uses standard date formats"
    case .parsingTimeout:
      return "Try parsing a smaller portion of the feed"
    case .unsupportedFormat:
      return "Please provide an RSS formatted feed"
    }
  }

  /// Metadata for logging the error, including error code and type.
  public var loggingMetadata: [String: String] {
    var metadata: [String: String] = [
      "errorCode": String(errorCode),
      "errorType": String(describing: self),
    ]

    switch self {
    case .networkError(let error, let statusCode):
      metadata["underlyingError"] = error.localizedDescription
      if let code = statusCode {
        metadata["statusCode"] = String(code)
      }

    case .parsingError(let error):
      metadata["underlyingError"] = error.localizedDescription

    case .invalidDateFormat(let dateString, let formats):
      metadata["dateString"] = dateString
      metadata["attemptedFormats"] = formats.joined(separator: ", ")

    case .invalidURL(let url):
      metadata["url"] = url?.absoluteString

    case .missingRequiredField(let field):
      metadata["field"] = field

    case .invalidData(let reason):
      metadata["reason"] = reason

    case .parsingTimeout(let duration):
      metadata["duration"] = String(format: "%.1f", duration)

    case .unsupportedFormat(let format):
      metadata["format"] = format

    case .emptyData:
      break
    }

    return metadata
  }
}

// MARK: - Error Handling Utilities

/// A utility that provides functions for handling errors related to RSS processing.
public enum RSSErrorHandler {
  /// Extracts a parsing error from a given error, returning an RSSError instance.
  public static func extractParsingError(_ error: Error) -> RSSError {
    switch error {
    case let nsError as NSError:
      return .parsingError(underlying: nsError)
    default:
      return .parsingError(underlying: error as NSError)
    }
  }

  /// Handles the network response and generates an RSSError if applicable.
  public static func handleNetworkResponse(_ response: URLResponse?, error: Error?) -> RSSError? {
    if let error = error {
      let statusCode = (response as? HTTPURLResponse)?.statusCode
      return .networkError(underlying: error, statusCode: statusCode)
    }

    guard let httpResponse = response as? HTTPURLResponse else {
      return .networkError(
        underlying: URLError(.badServerResponse),
        statusCode: nil
      )
    }

    guard (200 ... 299).contains(httpResponse.statusCode) else {
      return .networkError(
        underlying: URLError(.badServerResponse),
        statusCode: httpResponse.statusCode
      )
    }

    return nil
  }

  /// Validates the required fields of a given RSS item, returning an RSSError if any are missing.
  public static func validateRequiredFields(_ item: RSSItem) -> RSSError? {
    if item.title.isEmpty {
      return .missingRequiredField(field: "title")
    }
    if item.description.isEmpty {
      return .missingRequiredField(field: "description")
    }
    return nil
  }
}

extension RSSError: Equatable {
  public static func == (lhs: RSSError, rhs: RSSError) -> Bool {
    switch (lhs, rhs) {
    case (.emptyData, .emptyData):
      return true
    case (.parsingError(let lhsError), .parsingError(let rhsError)):
      return lhsError.localizedDescription == rhsError.localizedDescription
    case (.networkError(let lhsError, _), .networkError(let rhsError, _)):
      return lhsError.localizedDescription == rhsError.localizedDescription
    default:
      return false
    }
  }
}
