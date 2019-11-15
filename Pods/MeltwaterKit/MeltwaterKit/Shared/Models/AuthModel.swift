//
//  AuthProfile.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 5/23/17.
//  Copyright © 2017 Meltwater. All rights reserved.
//

import Foundation

@objc
public class AuthResult: NSObject {
    public var authToken: AuthToken?
    public var error: Error?
    
    public init(authToken: AuthToken? = nil, error: Error? = nil) {
        self.authToken = authToken
        self.error = error
    }
}

@objc
public class AuthToken: NSObject {
    public var idToken: String?
    public var refreshToken: String?
    
    public init(idToken: String, refreshToken: String?) {
        self.idToken = idToken
        self.refreshToken = refreshToken
    }
}
