//
//  LocalItemSavingService.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/28/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation
import FMDB
class LocalItemSavingService: ItemSaving {
  let database = FMDatabase(path: AppConstants.kDatabasePath)
  
  func saveItem(nerdItem: NerdItem) {
    //guard AppConstants.hasDatabase else {
      writeToItemsFile(item: nerdItem)
    //  return
    //}
    
    guard
      let database = database,
      database.open() else {
      print("Cannot open database to save item \(nerdItem.name) \(nerdItem.id)")
      return
    }
    
    let insertQuery = "insert into Item (id, name, rarity, description, isUsed, dateAdded) values (?,?,?,?,?,?)"
    
    do {
      try database.executeUpdate(insertQuery, values: [nerdItem.id,
                                                 nerdItem.name,
                                                 nerdItem.rarity,
                                                 nerdItem.description,
                                                 0,
                                                 nerdItem.dateAdded])
    } catch {
      print("error \(error.localizedDescription)")
      database.close()
      return
    }
    
    database.close()
  }
  
  func getAnnotatedItems() -> [AnnotatedItem] {
    var nerdItems = [NerdItem]()
    var annotatedItems = [AnnotatedItem]()
    guard
      let database = database,
      database.open() else {
        print("Cannot open database to get annotated items")
        return []
    }
    
    let selectQuery = "select id, name, rarity, description, isUsed, dateAdded from Item where isUsed = 0 order by dateAdded desc"
    do {
      let resultSet = try database.executeQuery(selectQuery, values: [])
      while resultSet.next() {
        guard let id = resultSet.string(forColumn: "id"),
              let name = resultSet.string(forColumn: "name") else {
          continue
        }
        
        let rarity = Int(resultSet.int(forColumn: "rarity"))
        let description = resultSet.string(forColumn: "description") ?? ""
        let isUsed = resultSet.bool(forColumn: "isUsed")
        let dateAdded = Int(resultSet.int(forColumn: "dateAdded"))
        
        let nerdItem = NerdItem(name: name, description: description, id: id, rarity: rarity, dateAdded: dateAdded, isUsed: isUsed)
        nerdItems.append(nerdItem)
      }
    } catch {
      print("error \(error.localizedDescription)")
      database.close()
      return []
    }
    do {
      for nerdItem in nerdItems {
        var annotation: Annotation?
        let selectQuery = "select itemType, duration, effect from Library join Item on Library.name = ?"
        let resultSet = try database.executeQuery(selectQuery, values: [nerdItem.name])
        while resultSet.next() {
          let itemType = ItemType(rawValue: Int(resultSet.int(forColumn: "itemType")))
          let duration = resultSet.string(forColumn: "duration")
          let effect = resultSet.string(forColumn: "effect")
          annotation = Annotation(itemType: itemType, duration: duration, effect: effect)
        }
        let annotatedItem = AnnotatedItem(item: nerdItem, annotation: annotation)
        annotatedItems.append(annotatedItem)
      }
    } catch {
      print("error \(error.localizedDescription)")
      database.close()
      return []
    }
    
    database.close()
    return annotatedItems
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
