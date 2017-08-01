//
//  ItemQueueTableDataSource.swift
//  NerdQuest
//
//  Created by Nicholas Lash on 7/30/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Cocoa

protocol QueueItemTappedDelegate {
  func removeFromItemBuffer(queueItem: NameAndIDWithTarget)
}

class ItemQueueTableDataSource: NSObject {
  var queueItems = [NameAndIDWithTarget]()
  weak var tableView: NSTableView!
  var delegate: QueueItemTappedDelegate?
  
  init(tableView: NSTableView) {
    super.init()
    self.tableView = tableView
    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.tableView.doubleAction = #selector(tableTapped(sender:))
    self.tableView.target = self
  }

  @objc func tableTapped(sender: AnyObject) {
    guard tableView.indexWithinBounds(index: sender.clickedRow) else {
      return
    }
    let queueItem = queueItems[sender.clickedRow]
    delegate?.removeFromItemBuffer(queueItem: queueItem)
  }
  
  enum ColumnInfo: String {
    case name = "queueName"
    case target = "queueTarget"
    case id = "queueID"
  }
}

extension ItemQueueTableDataSource: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return queueItems.count
  }
}

extension ItemQueueTableDataSource: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard
      let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifiers.kQueueCellIdentifier), owner: nil) as? NSTableCellView,
      let tableColumn = tableColumn,
      let columnIdentifier = ColumnInfo(rawValue: tableColumn.identifier.rawValue) else {
        return nil
    }
    
    let queueItem = queueItems[row]
    let name = queueItem.0
    let id = queueItem.1
    let target = queueItem.2
    
    var cellText = ""
    
    switch columnIdentifier {
    case .name:
      cellText = name
    case .id:
      cellText = id
    case .target:
      cellText = target
    }
    
    cell.textField?.stringValue = cellText
    return cell
  }
}
