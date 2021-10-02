//
//  APITests.swift
//  NetworkAPIDemoTests
//
//  Created by Nico Prananta on 01.10.21.
//

import Foundation
import XCTest
import Alamofire
@testable import NetworkAPIDemo

class APITests: XCTestCase {
  private var manager: Session?
  
  override func setUp() {
    super.setUp()
    
    manager = {
      let configuration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        return configuration
      }()
      
      return Session(configuration: configuration)
    }()
  }
  
  override func tearDown() {
    super.tearDown()
    
    manager = nil
  }
  
  func testFetchSuccess() async throws {
    let sampleResponse = """
{
  "jwt": "abcd"
}
"""
    MockURLProtocol.responseWithStatusCode(code: 200, data: sampleResponse.data(using: .utf8))
    let expected = try! JSONDecoder().decode(AuthData.self, from: sampleResponse.data(using: .utf8)!)
    let loginData = LoginData(identifier: "a@a.com", password: "aaa")
    let loginRequest = LoginRequest(loginData: loginData)
    let actual = try await API(fetcher: AlamofireFetcher(session: manager!)).fetch(loginRequest)
    XCTAssertEqual(actual.jwt, expected.jwt)
  }
  
  func testFetchError() async throws {
    let sampleResponse = """
{
    "statusCode": 400,
  "error": "Bad Request"
}
"""
    MockURLProtocol.responseWithStatusCode(code: 400, data: sampleResponse.data(using: .utf8))
    let loginData = LoginData(identifier: "a@a.com", password: "aaa")
    let loginRequest = LoginRequest(loginData: loginData)
    
    await XCTAssertThrowsError( try await API(fetcher: AlamofireFetcher(session: manager!)).fetch(loginRequest))
  }
  
  func testUploadSuccess() async throws {
    let sampleResponse = """
[
{
  "id": 1,
  "url": "http://localhost",
  "name": "a file",
  "width": 100,
  "height": 100,
  "size": 300
}
]
"""
    MockURLProtocol.responseWithStatusCode(code: 200, data: sampleResponse.data(using: .utf8))
    let expected = try! JSONDecoder().decode([Uploaded].self, from: sampleResponse.data(using: .utf8)!)
    let fetcher = TestFetcher()
    fetcher.dummyResponseString = sampleResponse
    fetcher.expectedPathname = "/upload"
    fetcher.expectedMethod = "POST"
    
    let uploadRequest = UploadRequest(file: MultipartData(data: "test".data(using: .utf8)!, name: "files", fileName: "somefile", mimeType: "image/jpeg"))
    
    let actual = try await API(fetcher: AlamofireFetcher(session: manager!)).fetch(uploadRequest)
    XCTAssertEqual(actual.first!.id, expected.first!.id)
  }
  
  func testUploadError() async throws {
    let sampleResponse = """
{
    "statusCode": 400,
  "error": "Bad Request"
}
"""
    MockURLProtocol.responseWithStatusCode(code: 400, data: sampleResponse.data(using: .utf8))
    let uploadRequest = UploadRequest(file: MultipartData(data: "test".data(using: .utf8)!, name: "files", fileName: "somefile", mimeType: "image/jpeg"))
    
    await XCTAssertThrowsError(try await API(fetcher: AlamofireFetcher(session: manager!)).fetch(uploadRequest))
  }
}
