//
//  NerdBadge.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/28/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

struct NerdBadge: Codable {
  let name: String
  
  enum CodingKeys: String, CodingKey {
    case name = "BadgeName"
  }
}
