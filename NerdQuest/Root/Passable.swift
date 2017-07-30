//
//  Passable.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/28/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

protocol Passable {
  var nerdService: NerdService! { get set }
  var battlingService: Battling! { get set }
}
