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
    var annotatedItems = [AnnotatedItem]()
    guard
      let database = database,
      database.open() else {
        print("Cannot open database to get annotated items")
        return []
    }
    
    let selectQuery = "select Item.id, Item.name, Item.rarity, Item.description, Item.isUsed, Item.dateAdded, Library.itemType, Library.duration, Library.effect from Item left join Library on Item.name = Library.name  where Item.isUsed = 0 order by Item.name asc"
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
        
        let itemType = ItemType(rawValue: Int(resultSet.int(forColumn: "itemType"))) ?? .unknown
        let duration = resultSet.string(forColumn: "duration") ?? "??"
        let effect = resultSet.string(forColumn: "effect") ?? "??"
        
        let nerdItem = NerdItem(name: name, itemDescription: description, id: id, rarity: rarity, dateAdded: dateAdded, isUsed: isUsed)
        let annotation = Annotation(itemType: itemType, duration: duration, effect: effect)

        annotatedItems.append(AnnotatedItem(item: nerdItem, annotation: annotation))
      }
      database.close()
      return annotatedItems
    } catch {
      print("error \(error.localizedDescription)")
      database.close()
      return []
    }
  }
  
  func isItemUsed(itemID: String) -> Bool {
    guard
      let database = database,
      database.open() else {
        print("Cannot open database to check item use")
        return false
    }
    
    var isUsed = false
    let selectQuery = "select isUsed from Item where id = ?"
    do {
      let resultSet = try database.executeQuery(selectQuery, values: [itemID])
      while resultSet.next() {
        isUsed = resultSet.bool(forColumn: "isUsed")
      }
    } catch {
      print("error \(error.localizedDescription)")
      database.close()
      return false
    }
    
    database.close()
    return isUsed
  }
  
  func getRandomItem(itemType: ItemType) -> AnnotatedItem? {
    var annotatedItem: AnnotatedItem?
    guard
      let database = database,
      database.open() else {
        print("Cannot open database to get annotated items")
        return nil
    }
    let selectQuery = "select Item.id, Item.name, Item.rarity, Item.description, Item.isUsed, Item.dateAdded, Library.itemType, Library.duration, Library.effect from Item left join Library on Item.name = Library.name  where Item.isUsed = 0 and Library.itemType = ? order by random() limit 1"
    do {
      let resultSet = try database.executeQuery(selectQuery, values: [itemType.rawValue])
      while resultSet.next() {
        guard let id = resultSet.string(forColumn: "id"),
          let name = resultSet.string(forColumn: "name") else {
            continue
        }
        
        let rarity = Int(resultSet.int(forColumn: "rarity"))
        let description = resultSet.string(forColumn: "description") ?? ""
        let isUsed = resultSet.bool(forColumn: "isUsed")
        let dateAdded = Int(resultSet.int(forColumn: "dateAdded"))
        
        let itemType = ItemType(rawValue: Int(resultSet.int(forColumn: "itemType"))) ?? .unknown
        let duration = resultSet.string(forColumn: "duration") ?? "??"
        let effect = resultSet.string(forColumn: "effect") ?? "??"
        
        let nerdItem = NerdItem(name: name, itemDescription: description, id: id, rarity: rarity, dateAdded: dateAdded, isUsed: isUsed)
        let annotation = Annotation(itemType: itemType, duration: duration, effect: effect)
        annotatedItem = AnnotatedItem(item: nerdItem, annotation: annotation)
      }
      database.close()
      return annotatedItem
    } catch {
      print("error \(error.localizedDescription)")
      database.close()
      return nil
    }
  }
  
  func useItem(itemID: String) {
    guard
      let database = database,
      database.open() else {
        print("Cannot open database to use item")
        return
    }
    let updateQuery = "update Item set isUsed = 1 where id = ?"
    do {
      try database.executeUpdate(updateQuery, values: [itemID])
    } catch {
      print("error \(error.localizedDescription)")
      database.close()
      return
    }
    
    database.close()
  }
}
