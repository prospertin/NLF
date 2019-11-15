//
//  EnrichmentProtocol.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 3/7/18.
//  Copyright © 2018 Meltwater. All rights reserved.
//

import Foundation

public protocol EnrichmentProtocol {
    func process(data:[Any], params:[String:Any]?) -> Any?
}
