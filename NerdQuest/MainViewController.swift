//
//  ViewController.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/27/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, Passable {
  var messages = [String]()
  
  let pointMiningService = LocalPointMiningService()
  
  var isMiningEnabled = true
  var isMiningRunning = false
  var nerdService: NerdService!
  
  @IBOutlet weak var messageTableView: NSTableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    messageTableView.dataSource = self
    messageTableView.delegate = self
    
    loadPointMiningTable()
  }
  
  private func loadPointMiningTable() {
    nerdService.sanityCheckingService.checkAPIKey(completion: { [weak self] in
      nerdService.pointMiningService.startMining(completion: { [weak self] nerdPoint in
        guard let nerdPoint = nerdPoint,
          let this = self else {
            return
        }
        let message = nerdPoint.messages.joined()
        this.messages = [message] + this.messages
        this.messageTableView.reloadData()
        if let item = nerdPoint.item {
          this.nerdService.itemSavingService.saveItem(nerdItem: item)
        }
      })
    })
  }
}

extension MainViewController: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifiers.kMessageCellIdentifier), owner: nil) as? NSTableCellView else {
      return nil
    }
    cell.textField?.stringValue = messages[row]
    return cell
  }
  
  func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
    return 20.0
  }
}

extension MainViewController: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return messages.count
  }
}
