//
//  LoginRequest.swift
//  NetworkAPIDemo
//
//  Created by Nico Prananta on 30.09.21.
//

import Foundation
import Alamofire

struct LoginData: Codable {
  let identifier: String
  let password: String
}

struct LoginRequest: APIRequest {
  typealias Response = AuthData
  
  var pathname: String { "/auth/local" }
  var method: HTTPMethod { .post }
  
  let loginData: LoginData
  var body: LoginData? { loginData }
}
