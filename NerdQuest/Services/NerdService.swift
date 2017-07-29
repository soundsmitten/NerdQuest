//
//  NerdService.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/28/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

class NerdService {
  var sanityCheckingService: SanityChecking!
  var pointMiningService: PointMining!
  var itemSavingService: ItemSaving!

  init(sanityCheckingService: SanityChecking, pointMiningService: PointMining, itemSavingService: ItemSaving) {
    self.sanityCheckingService = sanityCheckingService
    self.pointMiningService = pointMiningService
    self.itemSavingService = itemSavingService
  }
}
