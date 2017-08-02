//
//  LeaderboardTableDataSource.swift
//  NerdQuest
//
//  Created by Nicholas Lash on 7/30/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Cocoa

class LeaderboardTableDataSource: NSObject {
  var players = [NerdPlayer]()
  weak var tableView: NSTableView!
  
  init(tableView: NSTableView) {
    super.init()
    self.tableView = tableView
    self.tableView.dataSource = self
    self.tableView.delegate = self
  }
  
  enum ColumnInfo: String {
    case name = "playerName"
    case points = "playerPoints"
  }
}

extension LeaderboardTableDataSource: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return players.count
  }
}

extension LeaderboardTableDataSource: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard
      let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifiers.kPlayerCellIdentifier), owner: nil) as? NSTableCellView,
      let tableColumn = tableColumn,
      let columnIdentifier = ColumnInfo(rawValue: tableColumn.identifier.rawValue) else {
        return nil
    }
    
    let player = players[row]
    
    var cellText = ""
    
    switch columnIdentifier {
    case .name:
      cellText = player.name
    case .points:
      cellText = "\(player.points)"
    }
    
    var textColor = NSColor.red
    if Nerds.kWhiteList.contains(player.name) {
      textColor = NSColor.green
    }
    let range = cellText.nsrange
    var attributedString = NSMutableAttributedString(string: cellText)
    attributedString.addAttributes([.foregroundColor: textColor], range: range)
    cell.textField?.attributedStringValue = attributedString
    
    return cell
  }
}
