

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

@objc
public protocol EmailLinkProtocol: class {
    @objc func onEmailSent()
    @objc func onEmailFailure(error: Error)
}

@objc
public protocol RefreshTokenProtocol: class {
    @objc optional func onRefreshToken(resultPayload: Dictionary<String, Any>)
    @objc optional func onRefreshTokenFailure(error: Error)
}

@objc // Should USE Notification.default because it's easier for Magiclink
public protocol LoginProtocol: class {
    @objc func onLoginSuccess(resultPayload: Dictionary<String, Any>)
    @objc func onLoginFailure(error: Error)
}

public class LoginService: NSObject {
    
    var mwAuthHost = "https://mobile-services.meltwater.com/"
    var mwDBConnection = "meltwater-dashboards" // Default
    var auth0Domain = "meltwater-mobile.auth0.com"
    var client:Authentication = Auth0.authentication()
    
    static var universalLoginTransaction = false
    
    public typealias completionHandler = (_ resultPayload: Dictionary<String, Any>?, _ error: Error?) -> Void
    public typealias refreshTokenCompletionHandler = (_ resultPayload: Dictionary<String, Any>?, _ error: AuthTokenError?) -> Void
    
    public override init () {
        
        super.init()
        
        if let path = Bundle.main.path(forResource: "Auth0", ofType: "plist"),
            let values = NSDictionary(contentsOfFile: path) as? [String: Any] {
            if let db = values["MWDBConnection"] as? String {
                mwDBConnection = db
            }
            if let host = values["BffHost"] as? String {
                mwAuthHost = host
            }
            if let domain = values["Domain"] as? String {
                auth0Domain = domain
            }
        }
    }
    
    /**
     * Send email to Auth0 and receive an email with the magic link
     */
    public func startMagicLinkWith(email: String, magicLinkDelegate: EmailLinkProtocol?) {
        startPasswordlessForType(type: PasswordlessType.iOSLink, email: email, magicLinkDelegate: magicLinkDelegate)
    }
    
    public func startPasswordlessDeepLinkWith(email: String, magicLinkDelegate: EmailLinkProtocol?) {
        startPasswordlessForType(type: PasswordlessType.Code, email: email, magicLinkDelegate: magicLinkDelegate)
        
    }
    
    private func startPasswordlessForType(type: PasswordlessType, email: String, magicLinkDelegate: EmailLinkProtocol?) {
        client.startPasswordless(email: email, type: type, connection: "email")
            .start { result in
                switch result {
                    case .success:
                        print("Really Sent email to \(email)")
                        let defaults = UserDefaults.standard
                        defaults.set(email, forKey: AuthConstants.authEmailKey)
                        DispatchQueue.main.async {
                            if let del = magicLinkDelegate {
                                del.onEmailSent()
                            }
                        }
                    case .failure(let error):
                        print("Sent email failed \(error.localizedDescription)")
                        if let del = magicLinkDelegate {
                            debugPrint(error)
                            del.onEmailFailure(error: error)
                        }
                }
        }
    }
    
    /**
     * Login using userId/password and return the Auth0 token, refreshToken, and expires time in milliseconds
     */
    public func loginWithUser( login: String, password: String){
        let payload = [
            AuthConstants.reqParamUserName : login,
            AuthConstants.reqParamPassword : password,
            AuthConstants.reqParamGrantType : "http://auth0.com/oauth/grant-type/password-realm",
            AuthConstants.reqParamClientId : client.clientId,
            AuthConstants.reqParamRealm : mwDBConnection,
            AuthConstants.reqParamScope: AuthConstants.scopeValues
        ]

        let headers:HTTPHeaders = ["Accept": "application/json"]
        
        Alamofire.request(client.url.absoluteString + "/oauth/token", method: .post, parameters: payload, encoding: JSONEncoding.default, headers: headers)
            .validate().responseJSON { response in
                switch response.result {
                case .success:
                    guard let dict = response.result.value as? [String : AnyObject] else {
                        self.notifyUnauthorisedError(message: response.result.error?.localizedDescription ?? AuthConstants.resultUnknownError)
                        return
                    }
                    self.loadUserProfile(authResult: dict, tokenType: AuthConstants.resultPasswordTokenType, delegate: nil)
                case .failure(let error):
                    self.notifyUnauthorisedError(message: error.localizedDescription)
                }
        }
        
    }
    
