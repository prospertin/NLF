//
//  RefreshTokenError.swift
//  MeltwaterKit
//
//  Created by Arturo Gamarra on 8/30/18.
//  Copyright © 2018 Meltwater. All rights reserved.
//

import Foundation

public enum AuthTokenError: Error {
    
    case unauthorized
    case forbidden
    case other(String)
    
    public init(code:Int, message:String) {
        switch code {
        case 401:
            self = .unauthorized
        case 403:
            self = .forbidden
        default:
            self = .other(message)
        }
    }
}

// MARK: - CustomNSError
extension AuthTokenError: CustomNSError {
    
    public var errorCode: Int {
        switch self {
        case .unauthorized:
            return 401
        case .forbidden:
            return 403
        default:
            return 499
        }
    }
    
    public var errorUserInfo: [String : Any] {
        var message = ""
        switch self {
        case .unauthorized:
            message = "User is unauthorized - good token but cannot retrieve user"
        case .forbidden:
            message = "User is (Forbidden - bad token, deleted or blocked"
        case .other(let errorMessage):
            message = errorMessage
        }
        return [NSLocalizedDescriptionKey: message]
    }
    
}
