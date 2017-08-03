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
  var messagesTableDataSource: MessagesTableDataSource!
  var battlingMessagesTableDataSource: BattlingMessagesTableDataSource!
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
    
    nerdService.updateDelegate = self
    
    messagesTableDataSource = MessagesTableDataSource(tableView: messageTableView)
    battlingMessagesTableDataSource = BattlingMessagesTableDataSource(tableView: battlingMessageTableView)
    
    itemsTableDataSource = ItemsTableDataSource(tableView: itemsTableView)
    leaderboardTableDataSource = LeaderboardTableDataSource(tableView: leaderboardTableView)
    itemsTableDataSource.delegate = self

    queueItemsTableDataSource = ItemQueueTableDataSource(tableView: queueItemsTableView)
    queueItemsTableDataSource.delegate = self
    
    battlingService.delegate = self
    
    nerdService.startServices()
    startItemCounter()
  }
  
  private func startItemCounter() {
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
      guard let this = self else {
        return
      }
      this.itemCountdownLabel.stringValue = "Item Timer: \(this.battlingService.counter)"
      this.queueItemsTableDataSource.queueItems = this.battlingService.itemBuffer
      this.queueItemsTableView.reloadData()
      }.fire()
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
  }
}

extension MainViewController: AddedToQueue {
  func addedToQueue() {
    queueItemsTableDataSource.queueItems = battlingService.itemBuffer
    queueItemsTableView.reloadData()
  }
}

extension MainViewController: NerdServiceUpdates {
  func miningDidUpdate(nerdPoint: NerdPoint) {
    pointsLabel.stringValue = "Points: \(nerdPoint.points)"
    messagesTableDataSource.messages = nerdPoint.messages + messagesTableDataSource.messages
    messageTableView.reloadData()
  }
  
  func itemSavingDidUpdate(annotatedItems: [AnnotatedItem]) {
    itemsTableDataSource.annotatedItems = annotatedItems
    itemsTableView.reloadData()
  }
  
  func battlingDidUpdate(response: NerdBattlingResponse) {
    battlingMessagesTableDataSource.messages = response.messages + battlingMessagesTableDataSource.messages
    battlingMessageTableView.reloadData()
  }
  
  func leaderboardingDidUpdate(players: [NerdPlayer]) {
    leaderboardTableDataSource.players = players
    leaderboardTableView.reloadData()
  }
  
  func networkStatusDidUpdate(message: String) {
    errorLabel.stringValue = message
  }
}
