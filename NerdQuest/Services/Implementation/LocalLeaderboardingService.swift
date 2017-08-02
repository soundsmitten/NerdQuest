//
//  LocalLeaderboardingService.swift
//  NerdQuest
//
//  Created by Nicholas Lash on 7/30/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

class LocalLeaderboardingService: Leaderboarding {
  var leaderboard: [NerdPlayer]! = [NerdPlayer]()
  private var isLeaderboardRunning = false
  
  func setupLeaderboard(completion: @escaping ([NerdPlayer]?, Error?) -> Void) {
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] (timer) in
      guard let this = self else {
        return
      }
      if !this.isLeaderboardRunning {
        this.getLeaderboard(completion: completion)
      }
    }.fire()
  }
  
  private func getLeaderboard(completion: @escaping ([NerdPlayer]?, Error?) -> Void) {
    isLeaderboardRunning = true
    let resource = NerdLeaderboardResource()
    let request = NerdNetworkRequest(resource: resource)
    var urlRequest = URLRequest(url: resource.url)
    urlRequest.httpMethod = resource.httpMethod.rawValue
    urlRequest.addValue(UserDefaults.standard.string(forKey: "apikey")!, forHTTPHeaderField: "apikey")
    
    request.makeRequest(urlRequest: urlRequest, completion: { players, error in
      let when = DispatchTime.now() + AppConstants.kMiningInterval
      DispatchQueue.main.asyncAfter(deadline: when, execute: {
        self.isLeaderboardRunning = false
        if let players = players {
          self.leaderboard = players ?? []
          completion(players, error)
        } else {
          self.leaderboard = []
          completion(nil, error)
        }
      })
    })
  }
}
