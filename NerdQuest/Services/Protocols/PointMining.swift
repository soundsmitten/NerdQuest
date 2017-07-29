//
//  PointMining.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/27/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

protocol PointMining {
  func startMining(completion: @escaping (NerdPoint?) -> Void)
  func stopMining()
}
