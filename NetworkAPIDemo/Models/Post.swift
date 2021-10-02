//
//  Post.swift
//  NetworkAPIDemo
//
//  Created by Nico Prananta on 30.09.21.
//

import Foundation

struct Post: Codable, Equatable {
  var id: Int
  var title: String
  var body: String
  var author: User?
}
