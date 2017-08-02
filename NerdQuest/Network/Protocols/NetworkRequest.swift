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
  func makeRequest(urlRequest: URLRequest, completion: @escaping (Model?, Error?) -> Void) {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.timeoutIntervalForResource = AppConstants.kTimeOutInterval
    let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
    let task = session.dataTask(with: urlRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
      guard let data = data else {
        print("\(String(describing: error)) urlRequest.url")
        completion(nil, error)
        return
      }
      print(urlRequest.url ?? "unknown url")
      guard let model = self.decode(data) else {
        print("Error decoding data: \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
        return
      }
      completion(model, error)
    })
    task.resume()
  }
}
