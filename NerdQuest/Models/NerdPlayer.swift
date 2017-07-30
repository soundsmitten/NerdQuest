//
//  NerdPlayer.swift
//  NerdQuest
//
//  Created by Nicholas Lash on 7/29/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
// Models:
//{
//  "PlayerName": "jprice",
//  "AvatarUrl": "https://lh5.googleusercontent.com/-biUrJ4DVluQ/AAAAAAAAAAI/AAAAAAAAA9o/XmYvf96PtSE/photo.jpg",
//  "Points": 125513,
//  "Title": "Everyone's coach",
//  "Effects": [
//  "Slow"
//  ],
//  "Badges": [
//  {
//  "BadgeName": "Pony"
//  },
//  {
//  "BadgeName": "Core Value: Empowerment"
//  }
//  ],
//  "HasActiveQuest": false,
//  "ClassName": "Superheroine",
//  "ClassLevel": 1,
//  "PointsAsString": "125,513"
//}


import Foundation

struct NerdPlayer: Codable {
  let name: String
  let points: Int
  
  enum CodingKeys: String, CodingKey {
    case name = "PlayerName"
    case points = "Points"
  }
}