    /**
     * Do a silent auth
     */
    public func silentWebAuthentication() {
        // First see if user session is still valid by doing silent auth. If failed, call universalLogin with prompt
        doWebAuth(silent: true)
    }
    /**
     * Do universal login with SSO
     *
     */
    public func webAuthentication() {
        doWebAuth(silent: false)
    }
    
    /**
     * Do universal login with SSO
     * @param withPrompt: set to false to attempt silent login
     */
    func doWebAuth(silent: Bool) {
        
        objc_sync_enter(LoginService.universalLoginTransaction)
        
        if LoginService.universalLoginTransaction {
            debugPrint("There is already a login transaction running")
            objc_sync_exit(LoginService.universalLoginTransaction)
            return
        } else {
            LoginService.universalLoginTransaction = true
        }
    
        objc_sync_exit(LoginService.universalLoginTransaction)
        
        let webAuth = Auth0
            .webAuth()
            .audience("https://" + auth0Domain + "/userinfo")
            .scope(AuthConstants.scopeValues)
            .connection(mwDBConnection)
            .responseType([.code])
        if silent {
            _ = webAuth.parameters([AuthConstants.reqParamPrompt : AuthConstants.promptNone])
        }
        webAuth.start {
                LoginService.universalLoginTransaction = false
                switch $0 {
                case .success(let credentials):
                    guard let idToken = credentials.idToken, let refreshToken = credentials.refreshToken else {
                        self.notifyUnauthorisedError(message: AuthConstants.resultUnknownError)
                        return
                    }
                    let dict:[String:Any] = [AuthConstants.auth0ResultIdToken: idToken, AuthConstants.auth0ResultRefreshToken: refreshToken]
                    self.loadUserProfile(authResult: dict, tokenType: AuthConstants.resultUniversalLoginTokenType, delegate: nil)
                case .failure(let error):
                    if (error.localizedDescription == AuthConstants.universalLoginRequired) {
                        self.webAuthentication()
                    } else {
                        self.notifyUnauthorisedError(message: error.localizedDescription)
                    }
                }
        }
    }
    
    /**
     * logout from sso. This is just for clean up cookie. Doesn't matter if call failed, since the
     * app should already clear the token stored locally.
     */
    public func webAuthenticationLogout(presenter: UIViewController?) {
        let clientId = client.clientId
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        let urlString = "https://" + auth0Domain
            + "/v2/logout?federated&client_id="
            + clientId + "&returnTo="
            + bundleId + "%3A%2F%2F" + auth0Domain + "%2Flogout"
        
        if let url = URL(string: (urlString)), let pr = presenter {
            let vc = SFSafariViewController(url: url)
            pr.present(vc, animated: false){
                //vc.dismiss(animated: false)
            }
        }
    }
    
    public func webAuthenticationResume(open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return Auth0.resumeAuth(url, options: options)
    }
    
    public func openDeepLink(url: URL, sourceApplication: String?) -> Bool {
        let result = parseDeepLink(url: url)
        
        if let _ = result[AuthConstants.resultError] {
            NotificationCenter.default.post(name: .loginResultNotification, object: nil, userInfo: result)
        } else {
            loadUserProfile(authResult: result, tokenType: AuthConstants.resultMagicTokenType, delegate: nil)
        }
        return true
    }
    
    public func parseDeepLink(url: URL) -> Dictionary <String, Any>{
        
        //var authResult:AuthResult?
        
        guard let range = url.absoluteString.range(of: "#") else {
            let error = NSError(domain:"com.meltwater.meltwaterkit", code: HTTPStatusCodes.BadRequest.rawValue, userInfo: [NSLocalizedDescriptionKey : "Invalid credentials"])
            return [AuthConstants.resultError : error]
        }
        let urlString = String(url.absoluteString[range.upperBound..<url.absoluteString.endIndex])
        let params = urlString.components(separatedBy: "&")
        var idToken: String? = nil
        var refreshToken: String? = nil
        var accessToken: String? = nil
        
        params.forEach({ component in
            let keyValue = component.components(separatedBy: "=")
            if keyValue.count == 2 {
                switch(keyValue[0]) {
                case AuthConstants.auth0ResultIdToken:
                    idToken = keyValue[1]
                case AuthConstants.auth0ResultRefreshToken:
                    refreshToken = keyValue[1]
                case AuthConstants.auth0ResultAccessToken:
                    accessToken = keyValue[1]
                default:
                    break
                }
            }
        })
        
        if let token = idToken {
            return [AuthConstants.auth0ResultIdToken : token, AuthConstants.auth0ResultRefreshToken : refreshToken ?? "",
                    AuthConstants.auth0ResultAccessToken : accessToken ?? ""]
        } else {
            let error = NSError(domain:"com.meltwater.meltwaterkit", code: HTTPStatusCodes.BadRequest.rawValue, userInfo: [NSLocalizedDescriptionKey : "Bad link"])
            return [AuthConstants.resultError : error]
        }
    }
    
