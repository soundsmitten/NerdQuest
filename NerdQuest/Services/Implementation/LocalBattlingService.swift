//
//  LocalBattlingService.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/28/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation


class LocalBattlingService: Battling {
  var counter: Int = 0
  var buffPercentage: Int!
  private var nerdService: NerdService!
  private var isBattling: Bool = false
  private var isBattlingRunning: Bool = false
  private var itemBuffer = [IDWithTarget]()
  private var timer: Timer?

  required init(nerdService: NerdService) {
    self.nerdService = nerdService
  }
  
  func setupBattling(completion: @escaping (NerdBattlingResponse?) -> Void) {
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
      guard let this = self else {
        return
      }
      if this.isBattling && !this.isBattlingRunning {
        this.battle(completion: completion)
      }
      if !this.isBattling && this.counter == 0 {
        timer.invalidate()
      }
    }.fire()
  }
  
  private func battle(completion: @escaping (NerdBattlingResponse?) -> Void) {
    isBattlingRunning = true
    
    if let queuedItem = dequeue() {
      useItem(idWithTarget: queuedItem, completion: completion)
    } else {
      useRandomItem(completion: completion)
    }
  }
  
  func startBattling() {
    isBattling = true
  }
  
  func stopBattling() {
    isBattling = false
  }
  
  func enqueue(_ idWithTarget: IDWithTarget) {
    itemBuffer.append(idWithTarget)
  }
  
  func dequeue() -> IDWithTarget? {
    guard !bufferIsEmpty() else {
      return nil
    }
    let lastItem = itemBuffer.last
    itemBuffer = Array<IDWithTarget>(itemBuffer.dropLast())
    return lastItem
  }
  
  func bufferIsEmpty() -> Bool {
    return itemBuffer.count == 0
  }
  
  func useRandomItem(completion: @escaping (NerdBattlingResponse?) -> Void) {
    let randomNumber = arc4random_uniform(UInt32(100)) + 1
    var itemTypeToUse: ItemType = randomNumber <= buffPercentage ? .buff : .weapon
    var randomItem = nerdService.itemSavingService.getRandomItem(itemType: itemTypeToUse)
    
    if randomItem == nil {
      itemTypeToUse = itemTypeToUse == .buff ? .weapon : .buff
      randomItem = nerdService.itemSavingService.getRandomItem(itemType: itemTypeToUse)
    }
    
    guard let unwrappedRandomItem = randomItem else {
      completion(nil)
      return
    }
    
    guard let target = getTarget(itemTypeToUse: itemTypeToUse) else {
      completion(nil)
      return
    }
    
    let idWithTarget: IDWithTarget = (unwrappedRandomItem.item.id, target)
    useItem(idWithTarget: idWithTarget, completion: { (nerdBattlingResponse) in
      print("used item \(unwrappedRandomItem.item.name) on \(target)")
      completion(nerdBattlingResponse)
    })
  }

  func getTarget(itemTypeToUse: ItemType) -> String? {
    guard itemTypeToUse == .weapon else {
      return Nerds.kMe
    }
    
    guard nerdService.leaderboardingService.leaderboard.count > 0 else {
      return nil
    }
    let enemies = nerdService.leaderboardingService.leaderboard.filter({ player in
      return self.isEnemy(player: player.name)
    })
    guard enemies.count > 0 else {
      return nil
    }
    let index = Int(arc4random_uniform(UInt32(enemies.count)))
    return enemies[index].name
  }
  
  func useItem(idWithTarget: IDWithTarget, completion: @escaping (NerdBattlingResponse?) -> Void) {
    let resource = NerdBattlingResource()
    let request = NerdNetworkRequest(resource: resource)
    let itemID = idWithTarget.0
    let target = idWithTarget.1
    let url = resource.url.appendingPathComponent(itemID)
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = resource.httpMethod.rawValue
    urlRequest.addValue(UserDefaults.standard.string(forKey: UserDefaultsKey.kAPIKey)!, forHTTPHeaderField: HTTPHeaderKey.kAPIKey)
    urlRequest.addValue(target, forHTTPHeaderField: HTTPHeaderKey.kTarget)
    request.makeRequest(urlRequest: urlRequest, completion: { nerdBattlingResponse in
      self.startItemTimer()
      let when = DispatchTime.now() + AppConstants.kBattlingInterval
      DispatchQueue.main.asyncAfter(deadline: when, execute: {
        self.isBattlingRunning = false
        if let nerdBattlingResponse = nerdBattlingResponse {
          completion(nerdBattlingResponse)
        } else {
          completion(nil)
        }
      })
    })
  }
  
  private func startItemTimer() {
    guard timer == nil else {
      return
    }
    counter = 60
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
      guard let this = self else {
        return
      }
      this.counter = this.counter == 0 ? 60 : this.counter - 1
    }
    timer?.fire()
  }
  
  private func stopItemTimer() {
    counter = 0
    timer?.invalidate()
    timer = nil
  }
}
