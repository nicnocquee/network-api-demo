//
//  NetworkAPIDemoTests.swift
//  NetworkAPIDemoTests
//
//  Created by Nico Prananta on 29.09.21.
//

import XCTest
import Alamofire
@testable import NetworkAPIDemo

class TestFetcher: FetchCapable {
  var dummyResponseString: String = ""
  var expectedPathname: String?
  var expectedMethod: String?
  var expectedError: Error?
  
  func fetch<ResponseType>(request: URLRequest, decodeTo: ResponseType.Type) async throws -> ResponseType where ResponseType : Decodable {
    if let error = expectedError {
      throw error
    }
    if let pathname = expectedPathname {
      if request.url?.path != pathname {
        throw NSError(domain: "NetworkAPIDemoXCTest", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Pathname invalid. Expected: \(pathname). Actual: \(request.url?.path ?? "nil")"])
      }
    }
    if let method = expectedMethod {
      if request.method?.rawValue != method {
        throw NSError(domain: "NetworkAPIDemoXCTest", code: 1002, userInfo: [NSLocalizedDescriptionKey : "Method invalid. Expected: \(method). Actual: \(request.method?.rawValue ?? "nil")"])
      }
    }
    if request.method?.rawValue == "POST" {
      if request.httpBody == nil {
        throw NSError(domain: "NetworkAPIDemoXCTest", code: 1003, userInfo: [NSLocalizedDescriptionKey : "HTTP Body is required. Expected: not nil. Actual: nil"])
      }
    }
    return try dummyDecoded(to: ResponseType.self)
  }
  
  func upload<ResponseType>(multipart: [MultipartData], toURL: String, decodeTo: ResponseType.Type, headers: HTTPHeaders?) async throws -> ResponseType where ResponseType : Decodable {
    if let error = expectedError {
      throw error
    }
    if let pathname = expectedPathname {
      if toURL ~= pathname {
        throw NSError(domain: "NetworkAPIDemoXCTest", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Pathname invalid. Expected: \(pathname). Actual: \(toURL)"])
      }
    }
    return try dummyDecoded(to: ResponseType.self)
  }
  
  private func dummyDecoded<T> (to: T.Type) throws -> T where T: Decodable {
    let data = dummyResponseString.data(using: .utf8)
    let decoded = try JSONDecoder().decode(to, from: data!)
    return decoded
  }
}

class RequestTests: XCTestCase {
  func testFetchThrowsError() async throws {
    let fetcher = TestFetcher()
    fetcher.expectedError = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 404))
    
    let newPost = Post(id: 0, title: "A new post title", body: "A new post body")
    
    await XCTAssertThrowsError(try await API(fetcher:fetcher).fetch(NewPostRequest(newPost: newPost)), "Error something", { error in
      XCTAssertNotNil(error.asAFError!.isResponseValidationError)
    })
  }
  
  func testPostsFetch() async throws {
    let sampleResponse = """
[
  {
    "id": 1,
    "title": "First public post",
    "body": "The first mate and his Skipper too will do their very best to make the others comfortable in their tropic island nest. Michael Knight a young loner on a crusade to champion the cause of the innocent. The helpless. The powerless in a world of criminals who operate above the law. Here he comes Here comes Speed Racer. He's a demon on wheels.",
    "author": {
      "id": 1,
      "username": "nicop",
      "email": "nico.prananta@gmail.com",
      "provider": "local",
      "confirmed": true,
      "blocked": null,
      "role": 1,
      "created_at": "2021-09-30T20:03:50.296Z",
      "updated_at": "2021-09-30T20:03:50.304Z"
    },
    "createdAt": "2021-09-30T20:41:04.941Z",
    "private": false,
    "published_at": "2021-09-30T20:41:04.942Z",
    "created_at": "2021-09-30T20:41:04.950Z",
    "updated_at": "2021-09-30T20:41:04.955Z"
  },
  {
    "id": 3,
    "title": "Second public post",
    "body": "The first mate and his Skipper too will do their very best to make the others comfortable in their tropic island nest. Michael Knight a young loner on a crusade to champion the cause of the innocent. The helpless. The powerless in a world of criminals who operate above the law. Here he comes Here comes Speed Racer. He's a demon on wheels.",
    "author": {
      "id": 1,
      "username": "nicop",
      "email": "nico.prananta@gmail.com",
      "provider": "local",
      "confirmed": true,
      "blocked": null,
      "role": 1,
      "created_at": "2021-09-30T20:03:50.296Z",
      "updated_at": "2021-09-30T20:03:50.304Z"
    },
    "createdAt": "2021-09-30T20:41:29.706Z",
    "private": false,
    "published_at": "2021-09-30T20:41:29.706Z",
    "created_at": "2021-09-30T20:41:29.710Z",
    "updated_at": "2021-09-30T20:41:29.715Z"
  }
]
"""
    let expected = try! JSONDecoder().decode([Post].self, from: sampleResponse.data(using: .utf8)!)
    let fetcher = TestFetcher()
    fetcher.dummyResponseString = sampleResponse
    fetcher.expectedPathname = "/posts"
    
    let actual = try await API(fetcher:fetcher).fetch(PostsRequest())
    XCTAssertEqual(actual, expected)
  }
  
