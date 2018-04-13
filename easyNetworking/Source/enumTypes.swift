//
//  enumTypes.swift
//  easyNetworking
//
//  Created by IOS Developer on 3/6/18.
//  Copyright © 2018 javff. All rights reserved.
//

import Foundation
import Alamofire

// Response Alamofire callbacks

public enum ECallbackResultType<T> {
    
    case Success(T)
    
}


public enum ECallBackErrorType{
    
    // Error Without body //
    
    case UnknownError
    case NoInternetConnection
    
    // Error with body //
    
    case NotFound(String) // http 404 not found
    case BadRequest(String) // invalid http 400
    case NotAuthorized(String) // Access invalid 401
    case InternalServerError(String) //500
    case Conflict(String) //409
    case Forbidden(String)// 403
    
}

