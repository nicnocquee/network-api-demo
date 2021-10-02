//
//  AlamofireFetcher.swift
//  NetworkAPIDemo
//
//  Created by Nico Prananta on 01.10.21.
//

import Foundation
import Alamofire

class AlamofireFetcher: FetchCapable {
  let session: Session
  
  init(session: Session = AF) {
    self.session = session
  }
  
  func fetch<ResponseType>(request: URLRequest,
                           decodeTo: ResponseType.Type) async throws -> ResponseType where ResponseType: Decodable {
    let afRequest = session.request(request).debugLog().validate()
    return try await withCheckedThrowingContinuation({ continuation in
      afRequest.responseDecodable(of: ResponseType.self) { response in
        switch response.result {
        case .success(let decodedResponse):
          continuation.resume(returning: decodedResponse)
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    })
  }
  
  func upload<ResponseType>(multipart: [MultipartData],
                            toURL: String,
                            decodeTo: ResponseType.Type,
                            headers: HTTPHeaders?) async throws -> ResponseType where ResponseType: Decodable {
    return try await withCheckedThrowingContinuation({ continuation in
      session.upload(multipartFormData: { multipartFormData in
        for multi in multipart {
          multipartFormData.append(multi.data,
                                   withName: multi.name,
                                   fileName: multi.fileName,
                                   mimeType: multi.mimeType
          )
        }
      },
                to: toURL,
                headers: headers)
        .debugLog()
        .validate()
        .responseDecodable(of: ResponseType.self) { response in
          switch response.result {
          case .success(let decodedResponse):
            continuation.resume(returning: decodedResponse)
          case .failure(let error):
            continuation.resume(throwing: error)
          }
          
        }
    })
  }
}
