//
//  ManualLaunchViewController.swift
//  NerdQuest
//
//  Created by Nicholas Lash on 7/30/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Cocoa

protocol ManualLaunchAddedToQueue {
  func manualLaunchAddedToQueue()
}

class ManualLaunchViewController: NSViewController {
  @IBOutlet weak var itemNameField: NSTextField!
  @IBOutlet weak var itemIDField: NSTextField!
  @IBOutlet weak var targetField: NSTextField!
  
  var battlingService: Battling!
  var nerdService: NerdService!
  var delegate: ManualLaunchAddedToQueue?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
  }
  
  @IBAction func launchButtonTapped(sender: Any) {
    guard
      let _ = sender as? NSButton,
      validateFields() else {
        return
    }
    let nerdItem = NerdItem(name: itemNameField.stringValue, itemDescription: "Manually launched", id: itemIDField.stringValue, rarity: -1, dateAdded: Int(Date().timeIntervalSince1970), isUsed: false)
    nerdService.itemSavingService.saveItem(nerdItem: nerdItem)
    battlingService.enqueue((AppConstants.kManualLaunchName, itemIDField.stringValue, targetField.stringValue))
    print("target \(targetField.stringValue)")
    print("id: \(itemIDField.stringValue)")
      
    itemIDField.stringValue = ""
    targetField.stringValue = ""
    delegate?.manualLaunchAddedToQueue()
  }
  
  func validateFields() -> Bool {
    return itemIDField.stringValue.count > 0 && targetField.stringValue.count > 0
  }
}
