//
//  MWLoginManager.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 5/25/17.
//  Copyright © 2017 Meltwater. All rights reserved.
//

import UIKit
import Lock
import Auth0
import Alamofire
import SafariServices
import WebKit

@objc
public protocol AuthenticationResultProtocol: class {
    @objc optional func onAuthenticationSuccess(resultPayload: Dictionary<String, Any>)
    @objc optional func onAuthenticationFailure(error: Error)
}

public class MWLoginService: LoginService {

    var loginStateUUID:String?
    
    public init(authHost: String) {
        super.init()
        mwAuthHost = authHost
    }
    
    /**
     * Login using userId/password and return the Auth0 token
     */
    public override func loginWithUser(login: String, password: String) {

        let payload = [AuthConstants.reqParamEmail : login, AuthConstants.reqParamPassword : password]
        let headers:HTTPHeaders = ["Accept": "application/json"]

        Alamofire.request(mwAuthHost + AuthConstants.mwUsersAuthPath, method: .post, parameters: payload, encoding: JSONEncoding.default, headers: headers)
            .validate().responseJSON { response in
                switch response.result {
                case .success:
                    guard let data = response.result.value as? [String : AnyObject] else {
                        self.notifyUnauthorisedError(message: response.result.error?.localizedDescription ?? AuthConstants.resultUnknownError)
                        return
                    }
                    NotificationCenter.default.post(name: .loginResultNotification, object: nil, userInfo: data)

                case .failure(let error):
                    self.notifyUnauthorisedError(message: error.localizedDescription)
            }
        }
    }

    public override func openDeepLink(url: URL, sourceApplication: String?) -> Bool {
        let result = parseDeepLink(url: url)
        if let token = result[AuthConstants.auth0ResultIdToken] {
           // Login MW system
            self.loginWithAuthToken(bearerToken: token as! String, path: AuthConstants.mwUsersPath)
        } else {
            // Error, pass along
            NotificationCenter.default.post(name: .loginResultNotification, object: nil, userInfo: result)
        }
        return true
    }
    
    /**
     * Refresh token that are not OAuth2 token (like magic link token)
     */
    public override func refreshPasswordlessToken(refreshToken: String, refreshTokenDelegate: RefreshTokenProtocol?) {
        NSException(name: NSExceptionName(rawValue: "RefreshPasswordlessToken"), reason: "Not yet supported", userInfo: nil).raise()
    }
    
    /**
     * Refresh token that are OAuth2 token (when login with password)
     */
    public override func refreshToken(refreshToken: String, refreshTokenDelegate: RefreshTokenProtocol?, completion: completionHandler? = nil) {
        let headers = ["Authorization" : refreshToken]
        Alamofire.request(mwAuthHost + AuthConstants.mwUsersRefreshTokenPath, headers: headers).responseJSON { response in
            switch response.result{
            case .success:
                guard let data = response.result.value as? [String : AnyObject], let _ = data[AuthConstants.resultToken]  else {
                    self.notifyUnauthorisedError(message: response.result.error?.localizedDescription ?? AuthConstants.resultUnknownError)
                    if let del = refreshTokenDelegate, let error = response.result.error {
                        del.onRefreshTokenFailure?(error: error)
                    }
                    return
                }
                if let del = refreshTokenDelegate {
                    del.onRefreshToken?(resultPayload: data)
                }
            case .failure(let error):
                if let del = refreshTokenDelegate {
                    del.onRefreshTokenFailure?(error: error)
                }
            }
        }
    }
    /**
     * Temporary used to get a MW token from the Auth0 token from MobileBFF
     */
    fileprivate func loginWithAuthToken(bearerToken: String, path: String) {
        let headers = ["Authorization" : bearerToken, "AuthType" : "auth0"]
        Alamofire.request(mwAuthHost + path, headers: headers).responseJSON { response in
            switch response.result{
            case .success:
                guard let data = response.result.value as? [String : AnyObject], let _ = data[AuthConstants.resultToken]  else {
                    self.notifyUnauthorisedError(message: response.result.error?.localizedDescription ?? AuthConstants.resultUnknownError)
                    return
                }
                NotificationCenter.default.post(name: .loginResultNotification, object: nil, userInfo: data)
                
            case .failure(let error):
                self.notifyUnauthorisedError(message: error.localizedDescription)
            }
        }
    }
    
