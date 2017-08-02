//
//  AddToQueueViewController.swift
//  NerdQuest
//
//  Created by Nicholas Lash on 8/1/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Cocoa

protocol AddedToQueue {
  func addedToQueue()
}

class AddToQueueViewController: NSViewController {
  var nameAndID: NameAndID!
  var battlingService: Battling!
  
  var delegate: AddedToQueue?

  @IBOutlet weak var targetField: NSTextField!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.window?.title = nameAndID.0
    // Do view setup here.
  }
  
  @IBAction func addToQueue(sender: NSButton) {
    guard targetField.stringValue.count > 0 else {
      return
    }
    let nameAndIDWithTarget = (nameAndID.0, nameAndID.1, targetField.stringValue)
    battlingService.enqueue(nameAndIDWithTarget)
    delegate?.addedToQueue()
    view.window?.close()
  }
}
