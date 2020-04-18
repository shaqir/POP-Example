//
//  POP_ExampleTests.swift
//  POP ExampleTests
//
//  Created by Sakir Saiyed on 18/04/20.
//  Copyright © 2020 Sakir Saiyed. All rights reserved.
//

import XCTest
@testable import POP_Example

class POP_ExampleTests: XCTestCase {

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

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testOpenWeatherMap() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let exp = expectation(description: "Get weather data")
        
        let controller = OpenWeatherMapNetworkController()
        let backupcontroller = ApixuNetworkController()
        let city = "Carpinteria"
        backupcontroller.self.fetchCurrentWeatherData(city: city) { (weatherData, error) in
            XCTAssertNil(error, "fetchWeatherData() call returned error: \(error?.localizedDescription ?? "")")
            if let data = weatherData {
                print("Weather in \(city): \(data.condition), \(data.temperature)\(data.unit)")
                exp.fulfill()
            } else {
                XCTFail("no data returned by fetchWeatherData()")
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }

}
