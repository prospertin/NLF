//
//  MWEnrichment.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 3/13/18.
//  Copyright © 2018 Meltwater. All rights reserved.
//

import Foundation

public class MWEnrichment {
    
    class public func standardDeviation<T>(forList list: [T], getValue: (T) -> Double ) -> Double {
        var sum = 0.0
        let len = list.count
        
        if len <= 1 {
            return 0.0
        }
        list.forEach( { e in
            sum += getValue(e)
        })
        
        let mean = sum / Double(len)
        sum = 0
        list.forEach({ e in
            sum += pow(getValue(e) - mean, 2)
        })
        
        return sqrt(sum/Double(len - 1))
    }
    
}
