//
//  MWUserDefaults.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 11/3/19.
//  Copyright © 2019 Meltwater. All rights reserved.
//

import Foundation
import ObjectMapper

public class MWUserDefaults {
    public class func saveMappableObject(obj: Mappable, key: String) {
        let serialized = obj.toJSONString()
        UserDefaults.standard.set(serialized, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    public class func getObjectJsonString(key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
    public class func getMappableObject<T:Mappable>(forKey key: String, type:T.Type) -> T? {
        if let json = MWUserDefaults.getObjectJsonString(key: key) {
            return type.init(JSONString: json)
        }
        return nil
    }
}
