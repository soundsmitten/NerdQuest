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
  var queueItemsTableDataSource: ItemQueueTableDataSource!
  
  var isMiningEnabled = true
  var isMiningRunning = false
  var nerdService: NerdService!
  var battlingService: Battling!
  var isFirstLaunch = true
  var nameAndIDToBuffer: NameAndID?
  
  @IBOutlet weak var messageTableView: NSTableView!
  @IBOutlet weak var itemsTableView: NSTableView!
  @IBOutlet weak var leaderboardTableView: NSTableView!
  @IBOutlet weak var battlingMessageTableView: NSTableView!
  @IBOutlet weak var queueItemsTableView: NSTableView!
  
  
  @IBOutlet weak var itemCountdownLabel: NSTextField!
  @IBOutlet weak var pointsLabel: NSTextField!
  @IBOutlet weak var errorLabel: NSTextField!
  override func viewDidLoad() {
    super.viewDidLoad()

    messageTableView.dataSource = messagesTableDataSource
    messageTableView.delegate = messagesTableDataSource
    
    battlingMessageTableView.dataSource = battlingMessagesTableDataSource
    battlingMessageTableView.delegate = battlingMessagesTableDataSource
    
    itemsTableDataSource = ItemsTableDataSource(tableView: itemsTableView)
    leaderboardTableDataSource = LeaderboardTableDataSource(tableView: leaderboardTableView)
    itemsTableDataSource.delegate = self

    queueItemsTableDataSource = ItemQueueTableDataSource(tableView: queueItemsTableView)
    queueItemsTableDataSource.delegate = self
    
    battlingService.delegate = self
    
    refreshItemsTable()
    
    setupMining()
    setupLeaderboard() {
      self.setupBattling()
    }
  }
  
  func refreshItemsTable() {
    nerdService.itemSavingService.getAnnotatedItems { [weak self] annotatedItems in
      self?.itemsTableDataSource.annotatedItems = annotatedItems
      self?.itemsTableView.reloadData()
    }
  }
  
  @IBAction func toggleMining(_ sender: NSButton) {
    if sender.state == .on {
      nerdService.pointMiningService.startMining()
      sender.cell?.title = NSLocalizedString("Mining On", comment: "")
    } else {
      nerdService.pointMiningService.stopMining()
      sender.cell?.title = NSLocalizedString("Mining Off", comment: "")
    }
  }
  
  @IBAction func toggleBattling(_ sender: Any) {
    guard let button = sender as? NSButton else {
      return
    }
    if button.state == .on {
      battlingService.startBattling()
      button.cell?.title = NSLocalizedString("Battling On", comment: "")
    } else {
      battlingService.stopBattling()
      button.cell?.title = NSLocalizedString("Battling Off", comment: "")
    }
  }
  
  @IBAction func addToQueueMenuItemChosen(sender: Any) {
    guard itemsTableView.indexWithinBounds(index: itemsTableView.selectedRow) else {
      return
    }
    let itemToUse = itemsTableDataSource.annotatedItems[itemsTableView.selectedRow]
    addToItemBuffer(nameAndID: (itemToUse.item.name, itemToUse.item.id))
  }
  
  private func setupMining() {
    nerdService.pointMiningService.startMining()
    nerdService.sanityCheckingService.checkAPIKey(completion: { [weak self] in
      nerdService.pointMiningService.setupMining(completion: { [weak self] nerdPoint, error in
        guard let nerdPoint = nerdPoint,
          let this = self else {
            return
        }
        this.pointsLabel.stringValue = "Points: \(nerdPoint.points)"
        
        for message in nerdPoint.messages {
          this.saveItemFromMessage(message: message)
        }
        
        let messages = nerdPoint.messages
        this.messagesTableDataSource.messages = messages + this.messagesTableDataSource.messages
        this.messageTableView.reloadData()
        
        if let item = nerdPoint.item {
          this.nerdService.itemSavingService.saveItem(nerdItem: item) { success in
            if success {
              this.refreshItemsTable()
            }
          }
        }
      })
    })
  }
  
  private func saveItemFromMessage(message: String) {
    let idAndName = getIDAndName(text: message, pattern: AppConstants.kMessageParsingRegex)
    if idAndName.count == 2 {
      nerdService.itemSavingService.saveItem(nerdItem: NerdItem(name: idAndName.last!, itemDescription: "Bonus Item", id: idAndName.first!, rarity: -1, dateAdded: Int(Date().timeIntervalSince1970), isUsed: false)) { success in
        if !success {
          print("can't save item from message")
        }
      }
    }
  }
  
  private func setupLeaderboard(completion: @escaping ()->()) {
    nerdService.leaderboardingService.setupLeaderboard(completion: { [weak self] players, error in
      guard let players = players,
        let this = self else {
        return
      }
      this.leaderboardTableDataSource.players = players
      this.leaderboardTableView.reloadData()
      
      if this.isFirstLaunch {
        this.isFirstLaunch = false
        completion()
      }
    })
  }
  
  private func setupBattling() {
    battlingService.startBattling()
    battlingService.buffPercentage = AppConstants.kBuffPercentage
    battlingService.setupBattling { [weak self] nerdBattlingResponse, error in
      guard
        let this = self,
        let nerdBattlingResponse = nerdBattlingResponse else {
          if let error = error {
            self?.errorLabel.stringValue = "\(error.localizedDescription). Error using item. Get better internet."
          }
          return
      }
      
      self?.errorLabel.stringValue = "No connection issues."
      
      let messages = nerdBattlingResponse.messages
      for message in messages {
        this.saveItemFromMessage(message: message)
      }
      
      this.battlingMessagesTableDataSource.messages = messages + this.battlingMessagesTableDataSource.messages
      this.battlingMessageTableView.reloadData()
      this.refreshItemsTable()
    }
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
      guard let this = self else {
        return
      }
      this.itemCountdownLabel.stringValue = "Item Timer: \(this.battlingService.counter)"
      this.queueItemsTableDataSource.queueItems = this.battlingService.itemBuffer
      this.queueItemsTableView.reloadData()
    }.fire()
  }
  
  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else {
      return
    }
    switch identifier {
    case NSStoryboardSegue.Identifier(rawValue: SegueIdentifiers.kMainToManualSegue):

      guard
        let destination = segue.destinationController as? NSWindowController,
        let manualLaunchViewController = destination.contentViewController as? ManualLaunchViewController else {
          return
      }
      manualLaunchViewController.battlingService = battlingService
      manualLaunchViewController.nerdService = nerdService
      manualLaunchViewController.delegate = self
      return
    case NSStoryboardSegue.Identifier(rawValue: SegueIdentifiers.kMainToAddToQueueSegue):
      guard
        let destination = segue.destinationController as? NSWindowController,
        let addToQueueViewController = destination.contentViewController as? AddToQueueViewController else {
          return
      }
      addToQueueViewController.delegate = self
      addToQueueViewController.nameAndID = nameAndIDToBuffer
      addToQueueViewController.battlingService = battlingService
    default:
      return
    }
  }
}

