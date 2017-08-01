//
//  Passable.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/28/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

protocol Passable {
  var nerdService: NerdService! { get set }
  var battlingService: Battling! { get set }
}

extension Passable {
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
