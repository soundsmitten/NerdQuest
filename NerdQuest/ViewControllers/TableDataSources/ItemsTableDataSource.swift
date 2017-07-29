//
//  ItemsTableDataSource.swift
//  NerdQuest
//
//  Created by Nicholas Lash on 7/29/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Cocoa

class ItemsTableDataSource: NSObject {
  var annotatedItems = [AnnotatedItem]()
  
  enum Identifiers: String {
    case name = "itemName"
    case itemType = "itemType"
    case effect = "itemEffect"
    case duration = "itemDuration"
    case rarity = "itemRarity"
    case id = "itemID"
  }
}

extension ItemsTableDataSource: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard
      let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifiers.kItemCellIdentifier), owner: nil) as? NSTableCellView,
      let tableColumn = tableColumn,
      let columnIdentifier = Identifiers(rawValue: tableColumn.identifier.rawValue) else {
        return nil
    }
    
    let annotatedItem = annotatedItems[row]
    var cellText = ""
    
    switch columnIdentifier {
    case .name:
      cellText = annotatedItem.item.name
    case .itemType:
      cellText = annotatedItem.annotation?.itemType.text ?? "Unknown"
    case .effect:
      cellText = annotatedItem.annotation?.effect ?? "Unknown"
    case .duration:
      cellText = annotatedItem.annotation?.duration ?? "Unknown"
    case .rarity:
      cellText = "\(annotatedItem.item.rarity)"
    case .id:
      cellText = "\(annotatedItem.item.id)"
    }
    cell.textField?.stringValue = cellText
    return cell
  }
  
  func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
    return 20.0
  }
}

extension ItemsTableDataSource: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return annotatedItems.count
  }
}