  func testNewPostRequest() async throws {
    let sampleResponse = """
{
  "id": 101,
  "title": "A new post title",
  "body": "A new post body"
}
"""
    let expected = try! JSONDecoder().decode(Post.self, from: sampleResponse.data(using: .utf8)!)
    let fetcher = TestFetcher()
    fetcher.dummyResponseString = sampleResponse
    fetcher.expectedPathname = "/posts"
    fetcher.expectedMethod = "POST"
    
    let newPost = Post(id: 0, title: "A new post title", body: "A new post body")
    
    let actual = try await API(fetcher:fetcher).fetch(NewPostRequest(newPost: newPost))
    XCTAssertEqual(actual, expected)
  }
  
  func testLoginRequest() async throws {
    let sampleResponse = """
{
  "jwt": "abcd"
}
"""
    let expected = try! JSONDecoder().decode(AuthData.self, from: sampleResponse.data(using: .utf8)!)
    let fetcher = TestFetcher()
    fetcher.dummyResponseString = sampleResponse
    fetcher.expectedPathname = "/auth/local"
    fetcher.expectedMethod = "POST"
    
    let loginData = LoginData(identifier: "a@a.com", password: "aaa")
    let loginRequest = LoginRequest(loginData: loginData)
    
    let actual = try await API(fetcher:fetcher).fetch(loginRequest)
    XCTAssertEqual(actual.jwt, expected.jwt)
  }
  
  func testUploadRequest() async throws {
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
    let expected = try! JSONDecoder().decode([Uploaded].self, from: sampleResponse.data(using: .utf8)!)
    let fetcher = TestFetcher()
    fetcher.dummyResponseString = sampleResponse
    fetcher.expectedPathname = "/upload"
    fetcher.expectedMethod = "POST"
    
    let uploadRequest = UploadRequest(file: MultipartData(data: "test".data(using: .utf8)!, name: "files", fileName: "somefile", mimeType: "image/jpeg"))
    
    let actual = try await API(fetcher:fetcher).fetch(uploadRequest)
    XCTAssertEqual(actual.first!.id, expected.first!.id)
  }
  
  func testPostRequest () async throws {
    let sampleResponse = """
{
    "id": 3,
    "title": "Second public post",
    "body": "The first mate and his Skipper too will do their very best to make the others comfortable in their tropic island nest. Michael Knight a young loner on a crusade to champion the cause of the innocent. The helpless. The powerless in a world of criminals who operate above the law. Here he comes Here comes Speed Racer. He's a demon on wheels.",
    "author": {
      "id": 1,
      "username": "nicop",
      "email": "nico.prananta@gmail.com",
      "provider": "local",
      "confirmed": true,
      "blocked": null,
      "role": 1,
      "created_at": "2021-09-30T20:03:50.296Z",
      "updated_at": "2021-09-30T20:03:50.304Z"
    },
    "createdAt": "2021-09-30T20:41:29.706Z",
    "private": false,
    "published_at": "2021-09-30T20:41:29.706Z",
    "created_at": "2021-09-30T20:41:29.710Z",
    "updated_at": "2021-09-30T20:41:29.715Z"
  }
"""
    let expected = try! JSONDecoder().decode(Post.self, from: sampleResponse.data(using: .utf8)!)
    let fetcher = TestFetcher()
    fetcher.dummyResponseString = sampleResponse
    fetcher.expectedPathname = "/posts/3"
    
    let actual = try await API(fetcher:fetcher).fetch(PostRequest(postId: 3))
    XCTAssertEqual(actual, expected)
  }
}
