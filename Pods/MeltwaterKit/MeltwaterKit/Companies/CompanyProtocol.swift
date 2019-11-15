//
//  CompanyProtocol.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 11/3/19.
//  Copyright © 2019 Meltwater. All rights reserved.
//

import Foundation

//MARK: View
public protocol CompanyViewProtocol: class {
    /* Presenter -> ViewController */
    var presenter: CompanyPresenterProtocol?  { get set }
    func getCompanies()
    func switchCompany(companyId: String)
    // Results
    func onGetCompaniesSuccess(companies:[CompanyModel])
    func onGetCompaniesError(error:Error)
    func switchCompanyResult(error:Error?) // Error null if success
    
}
// Make default impl so API consumer don't havee to implement it
public extension CompanyViewProtocol {
    
    func getCompanies() {
        presenter?.getCompanies()
    }
    
    func switchCompany(companyId: String) {
        presenter?.switchCompany(companyId: companyId)
    }
}
//MARK: Presenter -
public protocol CompanyPresenterProtocol: class {
    var view: CompanyViewProtocol? { get set }
    var interactor: CompanyInteractorInputProtocol? { get set }
    /* View -> Presenter */ // STARTING POINT from View - viewDidLoad
    func getCompanies()
    func switchCompany(companyId: String)
}

public protocol CompanyInteractorOutputProtocol: class {
    /* Interactor -> Presenter */
    func didSwitchCompany(error: Error?) // Both success & error
    func didGetCompanies(companies:[CompanyModel])
    func didGetCompaniesError(error: Error)
}

//MARK: Interactor -
public protocol CompanyInteractorInputProtocol: class {
    /* Presenter -> Interactor */
    var presenter: CompanyInteractorOutputProtocol?  { get set }
    func switchCompany(companyId: String)
    func getCompanies()
}

//MARK: Router
public protocol CompanyRouterProtocol: class {
    /* Presenter -> Router */
}
