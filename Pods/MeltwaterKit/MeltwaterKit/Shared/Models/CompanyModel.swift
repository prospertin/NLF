//
//  CompanyModel.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 11/1/19.
//  Copyright © 2019 Meltwater. All rights reserved.
//

import Foundation
import ObjectMapper

public struct CompanyModel: Mappable {
    
    var id = ""
    var name = ""
    var accountId = ""
    var country = ""
    var opportunityId = ""
    
    public init?(map: Map) {
        
    }
    
    mutating public func mapping(map: Map) {
        id            <- map["_id"]
        name          <- map["name"]
        accountId     <- map["accountId"]
        country       <- map["country"]
        opportunityId <- map["opprotunity"]
    }
}