extension MainViewController: ItemTappedDelegate {
  func addToItemBuffer(nameAndID: NameAndID) {
    nameAndIDToBuffer = (nameAndID.0, nameAndID.1)
    
    performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: SegueIdentifiers.kMainToAddToQueueSegue), sender: nil)
  }
}

extension MainViewController: QueueItemTappedDelegate {
  func removeFromItemBuffer(queueItem: NameAndIDWithTarget) {
    guard let index = queueItemsTableDataSource.queueItems.index( where: {
      return  $0 == queueItem
    }), queueItemsTableView.indexWithinBounds(index: index) else {
      print("Protect from fucking the indices!")
      return
    }
    battlingService.remove(queueItem.1)
    queueItemsTableDataSource.queueItems = battlingService.itemBuffer
    queueItemsTableView.reloadData()
  }
}

extension MainViewController: BattlingActionDidOccurDelegate {
  func battlingActionDidOccur() {
    queueItemsTableDataSource.queueItems = battlingService.itemBuffer
    queueItemsTableView.reloadData()
    refreshItemsTable()
  }
}

extension MainViewController: AddedToQueue {
  func addedToQueue() {
    queueItemsTableDataSource.queueItems = battlingService.itemBuffer
    queueItemsTableView.reloadData()
    refreshItemsTable()
  }
}
