//
//  KeychainProtocol.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 2/19/18.
//  Copyright © 2018 Meltwater. All rights reserved.
//

import Foundation

public protocol KeychainProtocol: class {
    func saveToken(token: String)
    func loadToken() -> String?
}
