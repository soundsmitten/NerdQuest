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
  var databaseQueue = FMDatabaseQueue(path: AppConstants.kDatabasePath)
  
  func saveItem(nerdItem: NerdItem, completion: @escaping (Bool) -> Void){
    let insertQuery = "insert into Item (id, name, rarity, description, isUsed, dateAdded) values (?,?,?,?,?,?)"
    guard let databaseQueue = databaseQueue else {
      print("cannot create db queue")
      completion(false)
      return
    }
    
    databaseQueue.inTransaction { database, rollback in
      guard
        let database = database else {
          return
      }

      do {
        try database.executeUpdate(insertQuery, values: [nerdItem.id,
                                                         nerdItem.name,
                                                         nerdItem.rarity,
                                                         nerdItem.itemDescription,
                                                         0,
                                                         nerdItem.dateAdded])
      } catch {
        print("error \(error.localizedDescription)")
        rollback?.pointee = true
      }
    }
    completion(true)
  }
  
  func saveItemFromMessage(message: String) {
    let idAndName = getIDAndName(text: message, pattern: AppConstants.kMessageParsingRegex)
    if idAndName.count == 2 {
      saveItem(nerdItem: NerdItem(name: idAndName.last!, itemDescription: "Bonus Item", id: idAndName.first!, rarity: -1, dateAdded: Int(Date().timeIntervalSince1970), isUsed: false)) { success in
        if !success {
          print("can't save item from message")
        }
      }
    }
  }
    
  func getAnnotatedItems(completion: @escaping ([AnnotatedItem])->Void) {
    
    var annotatedItems = [AnnotatedItem]()
    let selectQuery = "select Item.id, Item.name, Item.rarity, Item.description, Item.isUsed, Item.dateAdded, Library.itemType, Library.duration, Library.effect from Item left join Library on Item.name = Library.name  where Item.isUsed = 0 order by Item.name asc"
    guard let databaseQueue = databaseQueue else {
      print("cannot create db queue")
      completion([])
      return
    }
    
    databaseQueue.inTransaction { database, rollback in
      guard
        let database = database else {
          return
      }
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
      } catch {
        print("error \(error.localizedDescription)")
        rollback?.pointee = true
        return
      }
    }
    completion(annotatedItems)
  }
  
  func isItemUsed(itemID: String, completion: @escaping (Bool)->Void) {
    guard let databaseQueue = databaseQueue else {
      print("cannot create db queue")
      return completion(false)
    }
    var isUsed = false
    databaseQueue.inTransaction { database, rollback in
      guard
        let database = database else {
          return
      }
      let selectQuery = "select isUsed from Item where id = ?"
      do {
        let resultSet = try database.executeQuery(selectQuery, values: [itemID])
        while resultSet.next() {
          isUsed = resultSet.bool(forColumn: "isUsed")
        }
      } catch {
        print("error \(error.localizedDescription)")
        rollback?.pointee = true
      }
    }
    return completion(isUsed)
  }
  
  func getRandomItem(itemType: ItemType, completion: @escaping (AnnotatedItem?)->Void) {
    var annotatedItem: AnnotatedItem?
    let selectQuery = "select Item.id, Item.name, Item.rarity, Item.description, Item.isUsed, Item.dateAdded, Library.itemType, Library.duration, Library.effect from Item left join Library on Item.name = Library.name  where Item.isUsed = 0 and Library.itemType = ? order by random() limit 1"
    
    guard let databaseQueue = databaseQueue else {
      print("cannot create db queue")
      return completion(nil)
    }
    
    databaseQueue.inTransaction { database, rollback in
      guard
        let database = database else {
          return
      }
    
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
      } catch {
        print("error \(error.localizedDescription)")
        rollback?.pointee = true
      }
    }
    completion(annotatedItem)
  }
  
  func useItem(itemID: String, completion: @escaping (Bool)->Void) {
    guard let databaseQueue = databaseQueue else {
      print("cannot create db queue")
      completion(false)
      return
    }
    
    databaseQueue.inTransaction { database, rollback in
      guard
        let database = database else {
          return
      }
      
      let updateQuery = "update Item set isUsed = 1 where id = ?"
      do {
        try database.executeUpdate(updateQuery, values: [itemID])
      } catch {
        print("error \(error.localizedDescription)")
        rollback?.pointee = true
      }
    }
    completion(true)
  }
}

