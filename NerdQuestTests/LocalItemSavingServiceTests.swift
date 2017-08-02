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
  var localItemSavingService = LocalItemSavingService()
  
  override func setUp() {
    super.setUp()
    setupDatabase()
  }
  
  private func setupDatabase() {
    localItemSavingService.databaseQueue = FMDatabaseQueue(path: TestAppConstants.kDatabasePath)
    let bundle = Bundle.init(for: type(of: self))
    
    guard let schemaPath = bundle.path(forResource: "schema", ofType: "sql") else {
      XCTFail()
      return
    }
    guard let libraryDataPath = bundle.path(forResource: "libraryData", ofType: "sql") else {
      XCTFail()
      return
    }
    guard
      let schemaCmd = try? String(contentsOfFile: schemaPath, encoding: .utf8),
      let libraryDataCmd = try? String(contentsOfFile: libraryDataPath, encoding: .utf8) else {
        XCTFail()
      return
    }
    localItemSavingService.databaseQueue?.inTransaction { database, rollback in
      guard let database = database else {
        XCTFail()
        return
      }
      print("Database Error 1: \(database.lastError())")
      database.executeStatements(schemaCmd)
      database.executeStatements(libraryDataCmd)
      print("Database Error 2: \(database.lastError())")
    }
  }
  
  override func tearDown() {
    super.tearDown()
    tearDownDatabase()
  }
  
  private func tearDownDatabase() {
    let fileManager = FileManager.default
    do {
      try fileManager.removeItem(atPath: TestAppConstants.kDatabasePath)
    } catch {
      XCTFail()
      return
    }
  }
  
  func testSaveAnItem() {
    let expect = expectation(description: "waitForDatabase")
    var annotatedItems = [AnnotatedItem]()
    let itemToSave = NerdItem(name: "Banana Peel", itemDescription: "Ridculously Good-looking", id: "9999", rarity: 3, dateAdded: 11, isUsed: false)
    localItemSavingService.saveItem(nerdItem: itemToSave) { [weak self] success in
      guard let this = self else {
        return
      }
      XCTAssertTrue(success)
      this.localItemSavingService.getAnnotatedItems { items in
        annotatedItems = items
        expect.fulfill()
      }
    }
    
    waitForExpectations(timeout: 10, handler: nil)
    let annotatedItem = annotatedItems.first!
    
    XCTAssertEqual(annotatedItems.count, 1, "There should only be one item in the Items table")
  
    XCTAssertEqual(itemToSave.name, annotatedItem.item.name, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave.itemDescription, annotatedItem.item.itemDescription, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave.id, annotatedItem.item.id, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave.rarity, annotatedItem.item.rarity, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave.dateAdded, annotatedItem.item.dateAdded, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave.isUsed, false, "Item retrieved should match originally inserted item")
  }
  
  
}
