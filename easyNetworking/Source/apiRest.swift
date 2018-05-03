//
//  apiRest.swift
//  easyNetworking
//
//  Created by IOS Developer on 1/18/18.
//  Copyright © 2018 javff. All rights reserved.
//


import Foundation
import Alamofire
import ObjectMapper



//MARK: define type Alias //

public typealias RefreshCompletion = (_ succeeded: Bool) -> Void


/**
 IMPLEMENT apiRestDelegate for handler Ouath2Flow
 */

@objc public protocol ApiRestDelegate: class{
    
    /**
     adapter for add headers authorization
     */
    @objc func adapter(urlRequest: URLRequest) -> URLRequest
    
    /**
     implement refresh token authorization, executed when recivied status 401 default
     */
    
     @objc  func refreshToken(completion: @escaping RefreshCompletion)
   
    /**
     exectue when fail connection internet
     */
     @objc optional func handlerConnectionInternet()

    /**
     exectue when expired session
     */
    @objc optional func handlerExpiredSession()

}


/**
    Simple extension HttpRequest 
 */

public class ApiRest{
    
    // MARK: define attrs //

    
   public var delegate: ApiRestDelegate?
    
    // Instance singleton
    
    public static let shared = ApiRest()
    
    private init(){}
    
    internal var requestsToRetry: [RequestRetryCompletion] = []
    internal let lock = NSLock()
    internal var isRefreshing = false
    
    /** Configurar status code http para ejecucion del refresh token , default 401 */
    public var refreshStatus = 401
    
    
    // MARK: implement PUBLIC methods //

    /**
    
     DO HTTP REQUEST WITH GENERIC OBJECT RESPONSE, is necessary pass Correctly Object Type
     
    */

     public func doRequestObject <T : BaseMappable> (_ type: T.Type,withAuthorization authorization:Bool = false , httpMethod:HTTPMethod, url: String, headers: [String : String]?,  parameters: Mappable?, callback: @escaping (T?,ErrorModel?) ->  Void)  {
        
        
        let sessionManager = Alamofire.SessionManager.default
        let endpoint = URL(string: url)!
        var request = URLRequest(url: endpoint)
        
        
        request.httpMethod = httpMethod.rawValue
        request.allHTTPHeaderFields = headers
        
        if parameters != nil{
            
            if headers?["Content-Type"]?.lowercased() == "application/x-www-form-urlencoded"{
                
                request = try! URLEncoding().encode(request, with: parameters?.toJSON())
                
            }else{
                
                let pjson = parameters?.toJSONString(prettyPrint: false)
                let data = (pjson?.data(using: .utf8))! as Data
                request.httpBody = data
            }
        }

        request.timeoutInterval = 10
        
        if authorization{
            sessionManager.retrier = self
            sessionManager.adapter = self
        }else{
            sessionManager.retrier = nil
            sessionManager.adapter = nil
        }
        
        sessionManager.request(request).validate().debugLog().responseJSON { (response) in
            
            if let error = response.error {
                
                if error._code == NSURLErrorTimedOut || error._code == NSURLErrorNetworkConnectionLost || error._code == NSURLErrorNotConnectedToInternet{
                    
                    print("Time Out/Connection Lost Error")
                    // call delegate conenction internet //
                    self.delegate?.handlerConnectionInternet?()
                    
                    let errorModel = ErrorModel(errorType: ECallBackErrorType.NoInternetConnection)
                    callback(nil,errorModel)
                    return
                }
            }
            
            guard let safeResponse = response.response else{
                
                let errorModel = ErrorModel(errorType: ECallBackErrorType.UnknownError)
                callback(nil,errorModel)
                return
            }
            
            let status = safeResponse.statusCode
            let handlerCallback = self.handlerStatusWithObject(T.self,status: status, response: response)
            
            callback(handlerCallback.0,handlerCallback.1)
        }
        
    }
    
