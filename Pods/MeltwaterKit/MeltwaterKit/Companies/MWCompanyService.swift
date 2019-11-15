//
//  CompanyService.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 11/1/19.
//  Copyright © 2019 Meltwater. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire

public protocol CompanyResultProtocol: class {
    func onGetCompaniesSuccess(companies: [CompanyModel])
    func onCompanyServiceFailure(error: Error)
}

public class MWCompanyService {
    
    var mwAuthHost = "https://staging-backend.meltwater.net/"
      
    public init(authHost: String) {
        mwAuthHost = authHost
    }
    
    public func getCompaniesForUser(id: String, authToken: String, delegate: CompanyResultProtocol?) {
        
        let headers = ["Authorization" : authToken]
        Alamofire.request(mwAuthHost + AuthConstants.mwCompanyByUserPath + "/" + id, headers: headers).responseJSON { response in
            switch response.result{
            case .success:
                if let json = response.result.value as? [Any] {
                    let companies = Mapper<CompanyModel>().mapArray(JSONArray: json as! [[String : Any]])
                    if let del = delegate {
                        del.onGetCompaniesSuccess(companies: companies)
                    }
                } else {
                    if let del = delegate {
                        if let error = response.result.error {
                            del.onCompanyServiceFailure(error: error)
                        } else {
                            del.onGetCompaniesSuccess(companies: []) // No error and no data
                        }
                    }
                }
            case .failure(let error):
                if let del = delegate {
                    del.onCompanyServiceFailure(error: error)
                }
            }
        }
    }
}