    /**
     * Magic link via universal linking
     */
    public func continueUserActivity(userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        let valid = false //client.continue(userActivity, restorationHandler:restorationHandler)
        if( !valid ) {
            print("Error validating the magic link: \(String(describing: userActivity.webpageURL))")
        }
        
        return valid
    }
    
    /**
     * Sign up a new user using userId/password More TODO
     */
    public func signUpUser(login: String, password: String, userName:String?) {
        
        Auth0
            .authentication()
            .signUp(
                email: login, username: userName,
                password: password,
                connection: mwDBConnection //Database/Connection name
            )
            .start { result in
                switch result {
                case .success(let credentials):
                    print("access_token: \(String(describing: credentials.accessToken))")
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    
    /**
     * Refresh token that are not OAuth2 token (like magic link token)
     */
    public func refreshPasswordlessToken(refreshToken: String, refreshTokenDelegate: RefreshTokenProtocol?) {
        
        // The token has the client_company_id appended to it if it's a magic link token. TODO combine connections. https://auth0.com/docs/link-accounts
        Auth0
            .authentication()
            .delegation(withParameters: [AuthConstants.resultRefreshToken : refreshToken])
            .start { result in
                switch result {
                case.success(let credentials):
                    if let del = refreshTokenDelegate {
                        if let token = credentials[AuthConstants.auth0ResultIdToken] {
                            let result = [AuthConstants.auth0ResultIdToken:token]
                            self.loadUserProfile(authResult: result, tokenType: AuthConstants.resultPasswordTokenType, delegate: del)
                        }
                    }
                    
                case .failure(let error):
                    if let del = refreshTokenDelegate {
                        del.onRefreshTokenFailure!(error: error)
                    }
                }
        }
    }
    
    /**
     * Refresh token that are OAuth2 token (when login with password)
     */
    public func refreshToken(refreshToken: String, refreshTokenDelegate: RefreshTokenProtocol?, completion: completionHandler? = nil) {
        
        Auth0
            .authentication()
            .renew(withRefreshToken: refreshToken)
            .start { result in
                switch result {
                case .success(let credentials):
                    print("access_token: \(String(describing: credentials.idToken))")
                    if let token = credentials.idToken {
                        let authResult = [AuthConstants.auth0ResultIdToken: token, AuthConstants.auth0ResultRefreshToken: refreshToken]
                        if let del = refreshTokenDelegate {
                            self.loadUserProfile(authResult: authResult, tokenType: AuthConstants.resultPasswordTokenType, delegate: del)
                        }else{
                            self.loadUserProfile(authResult: authResult, tokenType: AuthConstants.resultPasswordTokenType, delegate: nil, completion: { (resultPayload, error) in
                                completion?(resultPayload,error)
                            })
                        }
                    } else {
                        // The idToken is not in the payload -- cannot happen
                        debugPrint("idToken is not available - the token hasn't expired?")
                    }
                    
                    
                case .failure(let error):
                    
                    var refreshTokenError = AuthTokenError.other(error.localizedDescription)
                    if let authError = error as? AuthenticationError {
                        refreshTokenError = AuthTokenError(code: authError.statusCode, message: authError.description)
                    }
                    
                    if let del = refreshTokenDelegate {
                        del.onRefreshTokenFailure!(error: refreshTokenError)
                    }
                    completion?(nil, refreshTokenError)
                    
                }
        }
    }
    
    /* Send an email to user. Only work for authentication using Auth0 database */
    public func requestChangePassword(email: String, emailLinkDelegate: EmailLinkProtocol?) {
        client.resetPassword(email: email, connection: mwDBConnection)
            .start({ result in
                switch result {
                case .success:
                    if let del = emailLinkDelegate {
                        del.onEmailSent()
                    }
                case .failure(let error):
                    if let del = emailLinkDelegate {
                        del.onEmailFailure(error: error)
                    }
                }
        })
    }
    /**
     *
     */
    internal func notifyUnauthorisedError(message: String) {
        let error = NSError(domain:"com.meltwater.meltwaterkit", code: HTTPStatusCodes.Unauthorized.rawValue, userInfo: [NSLocalizedDescriptionKey: message])
        NotificationCenter.default.post(name: .loginResultNotification, object: nil, userInfo: [AuthConstants.resultError : error])
    }
    
    deinit {
        // Never happens -- singleton
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     *
     */

    internal func loadUserProfile(authResult: Dictionary<String, Any>, tokenType: String, delegate: RefreshTokenProtocol?, completion: completionHandler? = nil ) {

        var resultDict = Dictionary<String, Any>()
        
        if let token = authResult[AuthConstants.auth0ResultIdToken] as? String,
            tokenType != AuthConstants.auth0ResultTokenType{
            
            resultDict[AuthConstants.resultToken] = token
            if let refreshToken = authResult[AuthConstants.auth0ResultRefreshToken] as? String {
                resultDict[AuthConstants.resultRefreshToken] = refreshToken
            }
            resultDict[AuthConstants.resultTokenType] = tokenType
            
            let lang = self.getLanguage()
            let headers:HTTPHeaders = ["Accept": "application/json", "Authorization" : token, "Accept-Language": "\(lang)", "Origin": auth0Domain]
            
            Alamofire.request(mwAuthHost + AuthConstants.externalUsersAuthPath, method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate().responseJSON { response in
                    switch response.result {
                    case .success:
                        guard let dict = response.result.value as? [String : AnyObject] else {
                            self.notifyUnauthorisedError(message: response.result.error?.localizedDescription ?? AuthConstants.resultUnknownError)
                            return
                        }
                        resultDict[AuthConstants.resultEmail] = dict[AuthConstants.resultEmail] as! String;
                        resultDict[AuthConstants.resultExpires] = dict[AuthConstants.resultExpires] as! Int;
                        resultDict[AuthConstants.resultFullName] = dict[AuthConstants.resultFullName] as? String
                        resultDict[AuthConstants.resultFirstName] = dict[AuthConstants.resultFirstName]as? String
                        resultDict[AuthConstants.resultLastName] = dict[AuthConstants.resultLastName] as? String
                        resultDict[AuthConstants.resultLang] = dict[AuthConstants.resultLang] as? String
                        resultDict[AuthConstants.resultUserId] = dict[AuthConstants.resultUserId] as? String
                        resultDict[AuthConstants.resultCompanyId] = dict[AuthConstants.resultCompanyId] as? String
                        resultDict[AuthConstants.resultJobTitle] = dict[AuthConstants.resultJobTitle] as? String
                        resultDict[AuthConstants.resultCustomer] = dict[AuthConstants.resultCustomer] as? String
                        resultDict[AuthConstants.resultGermanPremiumContent] = dict[AuthConstants.resultGermanPremiumContent] as? Bool
                        resultDict[AuthConstants.resultUsPremiumContent] = dict[AuthConstants.resultUsPremiumContent] as? Bool
                        
                     //   NotificationCenter.default.post(name: .loginResultNotification, object: nil, userInfo: resultDict)
                    
                        if let del = delegate {
                            del.onRefreshToken!(resultPayload: resultDict)
                        } else {
                            NotificationCenter.default.post(name: .loginResultNotification, object: nil, userInfo: resultDict)
                        }
                        
                        completion?(resultDict,nil)
                        
                    case .failure(let error):
                        if let del = delegate {
                            del.onRefreshTokenFailure!(error: error)
                        } else {
                            self.notifyUnauthorisedError(message: error.localizedDescription)
                        }
                        completion?(nil,error)
                    }
            }
        } else {
            self.notifyUnauthorisedError(message: "Missing token or expires")
        }
    }
    
    internal func getLanguage() -> String {
        guard let lang = Locale.preferredLanguages.first else {
            return AuthConstants.english
        }
        
        if lang.hasPrefix(AuthConstants.chineseLanguageIdentifierSimplified) {
            return AuthConstants.chineseSimplified
        } else if lang.hasPrefix(AuthConstants.chineseLanguageIdentifierTraditional){
            return AuthConstants.chineseTrad
        } else {
            let index = lang.index(lang.startIndex, offsetBy: 2)
            return String(lang[..<index])
        }
    }
    
}

