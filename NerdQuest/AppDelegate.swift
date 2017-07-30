//
//  AppDelegate.swift
//  NerdQuest
//
//  Created by Nicholas Lash on 7/27/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  var window: NSWindow!
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
//    UserDefaults.standard.set(nil, forKey: "apikey") // uncomment reset the api key if you fucked up putting it in
    let nerdService = NerdService(sanityCheckingService: MacOSSanityCheckingService(),
                                  pointMiningService: LocalPointMiningService(),
                                  itemSavingService: LocalItemSavingService(),
                                  leaderboardingService: LocalLeaderboardingService())
    
    let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: StoryboardNames.kMain), bundle: nil)
    guard
      let mainWindowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: ViewControllerIdentifiers.kMainWindowController)) as? MainWindowController,
      let mainViewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: ViewControllerIdentifiers.kMainViewController)) as? MainViewController else {
        return
    }
    
    window = mainWindowController.window
    mainViewController.nerdService = nerdService
    mainWindowController.contentViewController = mainViewController
    window.makeKeyAndOrderFront(nil)
    
  }
  
  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
}

