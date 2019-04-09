//
//  Milestone1Tests.swift
//  Milestone1Tests
//
//  Created by Alistair Brice on 9/4/19.
//  Copyright © 2019 Alistair Brice. All rights reserved.
//

import XCTest
@testable import Milestone1

class Milestone1Tests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    func testObjectDefinition() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let name = "Brisbane"
        let address = "Games"
        let latitude = 5.0
        let longitute = 40.0
        
        let place = ObjectDefinition(name: name, address:address, latitude:latitude, longitude:longitute)
        XCTAssertEqual(place.name, name)
        XCTAssertEqual(place.address, address)
        XCTAssertEqual(place.latitude, latitude)
        XCTAssertEqual(place.longitude, longitute)
    }
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
