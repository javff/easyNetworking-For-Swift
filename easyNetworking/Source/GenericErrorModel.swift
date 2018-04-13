//
//  GenericErrorModel.swift
//  easyNetworking
//
//  Created by IOS Developer on 4/12/18.
//  Copyright © 2018 javff. All rights reserved.
//

import Foundation
import ObjectMapper

public class ErrorModel: Mappable{
    
   public var body = ""
   public var statusCode: Int!
    public var errorType: ECallBackErrorType!
    
    
 
    public  init(body bodyError:String = "", statusCode statusError: Int = -1, errorType error: ECallBackErrorType = ECallBackErrorType.UnknownError){
        
        self.body = bodyError
        self.statusCode = statusError
        self.errorType = error
    }
    
   public required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        
    }
    
    public func toObjectModel<T: BaseMappable> () -> T? {
        
        let object = Mapper<T>().map(JSONObject: self.body)
        return object
    }
    
}
