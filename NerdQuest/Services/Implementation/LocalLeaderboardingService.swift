//
//  LocalLeaderboardingService.swift
//  NerdQuest
//
//  Created by Nicholas Lash on 7/30/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

class LocalLeaderboardingService: Leaderboarding {
  private var isLeaderboardRunning = false
  
  func setupLeaderboard(completion: @escaping ([NerdPlayer]?) -> Void) {
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] (timer) in
      guard let this = self else {
        return
      }
      if !this.isLeaderboardRunning {
        this.getLeaderboard(completion: completion)
      }
    }.fire()
  }
  
  private func getLeaderboard(completion: @escaping ([NerdPlayer]?) -> Void) {
    isLeaderboardRunning = true
    let resource = NerdLeaderboardResource()
    let request = NerdNetworkRequest(resource: resource)
    var urlRequest = URLRequest(url: resource.url)
    urlRequest.httpMethod = resource.httpMethod.rawValue
    urlRequest.addValue(UserDefaults.standard.string(forKey: "apikey")!, forHTTPHeaderField: "apikey")
    
    request.makeRequest(urlRequest: urlRequest, completion: { players in
      let when = DispatchTime.now() + AppConstants.kMiningInterval
      DispatchQueue.main.asyncAfter(deadline: when, execute: {
        self.isLeaderboardRunning = false
        if let players = players {
          completion(players)
        } else {
          completion(nil)
        }
      })
    })
  }
}
