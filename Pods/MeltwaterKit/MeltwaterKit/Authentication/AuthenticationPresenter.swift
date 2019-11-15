//
//  AuthenticationPresenter.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 11/1/19.
//  Copyright © 2019 Meltwater. All rights reserved.
//

import Foundation

public class AuthenticationPresenter: AuthenticationPresenterProtocol {
    weak public var view: AuthenticationViewProtocol?
    public var interactor: AuthenticationInteractorInputProtocol?
    
    //MARK: - Actions
    public func loginWithCredentials(email: String, password: String) {
        interactor?.loginWithCredentials(email: email, password: password)
    }
    
    public func loginWithEmailLink(email: String) {
        interactor?.sendEmailLink(email: email)
    }
    
    public func refreshToken(token: String) {
        interactor?.refreshToken(token: token)
    }
}

extension AuthenticationPresenter: AuthenticationInteractorOutputProtocol {
    //MARK: - Results - Output
    public func didLogin(error: Error?) {
        view?.loginResult(error: error)
    }

    public func didSendEmail(error: Error?) {
        view?.emailResult(error: error)
    }
}
