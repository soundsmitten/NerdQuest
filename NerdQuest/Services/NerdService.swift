//
//  NerdService.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/28/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

protocol NerdServiceUpdates {
  func miningDidUpdate(nerdPoint: NerdPoint)
  func itemSavingDidUpdate(annotatedItems: [AnnotatedItem])
  func battlingDidUpdate(response: NerdBattlingResponse)
  func leaderboardingDidUpdate(players: [NerdPlayer])
  func networkStatusDidUpdate(message: String)
}

class NerdService {
  var updateDelegate: NerdServiceUpdates?
  private var isFirstLaunch: Bool = true
  
  var sanityCheckingService: SanityChecking!
  var pointMiningService: PointMining!
  var itemSavingService: ItemSaving!
  var leaderboardingService: Leaderboarding!
  var battlingService: Battling!

  init(sanityCheckingService: SanityChecking, pointMiningService: PointMining, itemSavingService: ItemSaving, leaderboardingService: Leaderboarding) {
    self.sanityCheckingService = sanityCheckingService
    self.pointMiningService = pointMiningService
    self.itemSavingService = itemSavingService
    self.leaderboardingService = leaderboardingService
  }
}

extension NerdService {
  func startServices() {
    itemSavingService.getAnnotatedItems { [weak self] annotatedItems in
      guard let this = self else {
        return
      }
      this.updateDelegate?.itemSavingDidUpdate(annotatedItems: annotatedItems)
      this.setupMining()
      
      self?.setupLeaderboard {
          this.setupBattling()
      }
    }
  }
  
  private func setupMining() {
    pointMiningService.startMining()
    sanityCheckingService.checkAPIKey(completion: { [weak self] in
      pointMiningService.setupMining(completion: { nerdPoint, error in
        guard let nerdPoint = nerdPoint,
          let this = self else {
            return
        }
        
        for message in nerdPoint.messages {
          this.itemSavingService.saveItemFromMessage(message: message)
        }
        this.updateDelegate?.miningDidUpdate(nerdPoint: nerdPoint)
        
        if let item = nerdPoint.item {
          this.itemSavingService.saveItem(nerdItem: item) { success in
            if success {
              this.itemSavingService.getAnnotatedItems { annotatedItems in
                this.updateDelegate?.itemSavingDidUpdate(annotatedItems: annotatedItems)
              }
            }
          }
        }
      })
    })
  }
  
  private func setupLeaderboard(completion: @escaping ()->()) {
    leaderboardingService.setupLeaderboard(completion: { [weak self] players, error in
      guard let players = players,
        let this = self else {
          return
      }
      this.updateDelegate?.leaderboardingDidUpdate(players: players)
      if this.isFirstLaunch {
        this.isFirstLaunch = false
        completion()
      }
    })
  }
  
  private func setupBattling() {
    battlingService.startBattling()
    battlingService.buffPercentage = AppConstants.kBuffPercentage
    battlingService.setupBattling { [weak self] nerdBattlingResponse, error in
      guard
        let this = self,
        let nerdBattlingResponse = nerdBattlingResponse else {
          if let error = error {
            self?.updateDelegate?.networkStatusDidUpdate(message: "\(error.localizedDescription). Error using item. Get better internet.")
          }
          return
      }
      this.updateDelegate?.networkStatusDidUpdate(message: "No connection issues.")
      
      let messages = nerdBattlingResponse.messages
      for message in messages {
        this.itemSavingService.saveItemFromMessage(message: message)
      }
      
      this.updateDelegate?.battlingDidUpdate(response: nerdBattlingResponse)
    }
  }
}
