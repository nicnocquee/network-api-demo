//
//  API.swift
//  NetworkAPIDemo
//
//  Created by Nico Prananta on 29.09.21.
//

import Foundation

import Alamofire
import SwiftUI

let BASE_URL = "http://localhost:1337"

struct EmptyResponse: Codable {}
struct EmptyBody: Codable {}

protocol APIRequest {
  associatedtype RequestData: Codable
  associatedtype Response: Codable
  
  var pathname: String { get }
  var method: HTTPMethod { get }
  var body: RequestData? { get }
  var multipartData: [MultipartData]? { get }
  var contentType: String { get }
}

extension APIRequest {
  typealias Response = EmptyResponse
  
  var method: HTTPMethod { .get }
  var body: EmptyBody? { nil }
  var multipartData: [MultipartData]? { nil }
  var contentType: String { "application/json" }
}

struct MultipartData {
  var data: Data
  var name: String
  var fileName: String
  var mimeType: String
}

protocol FetchCapable {
  func fetch<ResponseType: Decodable>(request: URLRequest,
                                      decodeTo: ResponseType.Type) async throws -> ResponseType
  func upload<ResponseType: Decodable>(multipart: [MultipartData],
                                       toURL: String,
                                       decodeTo: ResponseType.Type,
                                       headers: HTTPHeaders?,
                                       progress: Binding<Double>?) async throws -> ResponseType
}

protocol AuthProvider {
  func accessToken() async -> String?
  func setAccessToken(_ token: String?) async
  func refreshToken() async
}

class API<Request: APIRequest> {
  private var fetcher: FetchCapable
  private var accessTokenProvider: AuthProvider
  
  init(fetcher: FetchCapable = AlamofireFetcher(),
       accessTokenProvider: AuthProvider = AccessTokenProvider()) {
    self.fetcher = fetcher
    self.accessTokenProvider = accessTokenProvider
  }
  
  func fetch(_ request: Request, progress: Binding<Double>? = nil) async throws -> Request.Response {
    let url = "\(BASE_URL)\(request.pathname)"
    var urlRequest = URLRequest(url: URL(string: url)!)
    urlRequest.method = request.method
    urlRequest.headers.add(.contentType(request.contentType))
    
    if let token = await self.accessTokenProvider.accessToken() {
      urlRequest.headers.add(name: "Authorization", value: "Bearer \(token)")
    }
    
    if request.multipartData != nil {
      return try await self.fetcher.upload(multipart: request.multipartData!,
                                           toURL: url,
                                           decodeTo: Request.Response.self,
                                           headers: urlRequest.headers,
                                           progress: progress)
    }
    
    if request.body != nil {
      let data = try JSONEncoder().encode(request.body)
      urlRequest.httpBody = data
    }
    
    return try await self.fetcher.fetch(request: urlRequest, decodeTo: Request.Response.self)
  }
}
