//
//  NetworkRequest.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/27/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

protocol NetworkRequest: class {
  associatedtype Model
  func decode(_ data: Data) -> Model?
}

extension NetworkRequest {
 func makeRequest(urlRequest: URLRequest, completion: @escaping (Model?) -> Void) {
    let configuration = URLSessionConfiguration.ephemeral
    let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
    let task = session.dataTask(with: urlRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
      guard let data = data else {
        completion(nil)
        return
      }
      completion(self.decode(data))
    })
    task.resume()
  }
}
