//
//  String+Ranges.swift
//  NerdQuest
//
//  Created by Nicholas Lash on 7/31/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

extension String {
  /// An `NSRange` that represents the full range of the string.
  var nsrange: NSRange {
    return NSRange(location: 0, length: utf16.count)
  }
  
  /// Returns a substring with the given `NSRange`,
  /// or `nil` if the range can't be converted.
  func substring(with nsrange: NSRange) -> String? {
    guard let range = Range.init(nsrange)
      else { return nil }
    let start =  UTF16Index(String.Index(encodedOffset: range.lowerBound), within: self)!
    let end =  UTF16Index(String.Index(encodedOffset: range.upperBound), within: self)!
    return String(utf16[start..<end])
  }
  
  /// Returns a range equivalent to the given `NSRange`,
  /// or `nil` if the range can't be converted.
  func range(from nsrange: NSRange) -> Range<Index>? {
    guard let range = Range.init(nsrange) else { return nil }
    let utf16Start = UTF16Index(String.Index(encodedOffset: range.lowerBound), within: self)!
    let utf16End = UTF16Index(String.Index(encodedOffset: range.upperBound), within: self)!
    
    guard let start = Index(utf16Start, within: self),
      let end = Index(utf16End, within: self)
      else { return nil }
    
    return start..<end
  }
}
