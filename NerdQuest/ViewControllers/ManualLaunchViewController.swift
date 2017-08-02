//
//  ManualLaunchViewController.swift
//  NerdQuest
//
//  Created by Nicholas Lash on 7/30/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Cocoa

class ManualLaunchViewController: NSViewController {
  @IBOutlet weak var itemNameField: NSTextField!
  @IBOutlet weak var itemIDField: NSTextField!
  @IBOutlet weak var targetField: NSTextField!
  
  var battlingService: Battling!
  var nerdService: NerdService!
  var delegate: AddedToQueue?
  
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
    nerdService.itemSavingService.saveItem(nerdItem: nerdItem, completion: { [weak self] success in
      guard let this = self else {
        return ()
      }
      this.battlingService.enqueue((this.itemNameField.stringValue, this.itemIDField.stringValue, this.targetField.stringValue))
      print("target \(this.targetField.stringValue)")
      print("id: \(this.itemIDField.stringValue)")
      
      this.itemIDField.stringValue = ""
      this.targetField.stringValue = ""
      this.itemNameField.stringValue = ""
      
      this.delegate?.addedToQueue()
    })
  }
  
  func validateFields() -> Bool {
    return itemIDField.stringValue.count > 0 && targetField.stringValue.count > 0
  }
}
