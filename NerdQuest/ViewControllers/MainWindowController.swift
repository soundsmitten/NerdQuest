//
//  MainWindowController.swift
//  NerdQuest
//
//  Created by Nicholas Lash on 7/29/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
  var battlingService: Battling!
  var nerdService: NerdService!
  override func windowDidLoad() {
    super.windowDidLoad()
    guard let mainViewController = contentViewController as? MainViewController else {
      return
    }
    mainViewController.nerdService = nerdService
    mainViewController.battlingService = battlingService
  }

}
