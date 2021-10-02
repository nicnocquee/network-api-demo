//
//  XCTest+Helpers.swift
//  NetworkAPIDemoTests
//
//  Created by Nico Prananta on 01.10.21.
//

import Foundation
import XCTest

// xctassertthrowserror belon support async makanya pake extension ini

extension XCTest {
  func XCTAssertThrowsError<T: Sendable>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (_ error: Error) -> Void = { _ in }
  ) async {
    do {
      _ = try await expression()
      XCTFail(message(), file: file, line: line)
    } catch {
      errorHandler(error)
    }
  }
}

