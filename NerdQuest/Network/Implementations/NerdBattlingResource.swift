//
//  NerdBattlingResource.swift
//  NerdQuest
//
//  Created by Nicholas Lash on 7/30/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

struct NerdBattlingResource: ApiResource {
  var methodPath = "/items/use/"
  var httpMethod = NerdHTTPMethod.post
  func makeModel(data: Data) -> NerdBattlingResponse? {
    guard let model = try? JSONDecoder().decode(NerdBattlingResponse.self, from: data) else {
      return nil
    }
    return model
  }
}
