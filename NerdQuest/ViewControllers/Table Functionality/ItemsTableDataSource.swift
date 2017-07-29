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
  var sortDescriptors = [NSSortDescriptor]()
  
  weak var tableView: NSTableView!
  
  enum ColumnInfo: String {
    case name = "itemName"
    case itemType = "itemType"
    case effect = "itemEffect"
    case duration = "itemDuration"
    case rarity = "itemRarity"
    case id = "itemID"
    
    var name: String {
      switch self {
      case .name:
        return "Name"
      case .itemType:
        return "ItemType"
      case .effect:
        return "Effect"
      case .duration:
        return "Duration"
      case .rarity:
        return "Rarity"
      case .id:
        return "ID"
      }
    }
    
    var key: String {
      switch self {
      case .name:
        return "item.name"
      case .itemType:
        return "annotation.itemType"
      case .effect:
        return "annotation.effect"
      case .duration:
        return "annotation.duration"
      case .rarity:
        return "item.rarity"
      case .id:
        return "item.id"
      }
    }
  }
  
  let columnsInfo: [ColumnInfo] = [.name, .itemType, .effect, .duration, .rarity, .id]
  
  init(tableView: NSTableView) {
    super.init()
    self.tableView = tableView
    self.tableView.dataSource = self
    self.tableView.delegate = self
    setupSortDescriptors()
  }
  
  private func setupSortDescriptors() {
    for columnInfo in columnsInfo {
      guard let column = tableView.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: columnInfo.rawValue)) else {
        continue
      }
      let sortDescriptor = NSSortDescriptor.init(key: columnInfo.rawValue, ascending: true)
      column.sortDescriptorPrototype = sortDescriptor
      sortDescriptors.append(sortDescriptor)
     }
  }
}

extension ItemsTableDataSource: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard
      let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifiers.kItemCellIdentifier), owner: nil) as? NSTableCellView,
      let tableColumn = tableColumn,
      let columnIdentifier = ColumnInfo(rawValue: tableColumn.identifier.rawValue) else {
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
  
  func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
    annotatedItems = (annotatedItems as NSArray).sortedArray(using: sortDescriptors) as! [AnnotatedItem]
    tableView.reloadData()
  }
}

extension ItemsTableDataSource: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return annotatedItems.count
  }
}
