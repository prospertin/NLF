//
//  AuthenticationManager.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 11/1/19.
//  Copyright © 2019 Meltwater. All rights reserved.
//

import Foundation
import UIKit

public class MWAuthentication {

    var interactor:AuthenticationInteractor?
    var view:AuthenticationViewProtocol?
    
    public init(authHost: String, view: AuthenticationViewProtocol?) {
        self.view = view
        self.interactor = AuthenticationInteractor(hostName: authHost)
        AuthenticationRouter.initializeModule(view: view, interactor: interactor!)
    }
    
    public func isUserLoggedIn() -> Bool {
        if let _ = MWKeychain.loadToken(), let expires = MWKeychain.loadExpires() {
            let date = Date(timeIntervalSince1970: TimeInterval(expires)!)
            return date > Date()
        }
        return false
    }
    
    public class func getAuthToken() -> String? {
        return MWKeychain.loadToken()
    }
    
    public func refreshToken() {
        if let token = MWAuthentication.getAuthToken() {
            interactor?.refreshToken(token: token)
        }
    }
    
    public func loginWithCredentials(email: String, password: String) {
        view?.loginWithCredentials(email: email, password: password)
    }
    
    public func loginWithEmailLink(email: String) {
        view?.LoginWithEmailLink(email: email)
    }
    
    public func handleDeepLink(url: URL, sourceApplication: String?) -> Bool {
        return interactor?.handleDeepLink(url: url, sourceApplication: sourceApplication) ?? false
    }
}
