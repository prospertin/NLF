//
//  NLFModel.swift
//  NLF
//
//  Created by Thinh Nguyen on 10/5/19.
//  Copyright © 2019 Propertin. All rights reserved.
//

import Foundation
import ObjectMapper

struct LaureateModel: Mappable {
    
    var id = -1
    var category = ""
    var surname = ""
    var firstname = ""
    var motivation = ""
    var location = Coordinates(JSON: ["lat": 0.0, "lng": 0.0])
    var city = ""
    var year = ""
    var name = ""
    var country = ""
    
    public init?(map: Map) {}
    
    mutating public func mapping(map: Map) {
        id         <- map["id"]
        category   <- map["category"]
        surname    <- map["surname"]
        firstname  <- map["firstname"]
        motivation <- map["motivation"]
        location   <- map["location"]
        city       <- map["city"]
        year       <- map["year"]
        name       <- map["name"]
        country    <- map["country"]
    }
}

struct Coordinates: Mappable {
    
    var latitude = 0.0
    var longitude = 0.0
    
    public init?(map: Map) {}
    
    mutating public func mapping(map: Map) {
        latitude  <- map["lat"]
        longitude <- map["lng"]
    }
}
