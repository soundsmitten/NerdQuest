//
//  FriendOrFoeViewController.swift
//  NerdQuest
//
//  Created by Nicholas Lash on 7/31/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Cocoa

class FriendOrFoeViewController: NSViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    textField.becomeFirstResponder()
  }
  
  @IBOutlet weak var textField: NSTextField!
  @IBOutlet weak var resultField: NSTextField!
  
  @IBAction func queryButtonTapped(sender: NSButton) {
    let username = textField.stringValue
    if Nerds.kWhiteList.contains(username) {
      resultField.stringValue = "\(username) is a friend"
    } else {
      resultField.stringValue = "\(username) is an enemy"
    }
  }
}