    /**
     * Start the SSO login flow.
     * - parameter email: user email
     * - parameter callback: callback taking (URL, Error) as paramaters
    **/
    public func loginWithSSO(email: String, callback:  @escaping (URL?, Error?) -> Void) {
        loginStateUUID = UUID().uuidString
        
        let payload = [AuthConstants.reqParamEmail : email, AuthConstants.reqParamState: loginStateUUID]
        let headers:HTTPHeaders = ["Accept": "application/json"]
        
        Alamofire.request(mwAuthHost + AuthConstants.mwUsersSSOIdp, method: .post, parameters: payload as Parameters, encoding: JSONEncoding.default, headers: headers)
            .validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let data = response.result.value as? [String : AnyObject],
                        let urlString = data[AuthConstants.resultLoginUrl] as? String {
                        callback(URL(string: urlString), nil)
                    } else {
                        callback(nil, response.result.error)
                    }
                case .failure(let error):
                    callback(nil, error)
                }
        }
    }
    
    /**
     * Intercept all url and pass to the function to resume the login process.
     * - parameter url: the url intercepted by the webview
     * - return true if the url has the expected token or false otherwise
    */
    public func ssoAuthenticationResume(url: URL) -> Bool {
        /* */
        let urlString = url.absoluteString
        if let range = urlString.range(of: AuthConstants.auth0ResultIdToken + "="), let endRange = urlString.range(of: "&state=") {
            
            let state = String(urlString[urlString.index(endRange.upperBound, offsetBy: 0)..<urlString.endIndex])
            if (state != loginStateUUID) {
                return false
            }
            let token = String(urlString[urlString.index(range.upperBound, offsetBy: 0)..<endRange.lowerBound])
            let headers:HTTPHeaders = ["Accept": "application/json", "Authorization": token]
            
            Alamofire.request(mwAuthHost + AuthConstants.mwUsersSSOUsers, method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate().responseJSON { response in
                    switch response.result {
                    case .success:
                        guard let data = response.result.value as? [String : AnyObject] else {
                            self.notifyUnauthorisedError(message: response.result.error?.localizedDescription ?? AuthConstants.resultUnknownError)
                            return
                        }
                        NotificationCenter.default.post(name: .loginResultNotification, object: nil, userInfo: data)
                        
                    case .failure(let error):
                        self.notifyUnauthorisedError(message: error.localizedDescription)
                        if let data = response.data, let token = String(data: data, encoding: .utf8) {
                            self.loginWithAuthToken(bearerToken: token, path: AuthConstants.mwUsersSSOUsers)
                        }
                    }
            }
            return true
        } else {
            return false
        }
        
    }
    
    deinit {
        // Never happens -- singleton
        NotificationCenter.default.removeObserver(self)
    }
    
    public func switchCompany(companyId: String, authToken: String, delegate: AuthenticationResultProtocol?) {
        let headers = ["Authorization" : authToken]
        Alamofire.request(mwAuthHost + AuthConstants.mwUsersSwitchCompanyPath + "/" + companyId, headers: headers).responseJSON { response in
            switch response.result{
            case .success:
                guard let data = response.result.value as? [String : AnyObject], let _ = data[AuthConstants.resultToken]  else {
                    
                    if let del = delegate, let error = response.result.error {
                        del.onAuthenticationFailure?(error: error)
                    }
                    return
                }
                if let del = delegate {
                    del.onAuthenticationSuccess?(resultPayload: data)
                }
            case .failure(let error):
                if let del = delegate {
                    del.onAuthenticationFailure?(error: error)
                }
            }
        }
    }
}
