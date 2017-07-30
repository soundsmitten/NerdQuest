//
//  ItemsTableDataSource.swift
//  NerdQuest
//
//  Created by Nicholas Lash on 7/29/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Cocoa

typealias NameAndID = (String, String)

protocol ItemTappedDelegate {
  func addToItemBuffer(nameAndID: NameAndID)
}

@objc
class ItemTableWrapper: NSObject {
  let name: String!
  let itemType: NSNumber!
  let itemEffect: String!
  let duration: String!
  let rarity: NSNumber!
  let id: String!
  
  init(name: String, itemType: Int, itemEffect: String, duration: String, rarity: Int, id: String) {
    self.name = name
    self.itemType = itemType as NSNumber
    self.itemEffect = itemEffect
    self.duration = duration
    self.rarity = rarity as NSNumber
    self.id = id
  }
}

class ItemsTableDataSource: NSObject {
  var annotatedItems = [AnnotatedItem]() {
    didSet {
      wrappedItems = []
      for item in annotatedItems {
        let wrappedItem = wrap(annotatedItem: item)
        wrappedItems.append(wrappedItem)
      }
    }
  }
  var wrappedItems = [ItemTableWrapper]()
  weak var tableView: NSTableView!
  var delegate: ItemTappedDelegate?
  
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
        return "name"
      case .itemType:
        return "itemType"
      case .effect:
        return "effect"
      case .duration:
        return "duration"
      case .rarity:
        return "rarity"
      case .id:
        return "id"
      }
    }
  }
  
  enum ColumnState: Int {
    case nothing = -1
    case descending = 0
    case ascending = 1
  }
  
  let columnsInfo: [ColumnInfo] = [.name, .itemType, .effect, .duration, .rarity, .id]
  
  init(tableView: NSTableView) {
    super.init()
    self.tableView = tableView
    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.tableView.doubleAction = #selector(tableTapped(sender:))
    self.tableView.target = self
  }
  
  @objc func tableTapped(sender: AnyObject) {
    let annotatedItem = annotatedItems[sender.clickedRow]
    delegate?.addToItemBuffer(nameAndID: (annotatedItem.item.name, annotatedItem.item.id))
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
    
    let wrappedItem = wrappedItems[row]
    var cellText = ""
    
    switch columnIdentifier {
    case .name:
      cellText = wrappedItem.name
    case .itemType:
      cellText = ItemType(rawValue: wrappedItem.itemType as! Int)!.text
    case .effect:
      cellText = wrappedItem.itemEffect
    case .duration:
      cellText = wrappedItem.duration
    case .rarity:
      cellText = "\(wrappedItem.rarity ?? -1)"
    case .id:
      cellText = "\(wrappedItem.id!)"
    }
    cell.textField?.stringValue = cellText
    return cell
  }
  
  func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
    return 20.0
  }
  
  func wrap(annotatedItem: AnnotatedItem) -> ItemTableWrapper {
    return ItemTableWrapper(name: annotatedItem.item.name,
                            itemType: annotatedItem.annotation?.itemType.rawValue ?? 3,
                            itemEffect: annotatedItem.annotation?.effect ?? "Unknown",
                            duration: annotatedItem.annotation?.duration ?? "Unknown",
                            rarity: annotatedItem.item.rarity,
                            id: annotatedItem.item.id)
  }
}

extension ItemsTableDataSource: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return annotatedItems.count
  }
}
