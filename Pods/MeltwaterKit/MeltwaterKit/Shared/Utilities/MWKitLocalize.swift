//
//  MWKitLocalizable.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 7/3/17.
//  Copyright © 2017 Meltwater. All rights reserved.
//

import Foundation

public class MWKitLocalize: NSObject{
    
    var langBundle:Bundle?
    
    static public let shared = MWKitLocalize()
    
    public func setLanguage(lang: String) {
        
        if let bundlePath = Bundle(for: MWKitLocalize.self).path(forResource: "MeltwaterKit", ofType: "bundle") {
            let bundle = Bundle(path: bundlePath) ?? Bundle.main
            langBundle = Bundle(path: (bundle.path(forResource: lang, ofType: "lproj"))!)
        }
        
    }
    
    public func localizedString(key: String, defaultEnglish:String, forClass: Swift.AnyClass) -> String {
        
        if let bd = langBundle {
            let str = NSLocalizedString(key, tableName: "MeltwaterKit", bundle: bd, comment: "")
            if str != key {
                return str
            }
        }
        
        return defaultEnglish
    }
    
    public func LocalizeWithDefault(_ key:String, comment:String = "") -> String {
        let localString = NSLocalizedString(key, comment: comment)
        if localString != key {
            return localString
        }
        let bundle = MWTools.getBundle() ?? Bundle.main
        let fallbackString = bundle.localizedString(forKey: key, value: nil, table: nil)
        return fallbackString
    }
}
