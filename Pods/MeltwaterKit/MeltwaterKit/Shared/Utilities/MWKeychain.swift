//
//  KeychainDemo.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 6/11/17.
//  Copyright © 2017 Meltwater. All rights reserved.
//

import Foundation
import Security

// Constant Identifiers
let serviceId = Bundle.main.bundleIdentifier! as NSString


/**
 *  User defined keys for new entry
 *  Note: add new keys for new secure item and use them in load and save methods
 */

let tokenKey = "TokenKey"
let refreshTokenKey = "RefreshTokenKey"
let tokenTypeKey = "TokenTypeKey"
let expiresKey = "ExpiresKey"

// Arguments for the keychain queries
let kSecClassValue = NSString(format: kSecClass)
let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
let kSecValueDataValue = NSString(format: kSecValueData)
let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
let kSecAttrServiceValue = NSString(format: kSecAttrService)
let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
let kSecReturnDataValue = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)

public class MWKeychain: NSObject {
    
    /**
     * Exposed methods to perform save and load queries.
     */
    
    public class func saveToken(token: String) {
        if loadToken() != nil {
            updateToken(token: token)
        } else {
            save(key: tokenKey, data: token)
        }
    }
    
    public class func loadToken() -> String? {
        return self.load(key: tokenKey)
    }
    
    public class func updateToken(token: String) {
        self.update(key: tokenKey, data: token)
    }
    
    
    public class func saveRefreshToken(token: String) {
        if loadRefreshToken() != nil {
            updateRefreshToken(token: token)
        } else {
            save(key: refreshTokenKey, data: token)
        }
    }
    
    
    public class func loadRefreshToken() -> String? {
        return self.load(key: refreshTokenKey)
    }
    
    public class func updateRefreshToken(token: String) {
        self.update(key: refreshTokenKey, data: token )
    }
    
    public class func getSharedToken() {
//        UICKeyChainStore
    }
   
    public class func saveTokenType(tokenType: String) {
        if loadTokenType() != nil {
            updateTokenType(tokenType: tokenType)
        } else {
            save(key: tokenTypeKey, data: tokenType)
        }
    }
    
    public class func loadTokenType() -> String? {
        return self.load(key: tokenTypeKey)
    }
    
    public class func updateTokenType(tokenType: String) {
        self.update(key: tokenTypeKey, data: tokenType )
    }
    
    public class func saveExpires(expires: String) {
        if loadExpires() != nil {
            updateExpires(expires: expires)
        } else {
            save(key: expiresKey, data: expires)
        }
    }
    
    public class func updateExpires(expires: String) {
        self.update(key: expiresKey, data: expires)
    }
    
    public class func loadExpires() -> String? {
        return self.load(key: expiresKey)
    }
    
    public class func deleteToken() {
        delete(key: tokenKey)
    }
    
    public class func deleteRefreshToken() {
        delete(key: refreshTokenKey)
    }
    /**
     * Internal methods for querying the keychain.
     */
    
    private class func save(key: String, data: String) {
     
        let desiredString = data as NSString
        let dataFromString: NSData = desiredString.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)! as NSData
        
        // Instantiate a new default keychain query
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, serviceId, key as NSString, dataFromString], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])
        
        // Add the new keychain item
        let status = SecItemAdd(keychainQuery as CFDictionary, nil)
        
        if (status != errSecSuccess) {    // Always check the status
            print("Write failed: Attempting update.")
            updateToken(token: data)
        }
    }
    
    private class func load(key: String) -> String? {
        // Instantiate a new default keychain query
        // Tell the query to return a result
        // Limit our results to one item
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, serviceId, key as NSString, kCFBooleanTrue, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])
        
        var dataTypeRef :AnyObject?
        
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? NSData {
                if let contentsOfKeychain = NSString(data: retrievedData as Data, encoding: String.Encoding.utf8.rawValue){
                    return contentsOfKeychain as String
                }
            }
        }
        
        return nil
    }
    
    private class func update(key: String, data: String) {
        let desiredString = data as NSString
        let dataFromString: NSData = desiredString.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)! as NSData
        
        // Instantiate a new default keychain query
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, serviceId, key as NSString], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue])
        
        let status = SecItemUpdate(keychainQuery as CFDictionary, [kSecValueDataValue:dataFromString] as CFDictionary)
        
        if (status != errSecSuccess) {
            print("Update failed \(status)")
        }
    }
    
    private class func delete(key: String) {
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, serviceId, key as NSString], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue])
        
        let status = SecItemDelete(keychainQuery as CFDictionary)
        
        if (status != errSecSuccess) {
            print("Update failed \(status)")
        }
    }
    
}
