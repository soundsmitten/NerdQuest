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
  let battlingMessagesTableDataSource = BattlingMessagesTableDataSource()
  var itemsTableDataSource: ItemsTableDataSource!
  var leaderboardTableDataSource: LeaderboardTableDataSource!
  
  var isMiningEnabled = true
  var isMiningRunning = false
  var nerdService: NerdService!
  var battlingService: Battling!
  
  @IBOutlet weak var messageTableView: NSTableView!
  @IBOutlet weak var itemsTableView: NSTableView!
  @IBOutlet weak var leaderboardTableView: NSTableView!
  @IBOutlet weak var battlingMessageTableView: NSTableView!
  @IBOutlet weak var itemCountdownLabel: NSTextField!
  @IBOutlet weak var pointsLabel: NSTextField!

  override func viewDidLoad() {
    super.viewDidLoad()

    messageTableView.dataSource = messagesTableDataSource
    messageTableView.delegate = messagesTableDataSource
    battlingMessageTableView.dataSource = battlingMessagesTableDataSource
    battlingMessageTableView.delegate = battlingMessagesTableDataSource
    
    itemsTableDataSource = ItemsTableDataSource(tableView: itemsTableView)
    leaderboardTableDataSource = LeaderboardTableDataSource(tableView: leaderboardTableView)
    itemsTableView.doubleAction = #selector(doubleClickItemRow)
    
    refreshItemsTable()
    
    startMining()
    startLeaderboard()
    startBattling()
  }
  
  private func setupItemsTable() {
    // setup sort descriptor
  }
  
  func refreshItemsTable() {
    itemsTableDataSource.annotatedItems = nerdService.itemSavingService.getAnnotatedItems()
    itemsTableView.reloadData()
  }
  
  
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
    print(clickedItem)
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
  
  private func startLeaderboard() {
    nerdService.leaderboardingService.setupLeaderboard(completion: { [weak self] players in
      guard let players = players,
        let this = self else {
        return
      }
      this.leaderboardTableDataSource.players = players
      this.leaderboardTableView.reloadData()
    })
  }
  
  private func startBattling() {
    battlingService.buffPercentage = 100
    battlingService.startBattling()
    battlingService.setupBattling { [weak self] nerdBattlingResponse in
      guard
        let this = self,
        let nerdBattlingResponse = nerdBattlingResponse else {
          return
      }
      let message = nerdBattlingResponse.messages.joined()
      this.battlingMessagesTableDataSource.messages = [message] + this.battlingMessagesTableDataSource.messages
      this.battlingMessageTableView.reloadData()
      this.refreshItemsTable()
    }
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
      guard let this = self else {
        return
      }
      this.itemCountdownLabel.stringValue = "Item Timer: \(this.battlingService.counter)"
    }.fire()
  }
}
