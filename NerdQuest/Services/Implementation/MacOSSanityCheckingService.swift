//
//  MacOSSanityCheckingService.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/28/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import AppKit

class MacOSSanityCheckingService: SanityChecking {
  func checkAPIKey(completion:()->()) {
    if UserDefaults.standard.string(forKey: "apikey") == nil {
      let alert = NSAlert()
      let textField = NSTextField(frame: CGRect(x: 0, y: 0, width: 300, height: 24))
      textField.placeholderString = NSLocalizedString("API Key", comment: "")
      alert.accessoryView = textField
      alert.addButton(withTitle: NSLocalizedString("Save", comment: ""))
      alert.messageText = NSLocalizedString("No API Key provided", comment: "")
      alert.informativeText = NSLocalizedString("Please put it in this HIG-ignoring pile of shit.", comment: "")
      alert.alertStyle = .critical
      alert.runModal()
      UserDefaults.standard.set(textField.stringValue, forKey: UserDefaultsKey.kAPIKey)
    }
    completion()
  }
}
