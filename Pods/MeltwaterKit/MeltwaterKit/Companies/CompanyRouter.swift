//
//  File.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 11/3/19.
//  Copyright © 2019 Meltwater. All rights reserved.
//

import Foundation

public class CompanyRouter: CompanyRouterProtocol {
    static func initializeModule(view: CompanyViewProtocol?, interactor: CompanyInteractor) {
        let presenter = CompanyPresenter()
        view?.presenter = presenter
        presenter.view = view // Weak
        presenter.interactor = interactor
        interactor.presenter = presenter
    }
}
