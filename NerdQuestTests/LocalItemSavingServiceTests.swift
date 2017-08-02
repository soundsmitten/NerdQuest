//
//  LocalItemSavingServiceTests.swift
//  NerdQuestTests
//
//  Created by Nicholas Lash on 8/2/17.
//  Copyright © 2017 Nicholas Lash. All rights reserved.
//

import XCTest
import FMDB

@testable import NerdQuest



class LocalItemSavingServiceTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    let localItemSavingService = LocalItemSavingService()
    localItemSavingService.databaseQueue = FMDatabaseQueue(path: TestAppConstants.kDatabasePath)
    
    let bundle = Bundle.main
    if let schemaPath = bundle.path(forResource: "schema", ofType: "sql") {
      let data = try String(contentsOfFile: schemaPath, encoding: .utf8)
    } else {
      fatalError()
    }
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
