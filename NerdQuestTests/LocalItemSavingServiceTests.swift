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
  let itemToSave = NerdItem(name: "Banana Peel", itemDescription: "Ridculously Good-looking", id: "9999", rarity: 1, dateAdded: 1551, isUsed: false)
  let itemToSave2 = NerdItem(name: "Buffalo", itemDescription: "Ridculously Good-looking 2", id: "12345", rarity: 2, dateAdded: 44, isUsed: true)
  let itemToSave3 = NerdItem(name: "Crowbar", itemDescription: "Ridculously Good-looking 3", id: "23456", rarity: 1, dateAdded: 33, isUsed: false)
  let itemToSave4 = NerdItem(name: "Great Balls of Fire", itemDescription: "Ridculously Good-looking 3", id: "444444", rarity: 1, dateAdded: 3311, isUsed: false)
  let itemToSave5 = NerdItem(name: "Fisticuffs", itemDescription: "Ridculously Good-looking 3", id: "23455556", rarity: 2, dateAdded: 22, isUsed: false)
  let itemToSave6 = NerdItem(name: "Trash Panda", itemDescription: "Ridculously Good-looking 2", id: "123uu45", rarity: 2, dateAdded: 44, isUsed: true)

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
      this.localItemSavingService.getAnnotatedItems(itemState: .all) { items in
        annotatedItems = items
        expect.fulfill()
      }
    }
    
    waitForExpectations(timeout: 10, handler: nil)
    guard let annotatedItem = annotatedItems.first else {
      XCTFail()
      return
    }
    
    XCTAssertEqual(annotatedItems.count, 1, "There should only be one item in the Items table")
  
    XCTAssertEqual(itemToSave.name, annotatedItem.item.name, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave.itemDescription, annotatedItem.item.itemDescription, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave.id, annotatedItem.item.id, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave.rarity, annotatedItem.item.rarity, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave.dateAdded, annotatedItem.item.dateAdded, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave.isUsed, false, "Item retrieved should match originally inserted item")
  }
  
  func testUseAnItem() {
    var isItemUsed = false
    let expect = expectation(description: "waitForDatabase2")
    let expect2 = expectation(description: "waitForDatabase3")
    let expect3 = expectation(description: "waitForDatabase4")
    localItemSavingService.saveItem(nerdItem: itemToSave) { [weak self] success in
      guard let this = self else {
        return
      }
      XCTAssertTrue(success)
      this.localItemSavingService.isItemUsed(itemID: this.itemToSave.id) { isUsed in
        isItemUsed = isUsed
        XCTAssertEqual(isItemUsed, false)
        expect3.fulfill()
        this.localItemSavingService.useItem(itemID: this.itemToSave.id) { success in
          guard success else {
            XCTFail()
            return
          }
          expect2.fulfill()
          this.localItemSavingService.isItemUsed(itemID: this.itemToSave.id) { isUsed in
            isItemUsed = isUsed
            expect.fulfill()
          }
        }
      }
    }
    waitForExpectations(timeout: 10, handler: nil)
    XCTAssertEqual(isItemUsed, true)
  }
  
  func testUsedFromTwoItems() {
    let expect = expectation(description: "waitForDatabase5")
    let expect2 = expectation(description: "waitForDatabase6")
    let expect3 = expectation(description: "waitForDatabase7")
    var annotatedItems = [AnnotatedItem]()
    localItemSavingService.saveItem(nerdItem: itemToSave) { [weak self] success in
      XCTAssertTrue(success)

      guard let this = self else {
        XCTFail()
        return
      }
      expect2.fulfill()
      this.localItemSavingService.saveItem(nerdItem: this.itemToSave2) { success in
        XCTAssertTrue(success)
        expect3.fulfill()
        this.localItemSavingService.getAnnotatedItems(itemState: .isUsed) { items in
          annotatedItems = items
          expect.fulfill()
        }
      }
    }
    
    waitForExpectations(timeout: 10, handler: nil)
    guard let annotatedItem = annotatedItems.first else {
      XCTFail()
      return
    }
    
    XCTAssertEqual(itemToSave2.name, annotatedItem.item.name, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave2.itemDescription, annotatedItem.item.itemDescription, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave2.id, annotatedItem.item.id, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave2.rarity, annotatedItem.item.rarity, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave2.dateAdded, annotatedItem.item.dateAdded, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave2.isUsed, true, "Item retrieved should match originally inserted item")
  }
  
  func testUnusedFromTwoItems() {
    let expect = expectation(description: "waitForDatabase8")
    let expect2 = expectation(description: "waitForDatabase9")
    let expect3 = expectation(description: "waitForDatabase10")

    var annotatedItems = [AnnotatedItem]()
    localItemSavingService.saveItem(nerdItem: itemToSave) { [weak self] success in
      XCTAssertTrue(success)
      guard let this = self else {
        XCTFail()
        return
      }
      expect2.fulfill()
      this.localItemSavingService.saveItem(nerdItem: this.itemToSave2) { success in
        XCTAssertTrue(success)
        expect3.fulfill()
        this.localItemSavingService.getAnnotatedItems(itemState: .notUsed) { items in
          annotatedItems = items
          expect.fulfill()
        }
      }
    }
    
    waitForExpectations(timeout: 10, handler: nil)
    guard let annotatedItem = annotatedItems.first else {
      XCTFail()
      return
    }
    
    XCTAssertEqual(itemToSave.name, annotatedItem.item.name, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave.itemDescription, annotatedItem.item.itemDescription, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave.id, annotatedItem.item.id, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave.rarity, annotatedItem.item.rarity, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave.dateAdded, annotatedItem.item.dateAdded, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave.isUsed, false, "Item retrieved should match originally inserted item")
  }
  
  func testGetItemByName() {
    let expect = expectation(description: "waitForDatabase11")
    let expect2 = expectation(description: "waitForDatabase12")
    let expect3 = expectation(description: "waitForDatabase13")
    let expect4 = expectation(description: "waitForDatabase14")
    var annotatedItem: AnnotatedItem?
    localItemSavingService.saveItem(nerdItem: itemToSave) { [weak self] success in
      XCTAssertTrue(success)
      
      guard let this = self else {
        XCTFail()
        return
      }
      expect2.fulfill()
      this.localItemSavingService.saveItem(nerdItem: this.itemToSave2) { success in
        XCTAssertTrue(success)
        expect3.fulfill()
        this.localItemSavingService.saveItem(nerdItem: this.itemToSave3) { success in
          XCTAssertTrue(success)
          expect4.fulfill()
          this.localItemSavingService.getItem(itemName: "Crowbar") { item in
            annotatedItem = item
            expect.fulfill()
          }
        }
      }
    }
    waitForExpectations(timeout: 10, handler: nil)
    guard let unwrappedAnnotatedItem = annotatedItem else {
      XCTFail()
      return
    }
    
    XCTAssertEqual(itemToSave3.name, unwrappedAnnotatedItem.item.name, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave3.itemDescription, unwrappedAnnotatedItem.item.itemDescription, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave3.id, unwrappedAnnotatedItem.item.id, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave3.rarity, unwrappedAnnotatedItem.item.rarity, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave3.dateAdded, unwrappedAnnotatedItem.item.dateAdded, "Item retrieved should match originally inserted item")
    XCTAssertEqual(itemToSave3.isUsed, unwrappedAnnotatedItem.item.isUsed, "Item retrieved should match originally inserted item")
  }
  
  func testGetRandomItem() {
    let expect = expectation(description: "waitForDatabase15")
    let expect2 = expectation(description: "waitForDatabase16")
    let expect3 = expectation(description: "waitForDatabase17")
    let expect4 = expectation(description: "waitForDatabase18")
    var annotatedItem: AnnotatedItem?
    
    localItemSavingService.saveItem(nerdItem: itemToSave) { [weak self] success in
      XCTAssertTrue(success)
      
      guard let this = self else {
        XCTFail()
        return
      }
      expect2.fulfill()
      this.localItemSavingService.saveItem(nerdItem: this.itemToSave2) { success in
        XCTAssertTrue(success)
        expect3.fulfill()
        this.localItemSavingService.saveItem(nerdItem: this.itemToSave4) { success in
          XCTAssertTrue(success)
          expect4.fulfill()
          this.localItemSavingService.getRandomItem(itemType: .weapon) { item in
            annotatedItem = item
            expect.fulfill()
          }
        }
      }
    }
    waitForExpectations(timeout: 10, handler: nil)
    guard let unwrappedAnnotatedItem = annotatedItem else {
      XCTFail()
      return
    }
    XCTAssertEqual(itemToSave4.name, unwrappedAnnotatedItem.item.name, "Item retrieved should match originally inserted weapon")
    XCTAssertEqual(itemToSave4.itemDescription, unwrappedAnnotatedItem.item.itemDescription, "Item retrieved should match originally inserted weapon")
    XCTAssertEqual(itemToSave4.id, unwrappedAnnotatedItem.item.id, "Item retrieved should match originally inserted weapon")
    XCTAssertEqual(itemToSave4.rarity, unwrappedAnnotatedItem.item.rarity, "Item retrieved should match originally inserted weapon")
    XCTAssertEqual(itemToSave4.dateAdded, unwrappedAnnotatedItem.item.dateAdded, "Item retrieved should match originally inserted weapon")
    XCTAssertEqual(itemToSave4.isUsed, unwrappedAnnotatedItem.item.isUsed, "Item retrieved should match originally inserted weapon")
  }
  
  func testRandomItemGetsWeaponWhenNoBuff() {
    let expect = expectation(description: "waitForDatabase15")
    let expect2 = expectation(description: "waitForDatabase16")
    let expect3 = expectation(description: "waitForDatabase17")
    let expect4 = expectation(description: "waitForDatabase18")
    var annotatedItem: AnnotatedItem?
    
    localItemSavingService.saveItem(nerdItem: itemToSave) { [weak self] success in
      XCTAssertTrue(success)
      
      guard let this = self else {
        XCTFail()
        return
      }
      expect2.fulfill()
      this.localItemSavingService.saveItem(nerdItem: this.itemToSave2) { success in
        XCTAssertTrue(success)
        expect3.fulfill()
        this.localItemSavingService.saveItem(nerdItem: this.itemToSave4) { success in
          XCTAssertTrue(success)
          expect4.fulfill()
          this.localItemSavingService.getRandomItem(itemType: .weapon) { item in
            annotatedItem = item
            expect.fulfill()
          }
        }
      }
    }
    waitForExpectations(timeout: 10, handler: nil)
    guard let unwrappedAnnotatedItem = annotatedItem else {
      XCTFail()
      return
    }
    
    XCTAssertEqual(unwrappedAnnotatedItem.annotation?.itemType, .weapon, "Item should be a weapon")

  }
  
  func testRandomItemGetsBuffWhenNoWeapon() {
    
  }
}
