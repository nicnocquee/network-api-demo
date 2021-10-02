//
//  Alamofire+Extensions.swift
//  NetworkAPIDemo
//
//  Created by Nico Prananta on 02.10.21.
//

import Foundation
import Alamofire

extension Request {
  public func debugLog() -> Self {
#if DEBUG
    cURLDescription(calling: { (curl) in
      debugPrint("=======================================")
      print(curl)
      debugPrint("=======================================")
    })
#endif
    return self
  }
}
