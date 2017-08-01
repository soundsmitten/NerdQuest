//
//  NSTableView+Bounds.swift
//  NerdQuest
//
//  Created by Nicholas Lash on 8/1/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Cocoa

extension NSTableView {
  func indexWithinBounds(index: Int) -> Bool {
    return index >= 0 && index < self.numberOfRows
  }
}
