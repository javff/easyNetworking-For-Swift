//
//  apiRestProtocol.swift
//  easyNetworking
//
//  Created by IOS Developer on 10/13/17.
//  Copyright © 2018 javff. All rights reserved.
//

import Alamofire
import UIKit
import AlamofireObjectMapper


//MARK: DEBUG LOG

extension Request {
    public func debugLog() -> Self {
        debugPrint("=======================================")
        debugPrint(self)
        debugPrint("=======================================")
        return self
    }
}

