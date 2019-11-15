//
//  File.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 4/3/17.
//  Copyright © 2017 Meltwater. All rights reserved.
//

import UIKit

public class MWStyles {
    
    static let singleton = MWStyles()
    var styleMap:Dictionary <String, Any> = [:]

    static var mwBundle: Bundle {
        let podBundle = Bundle(for: MWStyles.self)
        
        if let bundleURL = podBundle.url(forResource: "MeltwaterKit", withExtension: "bundle") {
            // Find the location of the MeltwaterKit storyboard
            return Bundle(url: bundleURL)!
        }
        else {
            // In case this is included in the main bundle like the case of MeltwaterKitDemo
            return Bundle.main
        }
    }
    
    init?() {
        
        guard let path = Bundle.main.path(forResource: "CustomProperties", ofType: "plist") else {
            return nil
        }
        
        let map = NSDictionary(contentsOfFile: path) as! Dictionary<String, Any>
        
        let theme =  map["THEME_NAME"] as! String
        
        if let path = MWStyles.mwBundle.path(forResource: theme, ofType: "plist") {
            styleMap = NSDictionary(contentsOfFile: path) as! Dictionary<String, Any>
        }
    }
    
    public func getStyleProperty<T>( forKey key:String ) -> T {
        return styleMap[key] as! T
    }
    
    public func getColorFromRGB(rgbArray: [Int] ) -> UIColor {
         return UIColor(red: (CGFloat(rgbArray[0])/255.0), green: (CGFloat(rgbArray[1])/255.0), blue: (CGFloat(rgbArray[2])/255.0), alpha: 1.0)
    }
    
    public static func MWAqua() -> UIColor {
        return UIColor.init(red:0.16, green:0.73, blue:0.73, alpha:1.0)
    }
    
    public static func MWBorderGray() -> UIColor {
        return UIColor.init(red: 200.0/255.0, green: 199.0/255.0, blue: 204.0/255.0, alpha: 1.0)
    }
}
