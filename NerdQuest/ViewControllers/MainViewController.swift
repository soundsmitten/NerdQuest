//
//  ViewController.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/27/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, Passable {
  let pointMiningService = LocalPointMiningService()
  let messagesTableDataSource = MessagesTableDataSource()
  let itemsTableDataSource = ItemsTableDataSource()
  
  var isMiningEnabled = true
  var isMiningRunning = false
  var nerdService: NerdService!
  
  @IBOutlet weak var messageTableView: NSTableView!
  @IBOutlet weak var itemsTableView: NSTableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    messageTableView.dataSource = messagesTableDataSource
    messageTableView.delegate = messagesTableDataSource
    
    itemsTableView.dataSource = itemsTableDataSource
    itemsTableView.delegate = itemsTableDataSource
    itemsTableView.doubleAction = #selector(doubleClickItemRow)
    
    refreshItemsTable()
    
    startMining()
  }
  
  func refreshItemsTable() {
    itemsTableDataSource.annotatedItems = nerdService.itemSavingService.getAnnotatedItems()
    itemsTableView.reloadData()
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
  
  @objc func doubleClickItemRow() {
    let rowView = itemsTableView.rowView(atRow: itemsTableView.clickedRow, makeIfNecessary: false)
    guard
      let idCell = rowView?.view(atColumn: itemsTableView.numberOfColumns - 1) as? NSTableCellView,
      let id = idCell.textField?.stringValue
      else {
        print("Can't get table text field value")
        return
    }
   
    guard let clickedItem = itemsTableDataSource.annotatedItems.find(predicate: {
      $0.item.id == id
    }) else {
      return
    }
    
    let alert = NSAlert()
    
  }
  
  private func startMining() {
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
          this.messagesTableDataSource.messages = [message] + this.messagesTableDataSource.messages
          this.messageTableView.reloadData()
        }
        if let item = nerdPoint.item {
          this.nerdService.itemSavingService.saveItem(nerdItem: item)
          this.refreshItemsTable()
        }
      })
    })
  }
}
