//
//  Leaderboarding.swift
//  NerdQuest
//
//  Created by Nicholas Lash on 7/30/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

protocol Leaderboarding {
  func setupLeaderboard(completion: @escaping ([NerdPlayer]?) -> Void)
}
