//
//  AppConstants.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/27/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

struct Nerds {
  let whiteList = ["portal", "ajones",  "aolarte", "banderso", "bbowles", "bbueltma", "bhughes", "bkent", "bliset",  "bmoore",
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

struct StoryboardNames {
  static let kMain = "Main"
}

struct ViewControllerIdentifiers {
  static let kMainWindowController = "MainWindowController"
  static let kMainViewController = "MainViewController"
}

struct AppConstants {
  static let kMiningInterval = 1.0
  static let hasDatabase = false
}

struct UserDefaultsKey {
  static let kAPIKey = "apikey"
}

struct CellIdentifiers {
  static let kMessageCellIdentifier = "MessageCell"
}
