//
//  User.swift
//  NetworkAPIDemo
//
//  Created by Nico Prananta on 30.09.21.
//

import Foundation

struct User: Codable, Equatable {
  let id: Int
  let username, email: String
}
