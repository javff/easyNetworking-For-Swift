//
//  TypeExtension.swift
//  easyNetworking
//
//  Created by IOS Developer on 4/12/18.
//  Copyright © 2018 javff. All rights reserved.
//

import Foundation



extension Dictionary {
    
    
    
    var queryString: String {
        var output = ""
        for (key,value) in self {
            output +=  "\(key)=\(value)&"
        }
        output = String(output.dropLast())
        return output
    }
    
    
    
}
