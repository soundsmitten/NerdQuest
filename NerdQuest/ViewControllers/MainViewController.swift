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
  
  @IBOutlet weak var pointsLabel: NSTextField!
  
  @IBAction func toggleMining(_ sender: Any) {
    guard let button = sender as? NSButton else {
      return
    }
    if button.state == .on {
      nerdService.pointMiningService.startMining()
      button.cell?.title = NSLocalizedString("Mining On", comment: "")
    } else {
      nerdService.pointMiningService.stopMining()
      button.cell?.title = NSLocalizedString("Mining Off", comment: "")
    }
  }
  
  private func loadPointMiningTable() {
    nerdService.pointMiningService.startMining()
    nerdService.sanityCheckingService.checkAPIKey(completion: { [weak self] in
      nerdService.pointMiningService.setupMining(completion: { [weak self] nerdPoint in
        guard let nerdPoint = nerdPoint,
          let this = self else {
            return
        }
        this.pointsLabel.stringValue = "Points: \(nerdPoint.points)"
        
        if nerdPoint.messages.count > 1 {
        let message = nerdPoint.messages.joined()
          this.messages = [message] + this.messages
          this.messageTableView.reloadData()
        }
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
