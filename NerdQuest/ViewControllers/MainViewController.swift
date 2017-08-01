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
  
  @IBOutlet weak var messageTableView: NSTableView!
  @IBOutlet weak var itemsTableView: NSTableView!
  @IBOutlet weak var leaderboardTableView: NSTableView!
  @IBOutlet weak var battlingMessageTableView: NSTableView!
  @IBOutlet weak var queueItemsTableView: NSTableView!
  
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
    itemsTableDataSource.annotatedItems = nerdService.itemSavingService.getAnnotatedItems()
    itemsTableView.reloadData()
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
    let itemToUse = itemsTableDataSource.annotatedItems[itemsTableView.selectedRow]
    addToItemBuffer(nameAndID: (itemToUse.item.name, itemToUse.item.id))
  }
  
  private func setupMining() {
    nerdService.pointMiningService.startMining()
    nerdService.sanityCheckingService.checkAPIKey(completion: { [weak self] in
      nerdService.pointMiningService.setupMining(completion: { [weak self] nerdPoint in
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
          this.nerdService.itemSavingService.saveItem(nerdItem: item)
          this.refreshItemsTable()
        }
      })
    })
  }
  
  private func saveItemFromMessage(message: String) {
    let idAndName = getIDAndName(text: message, pattern: AppConstants.kMessageParsingRegex)
    if idAndName.count == 2 {
      nerdService.itemSavingService.saveItem(nerdItem: NerdItem(name: idAndName.last!, itemDescription: "Bonus Item", id: idAndName.first!, rarity: -1, dateAdded: Int(Date().timeIntervalSince1970), isUsed: false))
    }
  }
  
  private func setupLeaderboard(completion: @escaping ()->()) {
    nerdService.leaderboardingService.setupLeaderboard(completion: { [weak self] players in
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
    battlingService.setupBattling { [weak self] nerdBattlingResponse in
      guard
        let this = self,
        let nerdBattlingResponse = nerdBattlingResponse else {
          return
      }
      
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
    default:
      return
    }
  }
}

extension MainViewController: ItemTappedDelegate {
  func addToItemBuffer(nameAndID: NameAndID) {
    let name = nameAndID.0
    let itemID = nameAndID.1
    
    let alert = NSAlert()
    let textField = NSTextField(frame: CGRect(x: 0, y: 0, width: 300, height: 24))
    textField.placeholderString = NSLocalizedString("Target", comment: "")
    alert.accessoryView = textField
    alert.window.initialFirstResponder = textField
    alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
    alert.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
    alert.messageText = NSLocalizedString("Please enter your target.", comment: "")
    alert.informativeText = NSLocalizedString("Be careful.", comment: "")
    alert.alertStyle = .critical
    let responseTag = alert.runModal()
    if responseTag == .alertFirstButtonReturn {
      let nameAndIDWithTarget = (name, itemID, textField.stringValue)
      battlingService.enqueue(nameAndIDWithTarget)
      queueItemsTableDataSource.queueItems = battlingService.itemBuffer
      queueItemsTableView.reloadData()
    }
  }
}

extension MainViewController: QueueItemTappedDelegate {
  func removeFromItemBuffer(queueItem: NameAndIDWithTarget) {
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

extension MainViewController: ManualLaunchAddedToQueue {
  func manualLaunchAddedToQueue() {
    queueItemsTableDataSource.queueItems = battlingService.itemBuffer
    queueItemsTableView.reloadData()
    refreshItemsTable()
  }
}
