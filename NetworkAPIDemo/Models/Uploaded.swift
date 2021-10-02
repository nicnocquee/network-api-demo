//
//  Uploaded.swift
//  NetworkAPIDemo
//
//  Created by Nico Prananta on 01.10.21.
//

import Foundation

struct Uploaded: Codable, Equatable {
  let id: Int
  let url, name: String
  let width, height, size: Double
}
