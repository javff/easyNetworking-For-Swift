//
//  easyNetworkingTests.swift
//  easyNetworkingTests
//
//  Created by IOS Developer on 4/12/18.
//  Copyright © 2018 javff. All rights reserved.
//

import XCTest
import ObjectMapper
import easyNetworking


class loginModel:Mappable{
    
    var username = ""
    var password = ""
    var client_id = ""
    var client_secret = ""
    var scope = ""
    var grant_type = ""
    
    required init?(map:Map){
    }
    
    
    init(username:String,password:String,clientId: String, clientSecret:String){
        
        self.grant_type = "password"
        self.scope = "offline_access profile email"
        self.username = username
        self.password = password
        self.client_id = clientId
        self.client_secret = clientSecret
        
    }
    
    
    init(grantType:String, clientId:String, clientSecret:String){
        
        self.grant_type = grantType
        self.scope = "offline_access profile email"
        self.client_id = clientId
        self.client_secret = clientSecret
        
    }
    
    func mapping(map: Map) {
        
        username <- map["username"]
        password <- map["password"]
        client_id <- map["client_id"]
        client_secret <- map["client_secret"]
        scope <- map["scope"]
        grant_type <- map["grant_type"]
        
    }
}


class TokenModel:Mappable{
    
    var token_type = ""
    var access_token = ""
    var expires_in = ""
    var refresh_token = ""
    
    
    required init?(map:Map){
    }
    
    init(access_token: String, refresh_token: String){
        
        self.access_token = access_token
        self.refresh_token = refresh_token
        
    }
    
    func mapping(map: Map) {
        
        token_type <- map["token_type"]
        access_token <- map["access_token"]
        expires_in <- map["expires_in"]
        refresh_token <- map["refresh_token"]
        
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
        
        
        
        let expectation = XCTestExpectation(description: "Get some sandwiches!")
        
        let endpoint = "http://192.168.2.50:5200/Auth/token"
        let params = loginModel(username: "juan.vasquez@technifiser.com", password: ".America1", clientId: "67926ee8f4fa4734ba9e5d1987e9d190", clientSecret: "fEEb3StA3YINz17ZNUf2X8kLDmP13F4qAX5GSclQaEjZTyuS2thFcIJpT1M6Y+glc0lb8rAEOIeSjZf3u7eyyg==")
        let headers: [String:String] = [
            "Content-Type" : "application/x-www-form-urlencoded"
        ]
        
        ApiRest.shared.doRequestObject(TokenModel.self, httpMethod: .post, url: endpoint, headers: headers, parameters: params) { (response, error) in
            
            if error != nil{
                
                return
            }
            // save tokens //
            print("save")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)


    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func LoginTask(username:String, password:String
        ){
        
        let endpoint = "http://192.168.2.50:5200/Auth/token"
        let params = loginModel(username: username, password: password, clientId: "67926ee8f4fa4734ba9e5d1987e9d190", clientSecret: "fEEb3StA3YINz17ZNUf2X8kLDmP13F4qAX5GSclQaEjZTyuS2thFcIJpT1M6Y+glc0lb8rAEOIeSjZf3u7eyyg==")
        let headers: [String:String] = [
            "Content-Type" : "application/x-www-form-urlencoded"
        ]
        
        ApiRest.shared.doRequestObject(TokenModel.self, httpMethod: .post, url: endpoint, headers: headers, parameters: params) { (response, error) in
            
            if error != nil{
                
                return
            }
            
            // save tokens //
                print("save")
        }
        
    }
    
}
