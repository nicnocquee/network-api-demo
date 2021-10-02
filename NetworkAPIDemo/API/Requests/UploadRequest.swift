//
//  UploadRequest.swift
//  NetworkAPIDemo
//
//  Created by Nico Prananta on 30.09.21.
//

import Foundation
import Alamofire

struct UploadRequest: APIRequest {
  typealias Response = [Uploaded]
  var pathname: String { "/upload" }
  var multipartData: [MultipartData]? {
    [file]
  }
  
  let file: MultipartData
}
