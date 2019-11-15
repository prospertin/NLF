//
//  AuthenticationProtocol.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 11/1/19.
//  Copyright © 2019 Meltwater. All rights reserved.
//

import Foundation

//MARK: View
public protocol AuthenticationViewProtocol: class {
    /* Presenter -> ViewController */
    var presenter: AuthenticationPresenterProtocol?  { get set }
    func loginWithCredentials(email: String, password: String)
    func LoginWithEmailLink(email: String)
    func refreshToken(token: String)
    // If error is null => success
    func loginResult(error: Error?)
    // If error is null => success
    func emailResult(error:Error?)
}
// Make default impl so API consumer don't havee to implement it
public extension AuthenticationViewProtocol {
    
    func loginWithCredentials(email: String, password: String){
        presenter?.loginWithCredentials(email: email, password: password)
    }
    
    func LoginWithEmailLink(email: String) {
        presenter?.loginWithEmailLink(email: email)
    }
    
    func refreshToken(token: String){
        presenter?.refreshToken(token: token)
    }
}
//MARK: Presenter -
public protocol AuthenticationPresenterProtocol: class {
    var view: AuthenticationViewProtocol? { get set }
    var interactor: AuthenticationInteractorInputProtocol? { get set }
    /* View -> Presenter */ // STARTING POINT from View - viewDidLoad
    func loginWithCredentials(email: String, password: String)
    func loginWithEmailLink(email: String)
    func refreshToken(token: String)
}

public protocol AuthenticationInteractorOutputProtocol: class {
    /* Interactor -> Presenter */
    func didLogin(error: Error?)
    func didSendEmail(error: Error?)
}

//MARK: Interactor -
public protocol AuthenticationInteractorInputProtocol: class {
    /* Presenter -> Interactor */
    var presenter: AuthenticationInteractorOutputProtocol?  { get set }
    func loginWithCredentials(email: String, password: String)
    func sendEmailLink(email: String)
    func refreshToken(token: String)
}

//MARK: Router
public protocol AuthenticationRouterProtocol: class {
    /* Presenter -> Router */
}
