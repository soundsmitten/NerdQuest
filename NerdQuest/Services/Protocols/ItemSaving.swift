//
//  ItemSaving.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/28/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

protocol ItemSaving {
  func saveItem(nerdItem: NerdItem)
  func getAnnotatedItems() -> [AnnotatedItem]
  func getRandomItem(itemType: ItemType) -> AnnotatedItem?
  func useItem(itemID: String)
  func isItemUsed(itemID: String) -> Bool
}
