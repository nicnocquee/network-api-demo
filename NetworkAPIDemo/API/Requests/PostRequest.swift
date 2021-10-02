//
//  PostRequest.swift
//  NetworkAPIDemo
//
//  Created by Nico Prananta on 30.09.21.
//

import Foundation
import Alamofire

struct PostRequest: APIRequest {
  typealias Response = Post
  
  let postId: Int
  var pathname: String { "/posts/\(postId)" }
}

struct PostsRequest: APIRequest {
  var pathname: String { "/posts" }
  typealias Response = [Post]
}

struct NewPostRequest: APIRequest {
  typealias Response = Post
  var pathname: String { "/posts" }
  var method: HTTPMethod { .post }
  let newPost: Post
  var body: Post? { newPost }
}
