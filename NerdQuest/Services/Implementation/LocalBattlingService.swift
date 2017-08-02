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
  
  func setupBattling(completion: @escaping (NerdBattlingResponse?, Error?) -> Void) {
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
      guard let this = self else {
        return
      }
      if this.isBattling && !this.isBattlingRunning {
        this.battle(completion: completion)
      }
    }.fire()
  }
  
  private func battle(completion: @escaping (NerdBattlingResponse?, Error?) -> Void) {
    isBattlingRunning = true
    
    if let queuedItem = itemBuffer.first {
      useItem(nameAndIDWithTarget: queuedItem, inBuffer: true, completion: completion)
    } else {
      let itemTypeToUse = getRandomItemType()
      useRandomItem(itemType: itemTypeToUse) { resp, error in
        completion(resp, error)
      }
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
  
  @discardableResult
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
  
  func useRandomItem(itemType: ItemType, completion: @escaping (NerdBattlingResponse?, Error?) -> Void) {
    nerdService.itemSavingService.getRandomItem(itemType: itemType) { [weak self] randomItem in
      guard
        let this = self,
        let randomItem = randomItem else {
        completion(nil,nil)
        return
      }
      
      guard let target = this.getTarget(itemTypeToUse: itemType) else {
        completion(nil,nil)
        return
      }
      
      let idWithTarget: NameAndIDWithTarget = (randomItem.item.name, randomItem.item.id, target)
      this.useItem(nameAndIDWithTarget: idWithTarget, inBuffer: false, completion: { nerdBattlingResponse, error in
        completion(nerdBattlingResponse, error)
      })
    }
  }

  func getRandomItemType() -> ItemType {
    let randomNumber = arc4random_uniform(UInt32(100))
    let itemTypeToUse: ItemType = randomNumber <= buffPercentage ? .buff : .weapon
    return itemTypeToUse
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
  
  func useItem(nameAndIDWithTarget: NameAndIDWithTarget, inBuffer: Bool, completion: @escaping (NerdBattlingResponse?, _ error: Error?) -> Void) {
    let itemName = nameAndIDWithTarget.0
    let itemID = nameAndIDWithTarget.1
    let target = nameAndIDWithTarget.2
    
    nerdService.itemSavingService.isItemUsed(itemID: itemID) { [weak self] isUsed in
      guard let this = self else {
        completion(nil, nil)
        return
      }
      
      guard !isUsed else {
        print("Item already used")
        completion(nil, nil)
        if inBuffer {
          this.dequeue()
        }
        this.isBattlingRunning = false
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
      request.makeRequest(urlRequest: urlRequest, completion: {nerdBattlingResponse, error in
        this.wait()
        if let nerdBattlingResponse = nerdBattlingResponse {
          DispatchQueue.main.async {
            this.nerdService.itemSavingService.useItem(itemID: itemID) { success in
              guard success else {
                completion(nerdBattlingResponse, error)
                return
              }
              
              if inBuffer {
                this.dequeue()
              }
              this.startItemTimer()
              completion(nerdBattlingResponse, error)
            }
          }
        }
      })
    }
  }
  
  private func wait() {
    let when = DispatchTime.now() + AppConstants.kBattlingInterval
    DispatchQueue.main.asyncAfter(deadline: when, execute: { [weak self] in
      self?.isBattlingRunning = false
      self?.counter = 60
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
