//
//  Sequence+Find.swift
//  NerdQuest
//
//  Created by Nicholas Lash on 7/29/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

public extension Sequence {
  func find(predicate: (Iterator.Element) throws -> Bool) rethrows -> Iterator.Element? {
    for element in self {
      if try predicate(element) {
        return element
      }
    }
    return nil
  }
}
