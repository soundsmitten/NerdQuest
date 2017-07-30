//
//  Item.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/27/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
// Models:
// {"Description":"Maybe edible mushroom.","Name":"Mushroom","Rarity":1,"Id":"ac05829b-94b3-4051-9be5-9f3c9a2f1146"}

import Foundation

struct NerdItem: Codable {
  let name: String
  let itemDescription: String
  let id: String
  let rarity: Int
  
  // client-added properties
  var dateAdded: Int = Int(Date().timeIntervalSince1970)
  var isUsed: Bool = false


  enum CodingKeys: String, CodingKey {
    case name = "Name"
    case itemDescription = "Description"
    case id = "Id"
    case rarity = "Rarity"
  }
}
