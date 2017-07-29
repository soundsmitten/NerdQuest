//
//  NerdNetworkRequest.swift
//  SSNerdQuest
//
//  Created by Nicholas Lash on 7/27/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import Foundation

class NerdNetworkRequest<Resource: ApiResource> {
  let resource: Resource
  init(resource: Resource) {
    self.resource = resource
  }
}

extension NerdNetworkRequest: NetworkRequest {
  func decode(_ data: Data) -> Resource.Model? {
    return resource.makeModel(data: data)
  }
}
