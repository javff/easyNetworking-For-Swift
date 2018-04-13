//
//  easyNetworkingTests.swift
//  easyNetworkingTests
//
//  Created by IOS Developer on 4/12/18.
//  Copyright © 2018 javff. All rights reserved.
//

import XCTest
import easyNetworking
import ObjectMapper

class TestingModel: Mappable{
    
    required init?(map: Map) {
       
        if map.JSON["nonce"] == nil {
            return nil
        }
    }
    
    func mapping(map: Map) {
        
    }
}



class easyNetworkingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        
        let expectation =  XCTestExpectation(description: "testing http request")

        ApiRest.shared.doRequestJSON(httpMethod: .get, url: "https://apihostit.technifiser.com/v1/countries", headers: ["Content-Type":"application/json"], parameters: nil) { (json, error ,status) in
            
            
            print("hola")
            expectation.fulfill()

        }
        
        wait(for: [expectation], timeout: 10.0)

    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
