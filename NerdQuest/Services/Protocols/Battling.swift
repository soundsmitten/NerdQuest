//
//  Battling.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/28/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

typealias NameAndIDWithTarget = (String, String, String)


protocol Battling {
  var counter: Int { get set }
  var buffPercentage: Int! {get set}
  
  init(nerdService: NerdService)
  func setupBattling(completion: @escaping (NerdBattlingResponse?) -> Void)
  func startBattling()
  func stopBattling()
  
  // itemBuffer actions
  func enqueue(_ nameAndIDWithTarget: NameAndIDWithTarget)
  func dequeue() -> NameAndIDWithTarget?
  func remove(_ itemID: String)
}

extension Battling {
  func isEnemy(player: String) -> Bool {
    return !Nerds.kWhiteList.contains(player)
  }
}
