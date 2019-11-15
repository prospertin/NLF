//
//  CompanyPresenter.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 11/3/19.
//  Copyright © 2019 Meltwater. All rights reserved.
//

import Foundation

public class CompanyPresenter: CompanyPresenterProtocol {
    weak public var view: CompanyViewProtocol?
    public var interactor: CompanyInteractorInputProtocol?
    
    //MARK: - Actions
    public func getCompanies() {
        interactor?.getCompanies()
    }
    
    public func switchCompany(companyId: String) {
        interactor?.switchCompany(companyId: companyId)
    }
}

extension CompanyPresenter: CompanyInteractorOutputProtocol {
    public func didGetCompaniesError(error: Error) {
        view?.onGetCompaniesError(error: error)
    }
    
    //MARK: - Results
    public func didGetCompanies(companies: [CompanyModel]) {
        view?.onGetCompaniesSuccess(companies: companies)
    }
    
    public func didSwitchCompany(error: Error?) {
        view?.switchCompanyResult(error: error)
    }
}
