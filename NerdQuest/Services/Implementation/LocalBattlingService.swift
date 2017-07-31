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
  var itemBuffer = [NameAndIDWithTarget]()
  private var timer: Timer?
  var delegate: BattlingActionDidOccurDelegate?

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
    }.fire()
  }
  
  private func battle(completion: @escaping (NerdBattlingResponse?) -> Void) {
    isBattlingRunning = true
    
    if let queuedItem = dequeue() {
      useItem(nameAndIDWithTarget: queuedItem, completion: completion)
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
  
  func enqueue(_ nameAndIDWithTarget: NameAndIDWithTarget) {
    itemBuffer.append(nameAndIDWithTarget)
  }
  
  func dequeue() -> NameAndIDWithTarget? {
    guard !bufferIsEmpty() else {
      return nil
    }
    let firstItem = itemBuffer.first
    itemBuffer = Array<NameAndIDWithTarget>(itemBuffer.dropFirst())
    return firstItem
  }
  
  func remove(_ itemID: String) {
    itemBuffer = itemBuffer.filter {
      $0.1 != itemID
    }
  }
  
  func bufferIsEmpty() -> Bool {
    return itemBuffer.count == 0
  }
  
  func useRandomItem(completion: @escaping (NerdBattlingResponse?) -> Void) {
    let randomNumber = arc4random_uniform(UInt32(100))
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
    
    let idWithTarget: NameAndIDWithTarget = (unwrappedRandomItem.item.name, unwrappedRandomItem.item.id, target)
    useItem(nameAndIDWithTarget: idWithTarget, completion: { (nerdBattlingResponse) in
      completion(nerdBattlingResponse)
    })
  }
  
  func getTarget(itemTypeToUse: ItemType) -> String? {
    guard canUse(itemType: itemTypeToUse) else {
      return nil
    }
    
    guard itemTypeToUse == ItemType.weapon else {
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
  
  private func canUse(itemType: ItemType) -> Bool {
    return itemType == .weapon || itemType == .buff
  }
  
  func useItem(nameAndIDWithTarget: NameAndIDWithTarget, completion: @escaping (NerdBattlingResponse?) -> Void) {
    let itemName = nameAndIDWithTarget.0
    let itemID = nameAndIDWithTarget.1
    let target = nameAndIDWithTarget.2
    
    guard !nerdService.itemSavingService.isItemUsed(itemID: itemID) || itemName == AppConstants.kManualLaunchName else {
      print("Item already used")
      completion(nil)
      return
    }
    
    let resource = NerdBattlingResource()
    let request = NerdNetworkRequest(resource: resource)
    var url = resource.url.appendingPathComponent(itemID)
    let urlString = url.absoluteString + "?target=\(target)"
    url = URL(string: urlString)!
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = resource.httpMethod.rawValue
    urlRequest.addValue(UserDefaults.standard.string(forKey: UserDefaultsKey.kAPIKey)!, forHTTPHeaderField: HTTPHeaderKey.kAPIKey)
    urlRequest.addValue(target, forHTTPHeaderField: HTTPHeaderKey.kTarget)
    request.makeRequest(urlRequest: urlRequest, completion: { [weak self] nerdBattlingResponse in
      guard let this = self else {
        completion(nil)
        return
      }
      if let nerdBattlingResponse = nerdBattlingResponse {
        this.nerdService.itemSavingService.useItem(itemID: itemID)
        completion(nerdBattlingResponse)
      }
      this.startItemTimer()
      let when = DispatchTime.now() + AppConstants.kBattlingInterval
      DispatchQueue.main.asyncAfter(deadline: when, execute: {
        this.isBattlingRunning = false
        this.counter = 60
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
}
