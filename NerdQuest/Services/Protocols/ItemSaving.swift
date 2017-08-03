//
//  ItemSaving.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/28/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

protocol ItemSaving {
  func saveItem(nerdItem: NerdItem, completion: @escaping (Bool)->Void)
  func getAnnotatedItems(completion: @escaping ([AnnotatedItem])->Void)
  func getRandomItem(itemType: ItemType, completion: @escaping (AnnotatedItem?)->Void)
  func useItem(itemID: String, completion: @escaping (Bool)->Void)
  func isItemUsed(itemID: String, completion: @escaping (Bool)->Void)
  func saveItemFromMessage(message: String)
}

extension ItemSaving {
  func getIDAndName(text: String, pattern: String) -> [String] {
    let formatter = try! NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
    let matches = formatter.matches(in: text, options: [], range: text.nsrange)
    
    var results = [String]()
    guard matches.count > 0 else {
      return results
    }
    for i in 0..<2 {
      results.append(text.substring(with: matches.first!.range(at: i+1))!)
      print(i)
    }
    return results
  }
}
