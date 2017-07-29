//
//  NerdResource.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/27/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

struct NerdPointResource: ApiResource {
  var methodPath = "/points"
  var httpMethod = NerdHTTPMethod.post
  func makeModel(data: Data) -> NerdPoint? {
    guard let model = try? JSONDecoder().decode(NerdPoint.self, from: data) else {
      return nil
    }
    return model
  }
}
