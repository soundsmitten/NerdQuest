//
//  PointsResponse.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/27/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
// Models:
// {"Messages":["nlash gained 1 points! Total points: 678"],"Item":null,"Points":678,"Effects":[],"Badges":[]}

import Foundation

struct NerdPoint: Codable {
  let badges: [NerdBadge]
  let effects: [String]
  let points: Int
  let item: NerdItem?
  let messages: [String]
  
  enum CodingKeys: String, CodingKey {
    case badges = "Badges"
    case effects = "Effects"
    case points = "Points"
    case item = "Item"
    case messages = "Messages"
  }
}
