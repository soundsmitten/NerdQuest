//
//  ApiResource.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/27/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

protocol ApiResource {
  associatedtype Model
  var methodPath: String { get }
  var httpMethod: NerdHTTPMethod { get }
  func makeModel(data: Data) -> Model
}

extension ApiResource {
  var url: URL {
    let baseURL = "http://nerdquest.nerderylabs.com:1337"
    let url = baseURL + methodPath
    return URL(string: url)!
  }
}
