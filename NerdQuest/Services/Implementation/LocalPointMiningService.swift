//
//  LocalPointMiningService.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/27/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

class LocalPointMiningService: PointMining {
  var isMining = false
  private var isMiningRunning = false
  
  func setupMining(completion: @escaping (NerdPoint?, Error?) -> Void) {    
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
      guard let this = self else {
        return
      }
      if this.isMining && !this.isMiningRunning {
      this.mine(completion: completion)
      }
    }.fire()
  }
  
  func startMining() {
    let when = DispatchTime.now() + AppConstants.kMiningInterval
    DispatchQueue.main.asyncAfter(deadline: when, execute: { [weak self] in
      self?.isMining = true
    })
  }
  
  func stopMining() {
    isMining = false
  }
  
  private func mine(completion: @escaping (NerdPoint?, Error?) -> Void) {
    isMiningRunning = true
    let resource = NerdPointResource()
    let request = NerdNetworkRequest(resource: resource)
    
    var urlRequest = URLRequest(url: resource.url)
    urlRequest.httpMethod = resource.httpMethod.rawValue
    urlRequest.addValue(UserDefaults.standard.string(forKey: UserDefaultsKey.kAPIKey)!, forHTTPHeaderField: HTTPHeaderKey.kAPIKey)
    
    request.makeRequest(urlRequest: urlRequest, completion: { nerdPoint, error in
      let when = DispatchTime.now() + AppConstants.kMiningInterval
      DispatchQueue.main.asyncAfter(deadline: when, execute: {
        self.isMiningRunning = false
        if let nerdPoint = nerdPoint {
          print("pointsMessage = \(String(describing: nerdPoint?.messages.joined()))")
          completion(nerdPoint, error)
        } else {
          completion(nil, error)
        }
      })
    })
  }
}
