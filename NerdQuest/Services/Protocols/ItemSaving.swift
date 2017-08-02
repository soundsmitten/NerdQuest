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
}
