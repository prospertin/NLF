//
//  RestClient.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 2/20/18.
//  Copyright © 2018 Meltwater. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

public class PromiseRestClient {
    
    public static var headers: HTTPHeaders = [
        "Authorization": "update",
        "Content-Type": "application/json"
    ]
    
    internal static func getFromUrl(urlString: String) -> Promise<NSDictionary> {
        
        return Promise { fulfill, reject in
            Alamofire.request(urlString).validate().responseJSON { response in
                switch response.result {
                case .success(let dict):
                    fulfill(dict as! NSDictionary)
                case .failure(let error):
                    reject(error)
                }
            }
        }
    }
    
    internal static func getFromUrl(urlString: String, parameters: Parameters? ) -> Promise<NSDictionary> {
        
        return Promise { fulfill, reject in
            Alamofire.request(urlString, parameters: parameters, headers: headers).validate().responseJSON { response in
                switch response.result {
                case .success(let dict):
                    fulfill(dict as! NSDictionary)
                case .failure(let error):
                    reject(error)
                }
            }
        }
    }
    
    internal static func getJsonFromUrl<T: Mappable>(urlString: String, payload: Parameters? ) -> Promise<T> {
        return Promise { fulfill, reject in
            Alamofire.request(urlString, method: .get, parameters: payload, headers: headers)
                .validate().responseObject { (response: DataResponse<T>) in
                    switch response.result {
                    case .success(let obj):
                        fulfill(obj )
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    
    internal static func postToUrl<T: Mappable>(urlString: String, payload: Parameters? ) -> Promise<T> {
        return Promise { fulfill, reject in
            Alamofire.request(urlString, method: .post, parameters: payload, encoding: JSONEncoding.default, headers: headers)
                .validate().responseObject { (response: DataResponse<T>) in
                    switch response.result {
                    case .success(let obj):
                        fulfill(obj )
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
}

