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
                                                 nerdItem.itemDescription,
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
    
    let selectQuery = "select id, name, rarity, description, isUsed, dateAdded from Item where isUsed = 0 order by name asc"
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
        
        let nerdItem = NerdItem(name: name, itemDescription: description, id: id, rarity: rarity, dateAdded: dateAdded, isUsed: isUsed)
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
        let selectQuery = "select itemType, duration, effect from Library join Item on Library.name = ? order by itemType asc"
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
  
  func getRandomItem(itemType: ItemType) -> AnnotatedItem? {
    let annotatedItems = getAnnotatedItems()
    let filteredItems = annotatedItems.filter {
      $0.annotation?.itemType == itemType
    }
    
    guard filteredItems.count > 0 else {
      return nil
    }
    
    let index = Int(arc4random_uniform(UInt32(filteredItems.count)))
    return filteredItems[index]
  }
}
