//
//  MWCompany.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 11/3/19.
//  Copyright © 2019 Meltwater. All rights reserved.
//

import Foundation

public class MWCompany {

var interactor:CompanyInteractor?
var view:CompanyViewProtocol?

    public init(authHost: String, view: CompanyViewProtocol?) {
        self.view = view
        self.interactor = CompanyInteractor(hostName: authHost)
        CompanyRouter.initializeModule(view: view, interactor: interactor!)
    }
    
    public func getCompanies() {
        view?.getCompanies()
    }

    public func switchCompany(companyId: String) {
        view?.switchCompany(companyId: companyId)
    }
}
