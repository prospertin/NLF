//
//  UserModel.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 11/1/19.
//  Copyright © 2019 Meltwater. All rights reserved.
//

import Foundation
import ObjectMapper

public struct UserModel: Mappable {
    
    var id = ""
    var firstName = ""
    var lastName = ""
    var email = ""
    var activeCompanyId = ""
    var timezone = ""
    var language = ""
    var isInternal = false
    var appSettings:[String: Any] = [:]
    
    public init?(map: Map){}
    
    mutating public func mapping(map: Map) {
        id              <- map["_id"]
        firstName       <- map["firstName"]
        lastName        <- map["lastName"]
        email           <- map["email"]
        activeCompanyId <- map["activeCompanyId"]
        timezone        <- map["timezone"]
        isInternal      <- map["isInternal"]
        appSettings     <- map["appSettings"]
    }
}
