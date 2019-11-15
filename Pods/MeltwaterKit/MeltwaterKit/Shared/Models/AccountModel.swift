//
//  AccountModel.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 11/1/19.
//  Copyright © 2019 Meltwater. All rights reserved.
//

import Foundation
import ObjectMapper

public struct AccountModel: Mappable {
    
    var user:UserModel?
    var company:CompanyModel?
    var token = ""
    var expires:Any? // Expires return different type for login and switch company so only convert to the correct type when using it.
    
    public init?(map: Map) {
        
    }

    mutating public func mapping(map: Map) {
        user    <- map["user"]
        company <- map["company"]
        token   <- map["token"]
        expires <- map["expires"]
    }
}
