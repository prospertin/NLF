//
//  LoginInteractor.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 11/1/19.
//  Copyright © 2019 Meltwater. All rights reserved.
//

import Foundation
import ObjectMapper

public class AuthenticationInteractor: AuthenticationInteractorInputProtocol, AuthenticationResultProtocol {
    
    public var presenter: AuthenticationInteractorOutputProtocol?
    
    var loginService:MWLoginService?
    
    public init(hostName: String) {
        loginService = MWLoginService(authHost: hostName)
        NotificationCenter.default.addObserver(self, selector: #selector( loginResultNotificationHandler), name: .loginResultNotification, object: nil)
    }
    
    public func loginWithCredentials(email: String, password: String) {
        loginService?.loginWithUser(login: email, password: password)
    }
    
    public func sendEmailLink(email: String) {
        loginService?.startPasswordlessDeepLinkWith(email: email, magicLinkDelegate: self)
    }
    
    public func refreshToken(token: String) {
        loginService?.refreshToken(refreshToken: token, refreshTokenDelegate: self)
    }
    
    @objc fileprivate func loginResultNotificationHandler(note: Notification) {
        if let error = note.userInfo?[AuthConstants.resultError] as? Error {
            presenter?.didLogin(error: error)
        } else {
            if let accountJson = note.userInfo as? [String : Any] {
                if let account = Mapper<AccountModel>().map(JSON: accountJson),
                    let user = account.user, let company = account.company {
                    MWUserDefaults.saveMappableObject(obj: user, key:AuthConstants.userKey)
                    MWUserDefaults.saveMappableObject(obj: company, key: AuthConstants.companyKey)
                    MWKeychain.saveToken(token: account.token)
                    if let expires = account.expires as? String,
                        let date =  MWDateFormatter.shared.rfcUTCFormatToDate(formattedDate: expires) {
                        MWKeychain.saveExpires(expires: "\(date.timeIntervalSince1970)")
                        presenter?.didLogin(error: nil)
                    } else {
                        presenter?.didLogin(error: AuthTokenError(code: 401, message: "Invalid Token"))
                    }
                }
            }
        }
    }
    
    public func handleDeepLink(url: URL, sourceApplication: String?) -> Bool {
        return loginService?.openDeepLink(url: url, sourceApplication: sourceApplication) ?? false
    }
}

extension AuthenticationInteractor: EmailLinkProtocol {
    public func onEmailSent() {
        presenter?.didSendEmail(error: nil)
    }
    
    public func onEmailFailure(error: Error) {
        presenter?.didSendEmail(error: error)
    }
}

extension AuthenticationInteractor: RefreshTokenProtocol {
    public func onRefreshToken(resultPayload: Dictionary<String, Any>) {
        if let token = resultPayload[AuthConstants.resultToken] as? String,
            let expires = resultPayload[AuthConstants.resultExpires] as? Int64  {
            MWKeychain.saveToken(token: token)
            MWKeychain.saveExpires(expires: String(expires/1000))
        }
    }
    
    public func onRefreshTokenFailure(error: Error) {
        debugPrint("Error refreshing token: \(error)")
    }
}
