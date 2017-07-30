//
//  BattlingMessagesDataSource.swift
//  NerdQuest
//
//  Created by Nicholas Lash on 7/30/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Cocoa

class BattlingMessagesTableDataSource: NSObject {
  var messages = [String]()
}

extension BattlingMessagesTableDataSource: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifiers.kBattlingMessageCellIdentifier), owner: nil) as? NSTableCellView else {
      return nil
    }
    cell.textField?.stringValue = messages[row]
    return cell
  }
  
  func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
    return 20.0
  }
}

extension BattlingMessagesTableDataSource: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return messages.count
  }
}

