//
//  AccessTokenProvider.swift
//  NetworkAPIDemo
//
//  Created by Nico Prananta on 02.10.21.
//

import Foundation

class AccessTokenProvider: AuthProvider {
  private static var token: String?
  
  func accessToken() async -> String? {
    // maybe get from keychain first
    AccessTokenProvider.token
  }
  
  func setAccessToken(_ token: String?) async {
    // save to keychain
    AccessTokenProvider.token = token
  }
  
  func refreshToken() async {
    // refresh the token if needed
    // then set the new token
  }
}
