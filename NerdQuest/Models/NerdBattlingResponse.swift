//
//  NerdBattlingResponse.swift
//  NerdQuest
//
//  Created by Nicholas Lash on 7/30/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
// Models:
//{"Messages":["You used <Blind Date> on nlash; -2 points for nlash!"],"TargetName":"nlash","Points":7150}

import Foundation

struct NerdBattlingResponse: Codable {
  let messages: [String]
  
  enum CodingKeys: String, CodingKey {
    case messages = "Messages"
  }
}