    public func doRequestJSON(withAuthorization authorization:Bool = false , httpMethod:HTTPMethod, url: String, headers: [String : String]?,  parameters: Mappable?, callback: @escaping ([String:Any],ErrorModel?,Int) ->  Void)  {
        
        let sessionManager = Alamofire.SessionManager.default
        let endpoint = URL(string: url)!
        var request = URLRequest(url: endpoint)
        request.httpMethod = httpMethod.rawValue
        request.allHTTPHeaderFields = headers
        
        if parameters != nil{
            
            if headers?["Content-Type"]?.lowercased() == "application/x-www-form-urlencoded"{
                
                request = try! URLEncoding().encode(request, with: parameters?.toJSON())
                
            }else{
                
                let pjson = parameters?.toJSONString(prettyPrint: false)
                let data = (pjson?.data(using: .utf8))! as Data
                request.httpBody = data
            }
        }
        
        request.timeoutInterval = 10
        
        if authorization{
            sessionManager.retrier = self
            sessionManager.adapter = self
        }else{
            sessionManager.retrier = nil
            sessionManager.adapter = nil
        }
        
        sessionManager.request(request).validate().debugLog().responseJSON { (response) in
            
            if let error = response.error {
                
                if error._code == NSURLErrorTimedOut || error._code == NSURLErrorNetworkConnectionLost || error._code == NSURLErrorNotConnectedToInternet{
                    
                    print("Time Out/Connection Lost Error")
                    // call delegate conenction internet //
                    self.delegate?.handlerConnectionInternet?()
                    
                    let errorModel = ErrorModel(errorType: ECallBackErrorType.NoInternetConnection)
                    callback([:],errorModel,-1)
                    return
                }
            }
            
            
            guard let safeResponse = response.response else{
                
                let errorModel = ErrorModel(errorType: ECallBackErrorType.UnknownError)
                callback([:],errorModel,-1)
                return
            }
            
            let status = safeResponse.statusCode
            let handlerCallback = self.handlerStatusWithJSON(status: status, response: response)
            
            callback(handlerCallback.0,handlerCallback.1,handlerCallback.2)
        }
    }
    
    
    // MARK: implement PRIVATE methods //

    private func handlerStatusWithObject <T : BaseMappable> (_ type: T.Type, status:Int , response: DataResponse<Any>) -> (T?,ErrorModel?) {
        
        
        switch status {
            
        case 200..<300:
         
            if let responseObject = Mapper<T>().map(JSONObject: response.result.value){
                
                return(responseObject,nil)
            }
            
            assert(false, "Tipo generico T no puede ser mapeado verifique el modelo")
            
        case 300..<600:

            let errorModel = self.createErrorModel(status: status, response: response)
            return (nil,errorModel)
        
        default:
           
            let errorModel = ErrorModel(errorType: ECallBackErrorType.UnknownError)
            return(nil,errorModel)
        }
        
        let errorModel = ErrorModel(errorType: ECallBackErrorType.UnknownError)
        return(nil,errorModel)
    }
    
    
    private func handlerStatusWithJSON(status:Int , response: DataResponse<Any>) -> ([String:Any],ErrorModel?,Int) {
        
        switch status {
            
        case 200..<300:
            
            guard let json = response.result.value as? [String : Any] else {
                return ([:],nil,status)
            }
            
            return (json,nil,status)
            
            
        case 300..<600:
            
            let errorModel = self.createErrorModel(status: status, response: response)
            
            return ([:],errorModel,status)
            
        default:
            
            let errorModel = ErrorModel(errorType: ECallBackErrorType.UnknownError)
            return ([:],errorModel,status)
        }
        
    }
    
    

    
    private func createErrorModel(status: Int,response: DataResponse<Any>) -> ErrorModel{
        
        var body: String!
        
        body = String(data:response.data!,encoding:String.Encoding.utf8)
        
        // Console error log //
        
        debugPrint(body)
        
        var errorType: ECallBackErrorType!
        
        //MARK: DEFINIMOS EL TIPO DE ERROR SEGUN SEA EL CODIGO HTTP //
        
        switch status{
            
        case 400:
            errorType = ECallBackErrorType.BadRequest(body!)
        case 401:
            
            errorType = ECallBackErrorType.NotAuthorized(body!)
        case 403:
            errorType = ECallBackErrorType.Forbidden(body!)
        case 404:
            errorType = ECallBackErrorType.NotFound(body!)
        case 409:
            errorType = ECallBackErrorType.Conflict(body!)
        case 500..<600:
            errorType = ECallBackErrorType.InternalServerError(body!)
        default:
            errorType = ECallBackErrorType.UnknownError
        }
        return ErrorModel(body: body!, statusCode: status, errorType: errorType)
    }
}

//MARK: IMPLEMENT RequestAdapter and RequestRetier //

extension ApiRest: RequestAdapter, RequestRetrier{
    
    public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        
        return (self.delegate?.adapter(urlRequest: urlRequest))!
        
    }
    
    public func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        
        lock.lock() ; defer { lock.unlock() }
        
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == self.refreshStatus {
            
            requestsToRetry.append(completion)
            
            if !isRefreshing {
                
                self.delegate?.refreshToken(completion: { [weak self] succeeded in
                    
                    guard let strongSelf = self else { return }
                    
                    strongSelf.lock.lock() ; defer{ strongSelf.lock.unlock()}
                    
                    if succeeded{
                        // refresh success //
                        strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                        strongSelf.requestsToRetry.removeAll()
                        return
                    }
                    
                   //if fail expired session
                    strongSelf.delegate?.handlerExpiredSession?()
                })
            }
            
        } else {
            // dont need refresh
            completion(false, 0.0)
        }
    }
}
