//
//  LocalItemSavingService.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/28/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

class LocalItemSavingService: ItemSaving {
  
  func saveItem(nerdItem: NerdItem) {
    guard AppConstants.hasDatabase else {
      writeToItemsFile(item: nerdItem)
      return
    }
  }
  
  func writeToItemsFile(item: NerdItem) {
    let path = "/Users/nlash/Desktop/items.csv"
    let file = try FileHandle(forUpdatingAtPath: path)
    let dataToWrite = "\(item.name), \(item.id)\n".data(using: .utf8)!
    if file == nil {
      print("Opening the file failed")
    } else {
      file?.seekToEndOfFile()
      file?.write(dataToWrite)
      file?.closeFile()
    }
  }
}
