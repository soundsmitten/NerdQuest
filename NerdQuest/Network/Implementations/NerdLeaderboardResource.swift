//
//  NerdLeaderboardResource.swift
//  NerdQuest
//
//  Created by Nicholas Lash on 7/29/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

struct NerdLeaderboardResource: ApiResource {
  var methodPath = "/"
  var httpMethod = NerdHTTPMethod.get
  func makeModel(data: Data) -> [NerdPlayer]? {
    guard let model = try? JSONDecoder().decode(Array<NerdPlayer>.self, from: data) else {
      return nil
    }
    return model
  }
}
