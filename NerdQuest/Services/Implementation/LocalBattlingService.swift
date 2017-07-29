//
//  LocalBattlingService.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/28/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

class LocalBattlingService: Battling {
  private var isBattling: Bool = false
  func startBattling() {
    isBattling = true
    print("Doing battle")
  }
  func stopBattling() {
    isBattling = false
  }
}
