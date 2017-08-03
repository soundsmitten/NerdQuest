//
//  AppConstants.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/27/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

struct Nerds {
  static let kMe = "nlash"
  static let kWhiteList = ["portal", "ajones",  "aolarte", "banderso", "bbowles", "bbueltma", "bhughes", "bkent", "bliset",  "bmoore",
  "bnichols", "cdavis",  "cdoyle",  "clipskey", "dappiah", "darmbrus", "ddurbin", "dgerber", "dschmitz", "efilimon", "etrio",
  "eweiss",  "gwalrod", "iheraty", "iraja", "jberube", "jblack",  "jbutts",  "jdadamo", "jdevolde", "jgardner", "jjohnsto",
  "jjones",  "jkaplan", "jkinney", "jnagar",  "jng", "jpetit",  "jpollard", "jreed", "jstetler", "jtaboada", "kasykora",
  "kballard", "kluhman", "kmartino", "ktaylor", "kwhite",  "lashield", "mduran",  "mfalkner", "mgoetz",  "mmetts",  "mpeebles",
  "ndanner", "nlash", "pahartje", "pdewitte", "pphilipp", "ppilosi", "rmilner", "rperkins", "rschmalt", "rstankie", "rvashish",
  "sahart",  "sbinion", "sdenkov", "sdoesimk", "srompelm", "tangel",  "tflynn",  "tvose", "zhessler"]
}

enum NerdHTTPMethod: String {
  case get = "GET"
  case post = "POST"
}

enum NerdBool: Int {
  case no = 0
  case yes = 1
}
struct StoryboardNames {
  static let kMain = "Main"
}

struct ViewControllerIdentifiers {
  static let kMainWindowController = "MainWindowController"
  static let kMainViewController = "MainViewController"
}

struct AppConstants {
  static let kMiningInterval = 1.0
  static let kBattlingInterval = 60.0
  static let kTimeOutInterval = 5.0
  static let hasDatabase = false
  static let kDatabasePath = "/Users/nlash/Code/Data/nerdQuest.db"
  static let kBuffPercentage = 80
  static let kManualLaunchName = "Manual Launch"
  static let kMessageParsingRegex = ".*<(.*)> \\| <(.*)>.*"
}

struct UserDefaultsKey {
  static let kAPIKey = "apikey"
}

struct HTTPHeaderKey {
  static let kAPIKey = "apikey"
  static let kTarget = "target"
}

struct CellIdentifiers {
  static let kMessageCellIdentifier = "MessageCell"
  static let kItemCellIdentifier = "ItemCell"
  static let kPlayerCellIdentifier = "PlayerCell"
  static let kBattlingMessageCellIdentifier = "BattlingMessageCell"
  static let kQueueCellIdentifier = "QueueCell"
}

enum ItemType: Int {
  case buff = 0
  case weapon = 1
  case dontUse = 2
  case unknown = 3
  case manual = 4
  
  var text: String {
    switch self {
    case .buff:
      return "Buff"
    case .weapon:
      return "Weapon"
    case .dontUse:
      return "Don't Use"
    case .unknown:
      return "???"
    case .manual:
      return "Manual"
    }
  }
}

enum ItemState: Int {
  case notUsed = 0
  case isUsed = 1
  case all = 2
}

struct SegueIdentifiers {
  static let kMainToManualSegue = "MainToManualSegue"
  static let kMainToAddToQueueSegue = "MainToAddToQueueSegue"
}
